"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { Loader2, X } from "lucide-react";
import { SearchableGearDropdown } from "@/components/searchable-gear-dropdown";
import {
  cacheMyGearProfile,
  createEmptyMyGearProfile,
  normalizeMyGearProfile,
  type GearSearchItem,
  type GearSelectionCategory,
  type GearSelectionMetadata,
  type MyGearProfile
} from "@/lib/my-gear";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

export function MyGearSelectors() {
  const supabase = useMemo(() => createSupabaseBrowserClient(), []);
  const [profile, setProfile] = useState<MyGearProfile>(createEmptyMyGearProfile());
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [status, setStatus] = useState("");
  const [userId, setUserId] = useState<string | null>(null);
  const lastSavedRef = useRef<string>("");

  useEffect(() => {
    let active = true;

    async function loadProfile() {
      if (!supabase) {
        if (active) {
          setLoading(false);
        }
        return;
      }

      const {
        data: { user }
      } = await supabase.auth.getUser();

      if (!active) {
        return;
      }

      if (!user) {
        setLoading(false);
        return;
      }

      setUserId(user.id);

      const { data } = await supabase.from("profiles").select("my_gear_profile").eq("id", user.id).maybeSingle();
      if (!active) {
        return;
      }

      const normalized = normalizeMyGearProfile(data?.my_gear_profile);
      setProfile(normalized);
      cacheMyGearProfile(normalized);
      lastSavedRef.current = JSON.stringify(normalized);
      setLoading(false);
    }

    void loadProfile();

    return () => {
      active = false;
    };
  }, [supabase]);

  useEffect(() => {
    if (loading) {
      return;
    }

    cacheMyGearProfile(profile);
  }, [loading, profile]);

  useEffect(() => {
    if (!supabase || !userId || loading) {
      return;
    }

    const serialized = JSON.stringify(profile);
    if (serialized === lastSavedRef.current) {
      return;
    }

    const timeout = window.setTimeout(async () => {
      setSaving(true);
      const { error } = await supabase.from("profiles").update({ my_gear_profile: profile }).eq("id", userId);

      if (error) {
        setStatus(error.message);
      } else {
        setStatus("My Gear saved.");
        lastSavedRef.current = serialized;
      }

      setSaving(false);
    }, 300);

    return () => {
      window.clearTimeout(timeout);
    };
  }, [loading, profile, supabase, userId]);

  function setSingleSelection(key: "guitar" | "amp" | "multifx", category: GearSelectionCategory, item: GearSearchItem) {
    const selection = toSelection(category, item);
    setProfile((current) => ({
      ...current,
      [key]: selection,
      updated_at: new Date().toISOString()
    }));
  }

  function addPedal(item: GearSearchItem) {
    const selection = toSelection("pedal", item);

    setProfile((current) => {
      const exists = current.pedals.some((pedal) => pedal.model_id === selection.model_id);
      if (exists) {
        return current;
      }

      return {
        ...current,
        pedals: [...current.pedals, selection],
        updated_at: new Date().toISOString()
      };
    });
  }

  function removeSingleSelection(key: "guitar" | "amp" | "multifx") {
    setProfile((current) => ({
      ...current,
      [key]: null,
      updated_at: new Date().toISOString()
    }));
  }

  function removePedal(modelId: string) {
    setProfile((current) => ({
      ...current,
      pedals: current.pedals.filter((pedal) => pedal.model_id !== modelId),
      updated_at: new Date().toISOString()
    }));
  }

  if (loading) {
    return (
      <section className="compact-card mb-8 p-6 sm:p-8">
        <div className="flex items-center gap-3 text-sm text-slate-600">
          <Loader2 className="h-4 w-4 animate-spin" />
          Loading My Gear profile...
        </div>
      </section>
    );
  }

  return (
    <section className="compact-card mb-8 p-6 sm:p-8">
      <div className="mb-6 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 className="text-2xl font-bold">My Gear Profile</h2>
          <p className="text-sm text-slate-600">Search and save your core setup. Selections autosave and reload on login.</p>
        </div>
        <div className="text-sm text-slate-500">
          {saving ? (
            <span className="inline-flex items-center gap-2">
              <Loader2 className="h-4 w-4 animate-spin" />
              Saving...
            </span>
          ) : (
            status || null
          )}
        </div>
      </div>

      {!userId ? <p className="mb-5 rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm font-semibold text-amber-900">Sign in to persist your My Gear setup.</p> : null}

      <div className="grid gap-5 md:grid-cols-2">
        <div>
          <SearchableGearDropdown
            label="Guitar"
            placeholder="Search guitars..."
            endpoint="/api/equipment/search?type=guitar&instrumentType=guitar"
            selectedItems={profile.guitar ? [toSearchItem(profile.guitar)] : []}
            onSelect={(item) => setSingleSelection("guitar", "guitar", item)}
            requestType="Guitar"
          />
          <GearChips items={profile.guitar ? [profile.guitar] : []} onRemove={() => removeSingleSelection("guitar")} emptyLabel="No guitar selected" />
        </div>

        <div>
          <SearchableGearDropdown
            label="Amp"
            placeholder="Search amps..."
            endpoint="/api/equipment/search?type=amp&instrumentType=guitar"
            selectedItems={profile.amp ? [toSearchItem(profile.amp)] : []}
            onSelect={(item) => setSingleSelection("amp", "amp", item)}
            requestType="Guitar Amp"
          />
          <GearChips items={profile.amp ? [profile.amp] : []} onRemove={() => removeSingleSelection("amp")} emptyLabel="No amp selected" />
        </div>

        <div>
          <SearchableGearDropdown
            label="Pedals"
            placeholder="Search pedals..."
            endpoint="/api/equipment/search?type=pedal"
            selectedItems={profile.pedals.map(toSearchItem)}
            onSelect={addPedal}
            requestType="Pedal"
          />
          <GearChips items={profile.pedals} onRemove={removePedal} emptyLabel="No pedals selected" />
        </div>

        <div>
          <SearchableGearDropdown
            label="MultiFX"
            placeholder="Search multi-fx..."
            endpoint="/api/equipment/search?type=multifx"
            selectedItems={profile.multifx ? [toSearchItem(profile.multifx)] : []}
            onSelect={(item) => setSingleSelection("multifx", "multifx", item)}
            requestType="Multi FX Unit"
          />
          <GearChips items={profile.multifx ? [profile.multifx] : []} onRemove={() => removeSingleSelection("multifx")} emptyLabel="No MultiFX selected" />
        </div>
      </div>
    </section>
  );
}

function toSelection(category: GearSelectionCategory, item: GearSearchItem): GearSelectionMetadata {
  return {
    model_id: item.modelId,
    brand_name: item.brandName,
    model_name: item.modelName,
    category,
    model_category: item.category,
    pickup_configuration: item.pickupConfiguration,
    amp_type: item.ampType,
    pedal_type: item.pedalType
  };
}

function toSearchItem(item: GearSelectionMetadata): GearSearchItem {
  return {
    modelId: item.model_id,
    brandName: item.brand_name,
    modelName: item.model_name,
    name: `${item.brand_name} ${item.model_name}`,
    category: item.model_category,
    tags: [],
    pickupConfiguration: item.pickup_configuration,
    ampType: item.amp_type,
    pedalType: item.pedal_type
  };
}

function GearChips({
  items,
  onRemove,
  emptyLabel
}: {
  items: GearSelectionMetadata[];
  onRemove: (modelId: string) => void;
  emptyLabel: string;
}) {
  if (!items.length) {
    return <p className="mt-3 text-xs text-slate-500">{emptyLabel}</p>;
  }

  return (
    <div className="mt-3 flex flex-wrap gap-2">
      {items.map((item) => (
        <span key={item.model_id} className="inline-flex items-center gap-2 rounded-full border border-blue-100 bg-blue-50 px-3 py-1 text-xs font-semibold text-ink dark:border-slate-600 dark:bg-slate-800 dark:text-white">
          {item.brand_name} {item.model_name}
          <button
            type="button"
            className="rounded-full p-0.5 text-slate-500 transition hover:bg-white hover:text-ink dark:hover:bg-slate-700 dark:hover:text-white"
            onClick={() => onRemove(item.model_id)}
            aria-label={`Remove ${item.brand_name} ${item.model_name}`}
          >
            <X className="h-3 w-3" />
          </button>
        </span>
      ))}
    </div>
  );
}
