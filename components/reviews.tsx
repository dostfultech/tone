"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
import { Star } from "lucide-react";
import { createSupabaseBrowserClient } from "@/lib/supabase/browser";

type Review = {
  id: string;
  rating: number;
  name?: string;
  display_name?: string;
  body: string;
};

const starterReviews: Review[] = [
  {
    id: "1",
    rating: 5,
    name: "Session player",
    body: "The translated settings gave me a usable starting point before rehearsal."
  },
  {
    id: "2",
    rating: 4,
    name: "Home studio guitarist",
    body: "The gear notes helped me stop chasing knobs and focus on the part."
  }
];

export function Reviews() {
  const [reviews, setReviews] = useState<Review[]>(starterReviews);
  const [rating, setRating] = useState(5);
  const [name, setName] = useState("");
  const [body, setBody] = useState("");
  const [message, setMessage] = useState("");

  useEffect(() => {
    async function loadReviews() {
      const supabase = createSupabaseBrowserClient();
      if (!supabase) {
        const stored = localStorage.getItem("fretpilot_reviews");
        if (stored) setReviews(JSON.parse(stored));
        return;
      }
      const { data } = await supabase.from("reviews").select("id, rating, display_name, body").eq("status", "approved").order("created_at", { ascending: false });
      if (data?.length) setReviews(data);
    }
    loadReviews();
  }, []);

  useEffect(() => {
    localStorage.setItem("fretpilot_reviews", JSON.stringify(reviews));
  }, [reviews]);

  const average = useMemo(() => {
    const total = reviews.reduce((acc, review) => acc + review.rating, 0);
    return reviews.length ? (total / reviews.length).toFixed(1) : "0.0";
  }, [reviews]);

  async function submitReview(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (body.trim().length < 10) {
      setMessage("Reviews need at least 10 characters.");
      return;
    }

    const next: Review = {
      id: crypto.randomUUID(),
      rating,
      name: name.trim() || "Anonymous guitarist",
      body: body.trim()
    };
    const supabase = createSupabaseBrowserClient();
    if (supabase) {
      const {
        data: { user }
      } = await supabase.auth.getUser();
      await supabase.from("reviews").insert({
        user_id: user?.id || null,
        rating,
        display_name: next.name,
        body: next.body,
        status: "pending"
      });
      setMessage("Review submitted for approval.");
    } else {
      setMessage("Review saved locally.");
    }
    setReviews([next, ...reviews]);
    setName("");
    setBody("");
    setRating(5);
  }

  return (
    <section id="reviews" className="section py-16 lg:py-20">
      <div className="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p className="text-sm font-bold uppercase tracking-[0.18em] text-ocean">Reviews</p>
          <h2 className="mt-2 text-3xl font-bold tracking-normal">Player feedback</h2>
          <p className="mt-2 max-w-2xl text-slate-600">Short notes from players using FretPilot as a practical starting point.</p>
        </div>
        <div className="compact-card flex w-fit items-center gap-3 p-4">
          <div className="text-3xl font-bold">{average}</div>
          <div>
            <div className="flex text-ocean">
              {Array.from({ length: 5 }).map((_, index) => (
                <Star key={index} className="h-4 w-4 fill-current" />
              ))}
            </div>
            <div className="text-xs text-neutral-500">{reviews.length} reviews</div>
          </div>
        </div>
      </div>

      <div className="grid items-start gap-6 lg:grid-cols-[minmax(0,1fr)_360px]">
        <div className="grid items-start gap-4 md:grid-cols-2">
          {reviews.map((review) => (
            <article key={review.id} className="compact-card h-auto p-6">
              <div className="mb-3 flex text-ocean">
                {Array.from({ length: review.rating }).map((_, index) => (
                  <Star key={index} className="h-4 w-4 fill-current" />
                ))}
              </div>
              <p className="text-sm leading-6 text-neutral-700">{review.body}</p>
              <p className="mt-4 text-sm font-semibold">{review.display_name || review.name}</p>
            </article>
          ))}
        </div>

        <form onSubmit={submitReview} className="compact-card p-6">
          <h3 className="text-lg font-bold">Leave a review</h3>
          <p className="mt-1 text-sm text-neutral-600">Share the song, gear, or result that worked for you.</p>
          <div className="mt-5 grid gap-4">
            <div>
              <label className="label" htmlFor="rating">
                Your rating
              </label>
              <select id="rating" className="field mt-1" value={rating} onChange={(event) => setRating(Number(event.target.value))}>
                <option value={5}>Excellent</option>
                <option value={4}>Good</option>
                <option value={3}>Okay</option>
                <option value={2}>Needs work</option>
              </select>
            </div>
            <div>
              <label className="label" htmlFor="review-name">
                Name
              </label>
              <input id="review-name" className="field mt-1" value={name} onChange={(event) => setName(event.target.value)} placeholder="Optional" />
            </div>
            <div>
              <label className="label" htmlFor="review-body">
                Your review
              </label>
              <textarea
                id="review-body"
                className="field mt-1 min-h-28 resize-y"
                value={body}
                maxLength={800}
                onChange={(event) => setBody(event.target.value)}
                placeholder="Minimum 10 characters"
              />
              <div className="mt-1 text-xs text-neutral-500">{body.length}/800</div>
            </div>
            {message ? <div className="text-sm text-ocean">{message}</div> : null}
            <button className="button-primary" type="submit">
              Submit review
            </button>
          </div>
        </form>
      </div>
    </section>
  );
}
