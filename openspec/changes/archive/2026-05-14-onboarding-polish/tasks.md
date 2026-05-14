# Tasks: Onboarding Polish

## Phase 1: Part B — Cleanup & Navigation Rewire

- [x] 1.1 Delete `preferences_screen.dart` + `preferences_screen_test.dart`
- [x] 1.2 Remove `PreferencesScreen` import and `/onboarding/preferences` `GoRoute` from `app_router.dart`; update router test
- [x] 1.3 (TDD) `age_screen.dart`: replace `context.go('/onboarding/preferences')` → `/onboarding/tutorial` in both try and catch branches; update `age_screen_test.dart` nav expectations
- [x] 1.4 (TDD) `ready_screen.dart`: remove `modoLabel`, `settings['modo']` read, and `_SummaryRow` for modo; update `ready_screen_test.dart` to assert "Modo:" absent, "Edad:" present

## Phase 2: Part A — WelcomeScreen Implementation

- [x] 2.1 (TDD) Rewrite `welcome_screen.dart` to `ConsumerStatefulWidget` + `TickerProviderStateMixin`; add dual `AnimationController`s (1200ms stagger + 8s bg loop), 4 `CurvedAnimation(Interval...)` for title/stats/CTA/how-to, and private `_AnimatedItem` (fade + slide-up 24px)
- [x] 2.2 Add `ShaderMask` two-tone DESEA logo (hot pink `#ff40ff` → white gradient, stop 0.35), color-shifting background (`ColorTween` `0xFF0D0010` ↔ `0xFF1A0020`), and staggered entrance for all 4 animation groups
- [x] 2.3 Add premium fuchsia CTA "Comenzar" (full-width Material elevation 8, glow BoxShadow, 16px radius, navigates `/onboarding/age`) + outline "¿Cómo se juega?" button with `_showHowToPlay` modal bottom sheet (existing `GestureItem` + `AppStrings`)
- [x] 2.4 Write `welcome_screen_test.dart`: ShaderMask renders, stagger at 0ms/600ms/1200ms, CTA navigates, how-to-play sheet shows, controllers dispose — use `tester.pump(Duration)` never `pumpAndSettle`

## Summary

| Phase | Tasks | Focus |
|-------|-------|-------|
| Phase 1 | 4 | Part B: delete files, rewire navigation, strip modo from ReadyScreen |
| Phase 2 | 4 | Part A: WelcomeScreen rewrite with animations, ShaderMask, premium CTA, tests |
| Total | 8 | |

### Implementation Order

Phase 1 (Part B) first — deletions and navigation rewire have zero risk and remove dependencies. Phase 2 (Part A) then — the WelcomeScreen is purely presentational with no data dependencies, making it safe to implement last while anchoring the visual polish.

### Dependencies

None cross-phase. Each task within a phase is ordered by dependency: file deletion before route cleanup, route cleanup before navigation target changes, navigation before ReadyScreen modo removal (no strict dependency, but logical), AnimationController setup before visual elements, visual elements before tests.

### Next Step

Ready for implementation (sdd-apply).
