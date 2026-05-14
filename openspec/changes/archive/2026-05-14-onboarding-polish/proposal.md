# Proposal: Onboarding Polish

## Intent

WelcomeScreen looks basic compared to the redesigned HomeScreen — plain text logo, no animations, standard `ElevatedButton`. PreferencesScreen adds friction (choosing game mode during onboarding is premature). We need visual consistency at first contact and a leaner flow.

## Scope

### In Scope
- **Part A (WelcomeScreen)**: ShaderMask two-tone DESEA logo, staggered fade+slide-up entrance, premium fuchsia CTA with glow shadow, subtle color-shifting background
- **Part B (removal)**: Delete PreferencesScreen, remove `/onboarding/preferences` route, rewire AgeScreen → TutorialScreen, remove modo line from ReadyScreen
- Update all affected tests (age, ready, welcome); delete preferences_screen_test.dart

### Out of Scope
- Visual polish for AgeScreen, TutorialScreen, or ReadyScreen (future)
- Changes to HomeScreen, app_strings, or domain/data layer
- Refactoring `_AnimatedItem` into shared widget (duplicate in WelcomeScreen)

## Capabilities

### New Capabilities
- `onboarding/visual-welcome`: WelcomeScreen with branded visual treatment matching HomeScreen

### Modified Capabilities
- None — no existing onboarding spec; changes are cosmetic + flow simplification

## Approach

**Part A**: Convert WelcomeScreen to `ConsumerStatefulWidget` + `TickerProviderStateMixin`. Replicate HomeScreen's dual-controller pattern: one `AnimationController` for stagger (1200ms, 4 `Interval` curves), one for background shift (8s loop). `ShaderMask` with `_deseaShader` (hot pink → white gradient). Fuchsia CTA with glow `BoxShadow`.

**Part B**: Delete `preferences_screen.dart` + test. Remove import + route from `app_router.dart`. Change `context.go('/onboarding/preferences')` → `context.go('/onboarding/tutorial')` in `age_screen.dart`. Remove `_SummaryRow` for modo and its backing variables from `ready_screen.dart`.

## Affected Areas

| Area | Impact | What |
|------|--------|------|
| `lib/.../welcome_screen.dart` | Modified | ShaderMask, animations, premium CTA |
| `lib/.../preferences_screen.dart` | Removed | File deleted |
| `lib/.../age_screen.dart` | Modified | Route target → `/onboarding/tutorial` |
| `lib/.../ready_screen.dart` | Modified | Remove modo row + related code |
| `lib/.../routes/app_router.dart` | Modified | Remove pref import + route |
| `test/.../preferences_screen_test.dart` | Removed | File deleted |
| `test/.../age_screen_test.dart` | Modified | Nav expectations → tutorial |
| `test/.../ready_screen_test.dart` | Modified | Remove modo assertions |
| `test/.../welcome_screen_test.dart` | May update | Update if structure breaks |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Animation dispose bug | Low | Follow HomeScreen pattern; `pumpAndSettle` in tests |
| Missing route crash at runtime | Low | Delete route + imports atomically; test after each step |
| Loop animation breaks test `pumpAndSettle` | Med | Use `pump(Duration)` for WelcomeScreen tests |
| `settings['modo']` read elsewhere | Low | grep confirms only ready_screen reads it (being updated) |

## Rollback Plan

Single `git revert`. All changes are file-level — no migrations, no data schema changes. The WelcomeScreen polish is purely cosmetic. PreferencesScreen removal is safe because `settings['modo']` is only consumed in ready_screen (which is updated in the same change).

## Dependencies

None.

## Success Criteria

- [ ] WelcomeScreen shows ShaderMask DESEA logo, stagger entrance, premium fuchsia CTA with glow
- [ ] AgeScreen navigates to `/onboarding/tutorial` (not `/onboarding/preferences`)
- [ ] ReadyScreen no longer displays the modo summary row
- [ ] `/onboarding/preferences` returns 404/redirect (route removed)
- [ ] All 327+ tests pass (332 − 5 preference tests + updates)
- [ ] `flutter test` passes with zero failures
