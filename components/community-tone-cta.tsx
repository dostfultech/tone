"use client";

import { useRouter } from "next/navigation";
import { brand } from "@/lib/brand";

const AUTO_ADAPT_KEY = `${brand.storagePrefix}_auto_adapt_from_community`;

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
    localStorage.setItem("toneMatch_song", song);
    localStorage.setItem("toneMatch_artist", artist);
    localStorage.setItem("toneMatch_part", part);
    localStorage.setItem("toneMatch_partType", partType);
    localStorage.setItem("toneMatch_toneType", toneType || "auto");
    localStorage.setItem("toneMatch_guitar", guitar);
    localStorage.setItem("toneMatch_amp", amp);
    sessionStorage.setItem(AUTO_ADAPT_KEY, "1");
    router.push("/app");
  }

  return (
    <button type="button" className="button-primary w-full justify-center" onClick={adaptTone}>
      Adapt This Tone
    </button>
  );
}
