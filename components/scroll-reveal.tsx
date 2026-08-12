"use client";

import { useEffect } from "react";

/**
 * Reveal-on-scroll island. Elements tagged `.reveal` start lowered + transparent
 * (gated behind the `reveal-on` class this adds, so no-JS visitors and crawlers see
 * everything) and rise into place as they scroll into view.
 *
 * Uses a rAF-throttled scroll/resize check rather than IntersectionObserver so it
 * works in every environment (some embedded/headless browsers never fire IO), and
 * tears itself down once every element has been revealed.
 */
export function ScrollReveal() {
  useEffect(() => {
    const els = Array.from(document.querySelectorAll<HTMLElement>(".reveal"));
    if (!els.length) return;

    document.documentElement.classList.add("reveal-on");

    const reduce = window.matchMedia?.("(prefers-reduced-motion: reduce)").matches;
    if (reduce) {
      els.forEach((el) => el.classList.add("is-visible"));
      return;
    }

    const pending = new Set(els);
    let ticking = false;

    const teardown = () => {
      window.removeEventListener("scroll", onScroll);
      window.removeEventListener("resize", onScroll);
    };

    const reveal = () => {
      ticking = false;
      const viewport = window.innerHeight || document.documentElement.clientHeight || 0;
      for (const el of Array.from(pending)) {
        // Reveal once the element's top crosses into the lower ~90% of the viewport.
        if (el.getBoundingClientRect().top < viewport * 0.9) {
          el.classList.add("is-visible");
          pending.delete(el);
        }
      }
      if (pending.size === 0) teardown();
    };

    const onScroll = () => {
      if (!ticking) {
        ticking = true;
        window.requestAnimationFrame(reveal);
      }
    };

    window.addEventListener("scroll", onScroll, { passive: true });
    window.addEventListener("resize", onScroll, { passive: true });
    reveal(); // reveal whatever is already in view on load

    return teardown;
  }, []);

  return null;
}
