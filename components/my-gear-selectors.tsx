"use client";

import { Plus, Loader2, X } from "lucide-react";
import { PedalSelectorModal } from "@/components/pedal-selector-modal";
import { SearchableGearDropdown } from "@/components/searchable-gear-dropdown";
import { useMyGearProfile, toSearchItem } from "@/hooks/use-my-gear-profile";
import type { GearSelectionMetadata } from "@/lib/my-gear";
import { useState } from "react";

type MyGearSelectorsProps = {
  profile?: ReturnType<typeof useMyGearProfile>["profile"];
  loading?: boolean;
  saving?: boolean;
  status?: string;
  userId?: string | null;
  setSingleSelection?: ReturnType<typeof useMyGearProfile>["setSingleSelection"];
  addPedal?: ReturnType<typeof useMyGearProfile>["addPedal"];
  removeSingleSelection?: ReturnType<typeof useMyGearProfile>["removeSingleSelection"];
  removePedal?: ReturnType<typeof useMyGearProfile>["removePedal"];
};

export function MyGearSelectors(props: MyGearSelectorsProps) {
  const ownHook = useMyGearProfile();
  const profile = props.profile ?? ownHook.profile;
  const loading = props.loading ?? ownHook.loading;
  const saving = props.saving ?? ownHook.saving;
  const status = props.status ?? ownHook.status;
  const userId = props.userId ?? ownHook.userId;
  const setSingleSelection = props.setSingleSelection ?? ownHook.setSingleSelection;
  const addPedal = props.addPedal ?? ownHook.addPedal;
  const removeSingleSelection = props.removeSingleSelection ?? ownHook.removeSingleSelection;
  const removePedal = props.removePedal ?? ownHook.removePedal;

  const [pedalModalOpen, setPedalModalOpen] = useState(false);

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
          <label className="label">Pedals</label>
          <button
            type="button"
            onClick={() => setPedalModalOpen(true)}
            className="mt-2 flex min-h-12 w-full items-center justify-center gap-2 rounded-xl border border-dashed border-slate-300 bg-white px-4 text-sm font-semibold text-ocean shadow-sm transition hover:border-ocean/50 hover:bg-ocean/5 dark:border-slate-600 dark:bg-slate-900 dark:text-ocean dark:hover:border-ocean/50"
          >
            <Plus className="h-4 w-4" />
            Add Pedal
          </button>
          <GearChips items={profile.pedals} onRemove={removePedal} emptyLabel="No pedals selected" />
          <PedalSelectorModal
            open={pedalModalOpen}
            onClose={() => setPedalModalOpen(false)}
            onSelect={addPedal}
            selectedPedals={profile.pedals.map(toSearchItem)}
          />
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
