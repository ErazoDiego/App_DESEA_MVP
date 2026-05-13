# GameHub Specification

## Purpose

The GameHub screen is the central gaming home where users choose play modes and access their card collection. Transforms the current flat Material ListTile list into an immersive, scrollable gaming experience with hero section, per-mode identity cards, and library section with live counts.

## ADDED Requirements

### R1: Immersive Hero Section

The system MUST render a ~280px hero section at the top of the GameHub screen featuring "DESEA" title with fuchsia glow, subtitle, and CTA button.

- **GIVEN** GameHub is displayed
- **WHEN** the user scrolls to the top of the screen
- **THEN** a hero section of ~280px height SHALL be visible
- **AND** it SHALL contain "DESEA" in headlineLarge, fuchsia, bold with glow effect
- **AND** it SHALL contain the subtitle "La noche empieza acá" in bodyLarge, onSurface color
- **AND** it SHALL contain a CTA button labeled "Empezar sesión" with violet→fuchsia gradient

- **GIVEN** the hero CTA button is visible
- **WHEN** the user taps it
- **THEN** the app navigates to `/game/sesion/default`

### R2: Mode Cards with Per-Mode Identity

The system MUST display two mode cards (Sesión and Libre) with per-mode gradient, glow, icon, title, and description below a section header.

- **GIVEN** GameHub is displayed
- **WHEN** the user scrolls past the hero section
- **THEN** a section header "Elegí cómo jugar" SHALL be visible

- **GIVEN** the mode section is visible
- **THEN** a Sesión card SHALL be visible with violet gradient, violet glow, Icons.auto_awesome, title "Sesión", and description "20 cartas con arco progresivo"

- **GIVEN** the mode section is visible
- **THEN** a Libre card SHALL be visible with orange gradient, orange glow, Icons.construction, title "Libre", and description "Armá tu propio mazo"

- **GIVEN** the Sesión card is visible
- **WHEN** the user taps it
- **THEN** the app navigates to `/game/sesion/default`

- **GIVEN** the Libre card is visible
- **WHEN** the user taps it
- **THEN** the app navigates to `/game/libre`

### R3: Library Section with Counts

The system MUST display a library section with two cards showing live collection counts from providers.

- **GIVEN** GameHub is displayed
- **WHEN** the user scrolls past the mode cards
- **THEN** a section header "Tu colección" SHALL be visible

- **GIVEN** `guardadasBoxProvider` has N items
- **WHEN** the library section is rendered
- **THEN** the "Cartas guardadas" card SHALL display "$N guardadas"

- **GIVEN** `personalizadasBoxProvider` has M items
- **WHEN** the library section is rendered
- **THEN** the "Mis cartas" card SHALL display "$M personalizadas"

- **GIVEN** `guardadasBoxProvider` is empty
- **WHEN** the library section is rendered
- **THEN** the card SHALL display "0 guardadas"

- **GIVEN** the "Cartas guardadas" card is visible
- **WHEN** the user taps it
- **THEN** the app navigates to `/game/guardadas`

- **GIVEN** the "Mis cartas" card is visible
- **WHEN** the user taps it
- **THEN** the app navigates to `/game/mis-cartas`

### R4: Microinteractions

Cards SHOULD apply scale animation on press and use AnimatedContainer for border/glow transitions.

- **GIVEN** any card is visible
- **WHEN** the user presses down on it
- **THEN** the card SHALL scale to 0.96 within 120ms
- **WHEN** the user releases the press
- **THEN** the card SHALL return to scale 1.0 within 120ms

- **GIVEN** any card is visible
- **WHEN** it transitions between states
- **THEN** AnimatedContainer SHALL handle border and glow changes at 300ms duration

### R5: Existing String Compatibility

The system MUST preserve all AppStrings referenced by the three existing tests.

| Finder Expression | Current Test | Must Remain Findable |
|---|---|---|
| `find.text(AppStrings.gameHubTitle)` | renders title and all mode cards | Yes |
| `find.text(AppStrings.modoSesion)` | renders title and all mode cards | Yes |
| `find.text(AppStrings.modoSesionDesc)` | renders title and all mode cards | Yes |
| `find.text(AppStrings.modoLibre)` | renders title and all mode cards | Yes |
| `find.text(AppStrings.libreCardDescription)` | renders title and all mode cards | Yes |
| `find.text(AppStrings.savedCardsHubTitle)` | renders title and all mode cards | Yes |
| `find.text('N guardadas')` | shows saved cards count badge | Yes |

### R6: Route Navigation

All cards MUST navigate to their expected routes (covered by R1.2, R2.4–R2.5, R3.5–R3.6).

### New Strings

The following AppStrings MUST be added:
- `gameHubColeccionSection = 'Tu colección'`
- `gameHubImmersionSubtitle = 'La noche empieza acá'`

The following strings MAY be added (or existing `iniciarSesion` / `startNight` MAY be reused):
- `gameHubCtaSesion = 'Empezar sesión'`

## Non-Functional Requirements

| ID | Requirement | Strength |
|---|---|---|
| NFR1 | Each mode/library card SHOULD be wrapped in RepaintBoundary for scroll performance | SHOULD |
| NFR2 | The screen MUST use AppColors.background, AppColors.surface, and AppColors.onSurface for dark-mode consistency | MUST |

## Test Plan

| ID | Scenario | Req | Type |
|---|---|---|---|
| T1 | Hero renders "DESEA", subtitle, and CTA | R1 | Happy path |
| T2 | Hero CTA navigates to /game/sesion/default | R1 | Happy path |
| T3 | Section header "Elegí cómo jugar" is visible | R2 | Happy path |
| T4 | Sesión card shows violet identity, icon, title, description | R2 | Happy path |
| T5 | Libre card shows orange identity, icon, title, description | R2 | Happy path |
| T6 | Sesión card navigates to /game/sesion/default | R2 | Happy path |
| T7 | Libre card navigates to /game/libre | R2 | Happy path |
| T8 | Section header "Tu colección" is visible | R3 | Happy path |
| T9 | Guardadas card shows count from provider | R3 | Happy path |
| T10 | Mis Cartas card shows count from provider | R3 | Happy path |
| T11 | Empty guardadas shows "0 guardadas" | R3 | Edge case |
| T12 | Guardadas card navigates to /game/guardadas | R3 | Happy path |
| T13 | Mis Cartas card navigates to /game/mis-cartas | R3 | Happy path |
| T14 | Scale animation on tap down → 0.96, release → 1.0 | R4 | Interaction |
| T15 | AnimatedContainer border/glow at 300ms | R4 | Interaction |
| T16 | Existing strings findable: gameHubTitle, modoSesion, modoSesionDesc, modoLibre, libreCardDescription, savedCardsHubTitle | R5 | Regression |
| T17 | All routes map correctly (6 cards × 5 routes) | R6 | Happy path |
