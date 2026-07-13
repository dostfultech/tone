"use client";

import { useEffect, useRef } from "react";
import { usePathname, useSearchParams } from "next/navigation";
import { trackPageView, trackUiAction } from "@/lib/analytics";

const interactiveSelector = "a,button,input,select,textarea,[role='button'],[data-track-event]";

export function AppEventTracker() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const lastTrackedPathRef = useRef<string>("");

  useEffect(() => {
    if (!pathname) {
      return;
    }

    const query = searchParams.toString();
    const path = query ? `${pathname}?${query}` : pathname;
    if (lastTrackedPathRef.current === path) {
      return;
    }

    lastTrackedPathRef.current = path;
    trackPageView(path);
  }, [pathname, searchParams]);

  useEffect(() => {
    function handleClick(event: MouseEvent) {
      const element = resolveInteractiveElement(event.target);
      if (!element) {
        return;
      }

      if (element instanceof HTMLInputElement && shouldSkipInputType(element.type)) {
        return;
      }

      trackUiAction("click", {
        element: describeElement(element),
        metadata: {
          tag: element.tagName.toLowerCase(),
          href: element instanceof HTMLAnchorElement ? element.getAttribute("href") || undefined : undefined,
          disabled: element instanceof HTMLButtonElement || element instanceof HTMLInputElement
            ? element.disabled
            : undefined
        }
      });
    }

    function handleSubmit(event: SubmitEvent) {
      if (!(event.target instanceof HTMLFormElement)) {
        return;
      }

      const form = event.target;
      trackUiAction("form_submit", {
        element: describeForm(form),
        metadata: {
          method: (form.method || "get").toLowerCase(),
          action: form.getAttribute("action") || undefined,
          formId: form.id || undefined
        }
      });
    }

    function handleChange(event: Event) {
      const field = event.target;
      if (!isTrackableField(field)) {
        return;
      }

      if (field instanceof HTMLInputElement && shouldSkipInputType(field.type)) {
        return;
      }

      trackUiAction("field_change", {
        element: describeField(field),
        metadata: {
          fieldType: resolveFieldType(field),
          fieldName: field.getAttribute("name") || undefined,
          checked: field instanceof HTMLInputElement && (field.type === "checkbox" || field.type === "radio")
            ? field.checked
            : undefined
        }
      });
    }

    document.addEventListener("click", handleClick, true);
    document.addEventListener("submit", handleSubmit, true);
    document.addEventListener("change", handleChange, true);

    return () => {
      document.removeEventListener("click", handleClick, true);
      document.removeEventListener("submit", handleSubmit, true);
      document.removeEventListener("change", handleChange, true);
    };
  }, []);

  return null;
}

function resolveInteractiveElement(target: EventTarget | null) {
  if (!(target instanceof Element)) {
    return null;
  }

  return target.closest(interactiveSelector);
}

function isTrackableField(target: EventTarget | null): target is HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement {
  return target instanceof HTMLInputElement || target instanceof HTMLSelectElement || target instanceof HTMLTextAreaElement;
}

function shouldSkipInputType(type: string) {
  const lowered = type.toLowerCase();
  return lowered === "password" || lowered === "hidden";
}

function describeElement(element: Element) {
  const tag = element.tagName.toLowerCase();
  const id = element.getAttribute("id");
  const name = element.getAttribute("name");
  const role = element.getAttribute("role");
  const dataTrackEvent = element.getAttribute("data-track-event");
  const label = readElementLabel(element);
  const descriptor = [
    tag,
    id ? `#${id.slice(0, 40)}` : null,
    name ? `[name=${name.slice(0, 40)}]` : null,
    role ? `[role=${role.slice(0, 40)}]` : null,
    dataTrackEvent ? `[data-track-event=${dataTrackEvent.slice(0, 40)}]` : null,
    label ? `"${label}"` : null
  ]
    .filter(Boolean)
    .join(" ");

  return descriptor.slice(0, 220);
}

function describeForm(form: HTMLFormElement) {
  const parts = [
    "form",
    form.id ? `#${form.id.slice(0, 40)}` : null,
    form.getAttribute("name") ? `[name=${String(form.getAttribute("name")).slice(0, 40)}]` : null,
    form.getAttribute("action") ? `[action=${String(form.getAttribute("action")).slice(0, 80)}]` : null
  ]
    .filter(Boolean)
    .join(" ");

  return parts.slice(0, 220);
}

function describeField(field: HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement) {
  const tag = field.tagName.toLowerCase();
  const id = field.getAttribute("id");
  const name = field.getAttribute("name");
  const type = resolveFieldType(field);

  return [
    tag,
    id ? `#${id.slice(0, 40)}` : null,
    name ? `[name=${name.slice(0, 40)}]` : null,
    `[type=${type.slice(0, 30)}]`
  ]
    .filter(Boolean)
    .join(" ")
    .slice(0, 220);
}

function resolveFieldType(field: HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement) {
  if (field instanceof HTMLInputElement) {
    return field.type || "text";
  }

  if (field instanceof HTMLSelectElement) {
    return "select";
  }

  return "textarea";
}

function readElementLabel(element: Element) {
  if (element instanceof HTMLInputElement || element instanceof HTMLSelectElement || element instanceof HTMLTextAreaElement) {
    return null;
  }

  const text = (element.textContent || "").replace(/\s+/g, " ").trim();
  if (!text) {
    return null;
  }

  return text.slice(0, 50);
}
