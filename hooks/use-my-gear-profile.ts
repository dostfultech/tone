"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import {
  cacheMyGearProfile,
  createEmptyMyGearProfile,
  normalizeMyGearProfile,
  MY_GEAR_PROFILE_UPDATED_EVENT,
  type GearSearchItem,
  type GearSelectionCategory,
  type GearSelectionMetadata,
  type MyGearProfile
} from "@/lib/my-gear";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

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

export function toSearchItem(item: GearSelectionMetadata): GearSearchItem {
  return {
    modelId: item.model_id,
    brandName: item.brand_name,
    modelName: item.model_name,
    name: `${item.brand_name} ${item.model_name}`,
    category: item.model_category,
    tags: [],
    pickupConfiguration: item.pickup_configuration,
    ampType: item.amp_type,
    pedalType: item.pedal_type,
    priceLow: null,
    priceHigh: null,
    usedByArtists: [],
    description: ""
  };
}

export function useMyGearProfile() {
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
        if (active) setLoading(false);
        return;
      }

      const {
        data: { user }
      } = await supabase.auth.getUser();

      if (!active) return;

      if (!user) {
        setLoading(false);
        return;
      }

      setUserId(user.id);

      const { data } = await supabase.from("profiles").select("my_gear_profile").eq("id", user.id).maybeSingle();
      if (!active) return;

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
    if (loading) return;
    cacheMyGearProfile(profile);
  }, [loading, profile]);

  useEffect(() => {
    if (!supabase || !userId || loading) return;

    const serialized = JSON.stringify(profile);
    if (serialized === lastSavedRef.current) return;

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

  useEffect(() => {
    function handleExternalUpdate(event: Event) {
      const detail = (event as CustomEvent).detail;
      if (detail) {
        setProfile(normalizeMyGearProfile(detail));
      }
    }

    window.addEventListener(MY_GEAR_PROFILE_UPDATED_EVENT, handleExternalUpdate);
    return () => window.removeEventListener(MY_GEAR_PROFILE_UPDATED_EVENT, handleExternalUpdate);
  }, []);

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
      if (current.pedals.some((p) => p.model_id === selection.model_id)) return current;
      return { ...current, pedals: [...current.pedals, selection], updated_at: new Date().toISOString() };
    });
  }

  function removeSingleSelection(key: "guitar" | "amp" | "multifx") {
    setProfile((current) => ({ ...current, [key]: null, updated_at: new Date().toISOString() }));
  }

  function removePedal(modelId: string) {
    setProfile((current) => ({
      ...current,
      pedals: current.pedals.filter((p) => p.model_id !== modelId),
      updated_at: new Date().toISOString()
    }));
  }

  return {
    profile,
    loading,
    saving,
    status,
    userId,
    setSingleSelection,
    addPedal,
    removeSingleSelection,
    removePedal
  };
}
