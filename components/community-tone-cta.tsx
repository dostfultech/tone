"use client";

import { useRouter } from "next/navigation";
import { brand } from "@/lib/brand";

const AUTO_ADAPT_KEY = `${brand.storagePrefix}_auto_adapt_from_community`;
const AUTO_ADAPT_PAYLOAD_KEY = `${brand.storagePrefix}_auto_adapt_payload`;

type CommunityToneCtaProps = {
  song: string;
  artist: string;
  part: string;
  partType: string;
  toneType: string;
  guitar: string;
  amp: string;
};

export function CommunityToneCta({ song, artist, part, partType, toneType, guitar, amp }: CommunityToneCtaProps) {
  const router = useRouter();

  function adaptTone() {
    sessionStorage.setItem(
      AUTO_ADAPT_PAYLOAD_KEY,
      JSON.stringify({
        song,
        artist,
        part,
        partType,
        toneType: toneType || "auto",
        guitar,
        amp
      })
    );
    sessionStorage.setItem(AUTO_ADAPT_KEY, "1");
    router.push("/app");
  }

  return (
    <button type="button" className="button-primary w-full justify-center" onClick={adaptTone}>
      Adapt This Tone
    </button>
  );
}
