# UI Components

`SiteShell` owns public layout; `AppShell` owns the authenticated workspace. `ToneMatcher` owns research/gear/adaptation/save, while `GearView`, `MyGearSelectors`, and `SearchableGearDropdown` own the gear profile. `LibraryView`/`SavedToneDetail` own history, and `CommunityView`/`CommunityToneCta` own community browsing/reuse.

Auth/billing use `AuthForm`, `AuthCompleteClient`, `AccountView`, `Pricing`, and `CheckoutSuccessTracker`. Onboarding/access use `WelcomeView`, `OnboardingProgress`, `FreeAdaptationSummary`, and `ExpertUpgradeModal`. Public support uses Reviews, quick search, and ContactForm.

Search components consume `GearSearchItem`; My Gear persists schema-versioned JSON on `profiles`. Preserve loading, empty, error, quota, keyboard, and mobile states. Keep privileged data behind server routes and retain the established Tonefex visual language.
