# Delta for Onboarding Polish

## Purpose

Modernize the WelcomeScreen visual identity to match the redesigned HomeScreen (ShaderMask logo, staggered animations, premium CTA), and simplify the onboarding flow by removing the premature PreferencesScreen.

---

## ADDED Requirements

### R1: WelcomeScreen — Branded DESEA Logo with ShaderMask

The WelcomeScreen MUST render a ShaderMask two-tone "DESEA" logo using a hot pink (`#ff40ff`) to white linear gradient, matching the HomeScreen treatment.

- **GIVEN** WelcomeScreen is displayed
- **WHEN** the screen renders
- **THEN** the "DESEA" text SHALL use `ShaderMask` with `BlendMode.srcIn`
- **AND** the shader SHALL be a `LinearGradient` from hot pink to white with stop at 0.35

- **GIVEN** the ShaderMask is rendered
- **WHEN** the gradient is applied
- **THEN** the first letter "D" SHALL appear hot pink
- **AND** the remaining letters SHALL transition to white

### R2: WelcomeScreen — Staggered Entrance Animations

The WelcomeScreen MUST use a 1200ms `AnimationController` with 4 staggered `Interval` curves for entrance: title (0.0–0.4), stats (0.2–0.5), CTA (0.35–0.65), how-to (0.45–0.75).

- **GIVEN** WelcomeScreen is first displayed
- **WHEN** the screen mounts
- **THEN** all 4 animated groups start invisible (opacity 0, translated down 24px)
- **AND** the title group animates in first, finishing by 0.4 of 1200ms
- **AND** the CTA group starts animating at 0.35 and finishes by 0.65 of 1200ms

- **GIVEN** the animation controller is running
- **WHEN** the user navigates away before 1200ms
- **THEN** the controller SHALL be properly disposed via `dispose()`
- **AND** no "unmounted controller" error SHALL occur

### R3: WelcomeScreen — Color-Shifting Background

The WelcomeScreen MUST animate the background color in an 8-second loop with `repeat(reverse: true)` using a `ColorTween` between `#0D0010` and `#1A0020`.

- **GIVEN** WelcomeScreen is displayed
- **WHEN** the background controller starts
- **THEN** the background color SHALL smoothly shift between deep dark and slightly deeper violet every 8 seconds
- **AND** a second `AnimationController` SHALL manage this independently from the stagger controller

### R4: WelcomeScreen — Premium Fuchsia CTA Button

The WelcomeScreen MUST render a full-width fuchsia CTA button labeled "Comenzar" inside a `Material` widget with elevation 8, rounded 16px border radius, and a glow `BoxShadow` (fuchsiaAccent at 0.35 alpha, blur 16, offset Y 8).

- **GIVEN** the CTA button is rendered
- **WHEN** the user inspects it
- **THEN** it SHALL be full-width with `ElevatedButton` or `InkWell` inside `Material`
- **AND** its `BoxShadow` SHALL match fuchsiaAccent, 0.35 alpha, 16 blur, (0, 8) offset

### R5: WelcomeScreen — Outline "¿Cómo se juega?" Button

The WelcomeScreen MUST render a secondary outline button with fuchsia border, fuchsia icon + text for "¿Cómo se juega?".

- **GIVEN** WelcomeScreen is displayed
- **WHEN** the user scrolls to the secondary button
- **THEN** a button with fuchsia border, `Icons.help_outline`, and text "¿Cómo se juega?" SHALL be visible

### R6: WelcomeScreen — How-to-Play Dialog

Tapping the "¿Cómo se juega?" button MUST show a modal bottom sheet listing gestures (swipe, bookmark, comodín) and mode explanation.

- **GIVEN** the "¿Cómo se juega?" button is visible
- **WHEN** the user taps it
- **THEN** a modal bottom sheet SHALL appear with gesture items and mode explanation
- **WHEN** the user taps outside the sheet or dismisses it
- **THEN** the sheet SHALL close and the WelcomeScreen SHALL remain visible

### R7: WelcomeScreen — AnimatedItem Helper

The WelcomeScreen MUST define a private `_AnimatedItem` widget (fade + slide-up) identical in behavior to HomeScreen's `_AnimatedItem`.

- **GIVEN** `_AnimatedItem` wraps any child widget
- **WHEN** the parent animation value is 0.0
- **THEN** the child SHALL have opacity 0 and be translated 24px down
- **WHEN** the parent animation value reaches 1.0
- **THEN** the child SHALL have opacity 1 and translation 0

### R8: WelcomeScreen — Navigation to AgeScreen

The CTA button MUST navigate to `/onboarding/age` on tap.

- **GIVEN** the CTA "Comenzar" button is enabled
- **WHEN** the user taps it
- **THEN** the app navigates to `/onboarding/age`

---

## MODIFIED Requirements

### R9: AgeScreen — Navigation Target Change

AgeScreen's confirm button MUST navigate to `/onboarding/tutorial` instead of `/onboarding/preferences` after saving the profile.
(Previously: navigated to `/onboarding/preferences`)

#### Scenario: Navigation to tutorial

- **GIVEN** the user is on AgeScreen with age ≥ 18
- **WHEN** the user taps "Confirmar edad"
- **THEN** the app navigates to `/onboarding/tutorial`

#### Scenario: Catch branch also navigates to tutorial

- **GIVEN** `getPerfil()` throws an exception
- **WHEN** the catch branch creates a new Perfil and saves it
- **THEN** the app navigates to `/onboarding/tutorial`

### R10: ReadyScreen — Remove Modo Summary Row

ReadyScreen MUST NOT read `perfil.settings['modo']` or display a `_SummaryRow` for the game mode. Only the edad row SHALL appear.
(Previously: displayed both edad and modo summary rows)

#### Scenario: Only edad summary visible

- **GIVEN** ReadyScreen is displayed with a valid Perfil
- **THEN** the text "Edad:" SHALL be present
- **AND** the text "Modo:" SHALL NOT be present

#### Scenario: No modo-related variables remain

- **GIVEN** the ReadyScreen source code
- **THEN** it MUST NOT reference `perfil.settings['modo']` or any `modoLabel` variable

---

## REMOVED Requirements

### R11: PreferencesScreen — Full Removal

The PreferencesScreen file and its test file MUST be completely deleted from the project.

- **GIVEN** the project source tree
- **THEN** `lib/presentation/screens/onboarding/preferences_screen.dart` SHALL NOT exist
- **AND** `test/presentation/screens/onboarding/preferences_screen_test.dart` SHALL NOT exist

### R12: Router — Preferences Route Removal

The GoRouter configuration MUST NOT contain the `/onboarding/preferences` route or the PreferencesScreen import.

- **GIVEN** `lib/presentation/routes/app_router.dart`
- **THEN** the import of `preferences_screen.dart` SHALL be removed
- **AND** the `GoRoute(path: '/onboarding/preferences', ...)` SHALL be removed
- **AND** navigating to `/onboarding/preferences` SHALL fall through to the redirect logic (no matching route)

---

## Non-Functional Requirements

| ID | Requirement | Strength |
|---|---|---|
| NFR1 | WelcomeScreen MUST use `ConsumerStatefulWidget` + `TickerProviderStateMixin` | MUST |
| NFR2 | Both `AnimationController` instances MUST be disposed in `dispose()` | MUST |
| NFR3 | Tests MUST use `tester.pump(Duration)` instead of `pumpAndSettle()` for screens with looping animations | MUST |
| NFR4 | All existing AppStrings MUST remain unchanged | MUST |
