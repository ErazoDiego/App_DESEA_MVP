# Proposal: GameHub Screen — Immersive Gaming Home

## Intent

Transform `GameHubScreen` from a flat Material ListTile list into an immersive gaming home screen with hero section, per-mode identity cards, and library section with live counts. Must feel like a gaming console dashboard, not a settings menu.

## Scope

### In Scope
- 280px hero section with "DESEA" fuchsia glow title, subtitle, gradient CTA
- Two mode cards (Sesión / Libre) with per-mode gradient, glow, icon, title, description
- Library section with two cards showing live collection counts from providers
- Microinteractions: scale animation (0.96) on tap, AnimatedContainer transitions
- Add `azul` token to `GamingColorTokens`
- Add 3 new strings to `AppStrings`
- Add 5 new tests (8 total) — all existing 3 tests pass unchanged

### Out of Scope
- Route changes, new screens, new providers
- Sound effects, haptic feedback
- Animation framework overhaul
- Changes to data layer or any other screen

## Capabilities

### Modified Capabilities
- `game-hub`: GameHubScreen UI completely redesigned. Navigation targets, providers, and data flow unchanged.

## Approach

Complete rewrite of `GameHubScreen` (ConsumerWidget, 105→~419 LoC). Four new private widgets decompose responsibility:

| Widget | File | Role |
|--------|------|------|
| `_HeroSection` | `game_hub_screen.dart` | 280px hero with title, subtitle, gradient CTA |
| `_SectionHeader` | `game_hub_screen.dart` | Styled section headers |
| `_GameModeCard` | `game_hub_screen.dart` | Per-mode identity card with AnimatedScale |
| `_LibraryCard` | `game_hub_screen.dart` | Library card with consumer count + AnimatedScale |

Microinteractions use local `StatefulWidget` setState (not Riverpod). Counts read reactively via `ref.watch(provider)`.

## Visual Design

| Element | Color / Style |
|---------|---------------|
| Hero gradient | FuchsiaAccent → AppColors.background |
| Glow circle | Fuchsia, 200x200, blur 80 |
| Sesión card | Violet gradient + violet glow |
| Libre card | Orange gradient + orange glow |
| Guardadas card | Azul (#2563EB) |
| Mis Cartas card | FuchsiaAccent |
| Scale animation | 0.96 within 120ms, return 120ms |
| Container transitions | 300ms duration |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Existing 3 tests break | Low | Map all string references carefully, verify before commit |
| Scroll performance with animations | Low | RepaintBoundary wraps each card, SingleChildScrollView |
| Hero CTA text duplicates existing string | Low | New string `gameHubCtaSesion` for semantic independence |

## Success Criteria

- [ ] All 3 existing tests pass unchanged
- [ ] Hero section renders title, subtitle, CTA
- [ ] Mode cards render with correct identity (gradient, glow, icon, text)
- [ ] Library cards show live counts from providers
- [ ] Microinteractions animate on press
- [ ] All routes navigate correctly
