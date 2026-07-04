import { execFileSync } from "node:child_process";
import { mkdirSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";

const root = process.cwd();
const outDir = path.join(tmpdir(), "tonefex-backend-tests");
const tsconfigPath = path.join(outDir, "tsconfig.backend-tests.json");
const tscPath = path.join(root, "node_modules", "typescript", "bin", "tsc");
const files = [
  ...collectTypeScriptFiles(path.join(root, "lib", "rule-engine")),
  ...collectTypeScriptFiles(path.join(root, "lib", "backend", "tone-adaptation")),
  path.join(root, "tests", "backend-tone-service.test.ts")
];

rmSync(outDir, { recursive: true, force: true });
mkdirSync(outDir, { recursive: true });

writeFileSync(
  tsconfigPath,
  JSON.stringify(
    {
      compilerOptions: {
        target: "ES2022",
        module: "CommonJS",
        moduleResolution: "Node",
        strict: true,
        skipLibCheck: true,
        esModuleInterop: true,
        outDir,
        rootDir: root,
        typeRoots: [path.join(root, "node_modules", "@types")],
        types: ["node"]
      },
      files
    },
    null,
    2
  )
);

execFileSync(process.execPath, [tscPath, "-p", tsconfigPath], {
  cwd: root,
  stdio: "inherit"
});

execFileSync(process.execPath, ["--test", path.join(outDir, "tests", "backend-tone-service.test.js")], {
  cwd: root,
  stdio: "inherit"
});

function collectTypeScriptFiles(directory) {
  return readdirSync(directory)
    .flatMap((entry) => {
      const fullPath = path.join(directory, entry);
      if (statSync(fullPath).isDirectory()) {
        return collectTypeScriptFiles(fullPath);
      }
      return fullPath.endsWith(".ts") ? [fullPath] : [];
    })
    .sort();
}
