import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const migrationPaths = [
  path.join(root, "supabase", "migrations", "20260717150000_rebuild_master_equipment_catalog.sql"),
  path.join(root, "supabase", "migrations", "20260718100000_expand_master_equipment_catalog_verified.sql")
];

const SUPPORTED_TYPES = new Set(["electric_guitar", "bass_guitar", "guitar_amp", "bass_amp"]);
const tuplePattern = /\('((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*(true|false),\s*'((?:''|[^'])*)'\)/g;

function unescapeSql(value) {
  return value.replaceAll("''", "'");
}

function readSeedRows(filePath) {
  const text = fs.readFileSync(filePath, "utf8");
  const rows = [];

  for (const match of text.matchAll(tuplePattern)) {
    rows.push({
      equipmentType: unescapeSql(match[1]),
      brand: unescapeSql(match[2]),
      model: unescapeSql(match[3]),
      series: unescapeSql(match[4]),
      isPopular: match[5] === "true",
      description: unescapeSql(match[6]),
      sourceFile: path.basename(filePath)
    });
  }

  return rows;
}

const rows = migrationPaths.flatMap(readSeedRows);
const duplicateKeys = new Map();
const counts = {
  electric_guitar: 0,
  bass_guitar: 0,
  guitar_amp: 0,
  bass_amp: 0
};

for (const row of rows) {
  if (!SUPPORTED_TYPES.has(row.equipmentType)) {
    throw new Error(`Unsupported equipment type "${row.equipmentType}" in ${row.sourceFile}: ${row.brand} ${row.model}`);
  }

  if (!row.brand.trim() || !row.model.trim() || !row.series.trim() || !row.description.trim()) {
    throw new Error(`Incomplete seed row in ${row.sourceFile}: ${JSON.stringify(row)}`);
  }

  if (row.brand === "Generic") {
    throw new Error(`Generic brand is not allowed in ${row.sourceFile}: ${row.model}`);
  }

  const key = `${row.equipmentType}|${row.brand.toLowerCase()}|${row.model.toLowerCase()}`;
  duplicateKeys.set(key, (duplicateKeys.get(key) || 0) + 1);
  counts[row.equipmentType] += 1;
}

const duplicates = [...duplicateKeys.entries()].filter(([, count]) => count > 1);
if (duplicates.length) {
  throw new Error(
    `Duplicate equipment_type + brand + model rows found:\n${duplicates
      .map(([key, count]) => `  ${key} (${count})`)
      .join("\n")}`
  );
}

const verifiedExpansionCount = readSeedRows(migrationPaths[1]).length;
if (verifiedExpansionCount < 80) {
  throw new Error(`Expected at least 80 verified expansion rows, found ${verifiedExpansionCount}.`);
}

console.log("Equipment catalog validation passed.");
console.log(JSON.stringify({ counts, verifiedExpansionCount, totalSeedRows: rows.length }, null, 2));
