import { redirect } from "next/navigation";
import { SavedToneDetail } from "@/components/saved-tone-detail";
import { getCurrentSession } from "@/lib/server-access";

type LibraryTonePageProps = {
  params: Promise<{ toneId: string }>;
};

export default async function LibraryTonePage({ params }: LibraryTonePageProps) {
  const { toneId } = await params;
  const { supabase, user } = await getCurrentSession();

  if (!user || !supabase) {
    redirect(`/login?redirect=${encodeURIComponent(`/library/${toneId}`)}`);
  }

  const { data } = await supabase
    .from("saved_tones")
    .select("id, song, artist, part, mode, notes, result")
    .eq("id", toneId)
    .maybeSingle();

  if (!data) {
    redirect("/library");
  }

  return (
    <SavedToneDetail
      song={data.song}
      artist={data.artist}
      part={data.part}
      mode={data.mode}
      notes={data.notes || null}
      result={(data.result || {}) as Record<string, unknown>}
    />
  );
}