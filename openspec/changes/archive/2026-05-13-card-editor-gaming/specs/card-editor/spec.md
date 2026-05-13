# Card Editor Specification

## Purpose

Replace the standard `CardFormWidget` with an immersive gaming-themed card editor featuring live preview, visual selectors, and dark aesthetic with fuchsia/violet accents. Must work in create mode (embedded in LibreScreen IndexedStack) and edit mode (standalone route).

## Requirements

### R1: Gaming Layout with Live Preview

The editor MUST display a live card preview at the top that updates in real-time as the user fills fields. The form fields MUST appear below the preview with translucent backgrounds and neon glow on focus. The aesthetic MUST use `AppColors` dark palette (background `#07000F`, surface `#1A1A2E`, fuchsia accent `#A21CAF`).

#### Scenario: Fields render below preview in create mode
- GIVEN the user opens the editor in create mode
- WHEN the widget renders
- THEN a live card preview is visible at the top
- AND all input fields are visible below the preview
- AND the background uses the dark gaming palette

#### Scenario: Preview reflects initial empty state
- GIVEN the editor renders with no existing card
- WHEN no fields have been filled
- THEN the preview shows placeholder text and default category/level values

### R2: Category Selector — Visual Chips

The category selector MUST render as horizontal tappable chips with icons and labels. Each chip MUST change the preview accent color on selection. Four categories: 💬 Verdad, 🔥 Reto, ❤️ Deseo, ✨ Sin Límites. Only one chip MAY be selected at a time.

#### Scenario: Category chip selection changes preview
- GIVEN the editor is open
- WHEN the user taps the "🔥 Reto" chip
- THEN the chip visually activates (filled/highlighted state)
- AND the live preview updates its accent color to match the Reto palette
- AND the previously selected chip (if any) deactivates

#### Scenario: Category defaults to unselected in create mode
- GIVEN the editor is in create mode
- WHEN the widget renders
- THEN no category chip is pre-selected

### R3: Level Selector — Colored Pills

The level selector MUST render as three colored pills: 🟢 Suave, 🟠 Picante, 🔴 Intenso. Exactly one pill MUST be selected at all times. The preview MUST show the level badge with the corresponding color.

#### Scenario: Level pill selection
- GIVEN the editor is open
- WHEN the user taps "🔴 Intenso"
- THEN the Intenso pill activates
- AND the previously selected pill deactivates
- AND the preview shows the Intenso level badge

#### Scenario: Default level in create mode
- GIVEN the editor is in create mode
- WHEN the widget renders
- THEN "🟢 Suave" is pre-selected

### R4: Time Selector — Slider with Presets

The time selector MUST provide a slider (range 5–120 seconds) AND three preset buttons: 15s, 30s, 60s. Tapping a preset MUST update the slider position. Dragging the slider MUST update the selected time. The preview MUST display the selected time.

#### Scenario: Preset button sets time
- GIVEN the editor is open
- WHEN the user taps "30s"
- THEN the slider moves to the 30-second position
- AND the preview shows "30s"

#### Scenario: Slider drag updates time
- GIVEN the editor is open
- WHEN the user drags the slider to 45 seconds
- THEN the selected time displays as 45s
- AND no preset button is highlighted

### R5: Texto Input — Gaming Style

The texto input MUST have a translucent background (`surface` with opacity), glow border on focus using `fuchsiaAccent`, and support 1–3 lines of text. It MUST validate that text is non-empty on save. The preview MUST show the entered text in real-time.

#### Scenario: Text input updates preview
- GIVEN the editor is open
- WHEN the user types "Bailá como nunca"
- THEN the preview displays "Bailá como nunca"
- AND the input has a glow border when focused

#### Scenario: Empty text shows validation error
- GIVEN the editor is open
- WHEN the user taps save without entering text
- THEN a validation error message appears below the text input
- AND the save action does not proceed

### R6: Premium CTA Button

The CTA button MUST use a gradient background (fuchsia-to-violet) with glow effect. It MUST have three visual states: enabled (gradient + glow), saving (CircularProgressIndicator), and disabled (greyed out). Text MUST read "Guardar carta" or "Actualizar carta" depending on mode.

#### Scenario: Save button shows loading state
- GIVEN the editor has valid fields
- WHEN the user taps save
- THEN the button shows a CircularProgressIndicator
- AND the button is disabled during save

#### Scenario: Success state after save
- GIVEN the save completes successfully
- WHEN the operation finishes
- THEN `onSaved` callback is invoked
- AND the button re-enables (or navigates away per parent)

### R7: Dual Mode — Create and Edit

The editor MUST detect whether it receives an `existingCard` parameter. If `null`, it operates in create mode (empty fields, generates new ID on save). If provided, it pre-populates all fields and updates the same card on save.

#### Scenario: Create mode — empty form
- GIVEN no existingCard is provided
- WHEN the editor renders
- THEN all fields are empty (except default level Suave)
- THEN the save generates a new ID with format `pers_{timestamp}`

#### Scenario: Edit mode — pre-populated fields
- GIVEN an existingCard with texto "Hola", categoria "reto", nivel "intenso", tiempo 30s
- WHEN the editor renders
- THEN the preview shows "Hola"
- AND the "🔥 Reto" chip is selected
- AND the "🔴 Intenso" pill is selected
- AND the slider shows 30s

#### Scenario: Edit mode — modify and save
- GIVEN the editor is in edit mode with pre-populated data
- WHEN the user changes texto to "Actualizado" and taps save
- THEN the existing card (same ID) is updated in Hive
- AND `onSaved` is called

### R8: Sub-widget Structure

The editor MUST be composed of exactly 6 sub-widgets under `lib/presentation/widgets/card_editor/`:
- `card_preview_widget.dart` — live preview
- `category_selector_widget.dart` — visual chips
- `level_selector_widget.dart` — colored pills
- `time_selector_widget.dart` — slider + presets
- `texto_field_widget.dart` — gaming text input
- `cta_button_widget.dart` — premium gradient CTA

The parent widget `CardFormWidget` MUST be refactored to compose these sub-widgets while preserving its public API (`existingCard`, `onSaved`).

#### Scenario: Public API preserved
- GIVEN any code that currently uses `CardFormWidget(existingCard: x, onSaved: y)`
- WHEN the refactor completes
- THEN the constructor signature remains unchanged
- AND all existing usage sites compile without modification

## Non-Functional Requirements

| ID | Requirement | Criterion |
|----|------------|-----------|
| N1 | Performance | Editor renders under 200ms on a mid-range device |
| N2 | Responsiveness | All interactions (chip tap, slider drag, text input) reflect in preview within 16ms (60fps) |
| N3 | Accessibility | All chips and pills have min touch target 48x48dp |
| N4 | Testability | Each sub-widget MUST be independently widget-testable |
| N5 | TDD compliance | All scenarios above MUST have corresponding tests before implementation |

## Test Plan

### New Tests (replacing old test file)

| ID | Scenario | Replaces |
|----|----------|----------|
| T1 | Create mode renders preview + 6 sub-widgets | 5.1 (old) |
| T2 | Texto validation shows error on empty | 5.2 (preserved) |
| T3 | Save new card in create mode calls onSaved | 5.3 (adapted) |
| T4 | Category chip selection updates state | 5.4 (replaces dropdown) |
| T5 | Level pill selection (default Suave) | new |
| T6 | Time preset 30s sets slider to 30 | new |
| T7 | Texto input updates preview text | new |
| T8 | Edit mode pre-populates all fields | 5.5 (adapted) |
| T9 | Edit mode updates existing card on save | 5.6 (preserved) |
| T10 | CTA button shows loading state during save | new |
| T11 | Preview accent color changes with category | new |
| T12 | Slider drag updates displayed time | new |
| T13 | Public API unchanged after refactor | new (compile test) |

### Removed Test Scenarios
- 5.4 (categoria dropdown selection) — replaced by chip selector
- Nivel dropdown & Tiempo text field tests — replaced by pill/slider tests

## File Structure

```
lib/presentation/widgets/
├── card_editor/
│   ├── card_editor_widget.dart        ← renamed from card_form_widget.dart (composes sub-widgets)
│   ├── card_preview_widget.dart       ← live preview
│   ├── category_selector_widget.dart  ← visual chips
│   ├── level_selector_widget.dart     ← colored pills
│   ├── time_selector_widget.dart      ← slider + presets
│   ├── texto_field_widget.dart        ← gaming input
│   └── cta_button_widget.dart         ← gradient CTA
└── card_form_widget.dart              ← DELETED or replaced by re-export
```
