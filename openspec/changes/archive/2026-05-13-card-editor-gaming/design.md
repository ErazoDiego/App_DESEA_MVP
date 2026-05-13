# Design: Card Editor — Gaming Experience

## Technical Approach

Refactor `CardFormWidget` from monolithic Material form to a composable widget that delegates rendering to 6 sub-widgets under `lib/presentation/widgets/card_editor/`. The parent retains ownership of all state (`TextEditingController`s, selection values, save logic, validation) via `setState`. Sub-widgets are pure presentational — they receive values and callbacks, never manage state. This enables the live preview to rebuild naturally on every `setState` without prop-drilling complexity.

## Architecture Decisions

### AD-1: CardFormWidget stays as public API

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Move to `card_editor/card_editor_widget.dart` | Breaks all existing imports (`libre_screen.dart`, edit route). Forces migration on unused code. | ❌ Rejected |
| **Keep `card_form_widget.dart` + compose sub-widgets** | Zero import changes. `CardFormWidget(existingCard:, onSaved:)` unchanged. Sub-widgets hidden behind public API. | ✅ **Chosen** |

### AD-2: TimeSelector — slider + presets (per spec)

| Option | Tradeoff | Decision |
|--------|----------|----------|
| **Slider (5–120s) + 3 preset buttons (15s/30s/60s)** | One-tap presets for common values + fine-grained slider for custom. Matches spec R4. | ✅ **Chosen** |
| Preset chips only (no slider) | Less flexible, no custom values | ❌ Rejected |
| Custom text input | Higher validation cost, worse UX | ❌ Rejected |

### AD-3: State via setState (no Riverpod)

| Option | Tradeoff | Decision |
|--------|----------|----------|
| **setState in parent** | Simple, local. Preview is child (not sibling), rebuilds are instant. No provider boilerplate. | ✅ **Chosen** |
| Riverpod `StateProvider` family | Over-engineering — no other widget reads form state. Higher complexity, same result. | ❌ Rejected |

### AD-4: Preview updates immediately (no debounce)

| Option | Tradeoff | Decision |
|--------|----------|----------|
| **Immediate setState on every change** | Preview is lightweight (< 5 widgets, no images). 60fps achievable. 16ms reflect time (N2). | ✅ **Chosen** |
| Debounced (300ms) | Visual lag — preview feels sluggish. Unnecessary for simple text + colors. | ❌ Rejected |

## Data Flow

```
User tap/type
    │
    ▼
CardFormWidget (setState)
    │
    ├── _texto, _categoria, _nivel, _tiempoSegundos, _dirigida, _isSaving
    │
    ├──▶ CardPreviewWidget(texto, categoria, nivel, tiempoSegundos, dirigida)
    ├──▶ GamingTextField(controller, label, maxLines, validator)
    ├──▶ CategorySelector(selected: _categoria, onChanged: (v) → setState)
    ├──▶ LevelSelector(selected: _nivel, onChanged: (v) → setState)
    ├──▶ TimeSelector(seconds: _tiempoSegundos, onChanged: (v) → setState)
    ├──▶ GamingTextField(controller: _dirigidaController, label, singleLine)
    └──▶ GamingButton(label, isSaving, onPressed: _save)
```

Save flow (unchanged from current implementation):
```
_save() → validate → build CartaPersonalizada → box.put() → onSaved callback
```

## Widget Contracts

### CardPreviewWidget
```
props: { String texto, String? categoria, String nivel, int? tiempoSegundos, String? dirigida }
render: AspectRatio(0.68) → gradient card with: (top) category icon + color, 
        (center) texto, (bottom) tipo label + level dot + time badge
state: none (pure render)
```

### GamingTextField
```
props: { TextEditingController controller, String label, int maxLines, 
         FormFieldValidator<String>? validator, TextInputType? keyboardType }
style: surface @ 60% opacity bg, 1px border (white @ 10%), 
       focused: fuchsiaAccent glow border (3px, fuchsiaAccent @ 30% opacity)
```

### CategorySelector
```
props: { String? selected, ValueChanged<String?> onChanged }
chips: 4 items in a Wrap/Row
  - verdad   → icon: psychology   color: #059669 (emerald), label: "💬 Verdad"
  - reto     → icon: whatshot     color: #EA580C (orange),  label: "🔥 Reto"
  - deseo    → icon: favorite     color: #A21CAF (fuchsia), label: "❤️ Deseo"
  - sinLimites → icon: auto_awesome  color: #7C3AED (violet), label: "✨ Sin Límites"
selected: filled accent + glow shadow; unselected: surface @ 60% + border
```

### LevelSelector
```
props: { String selected, ValueChanged<String> onChanged }
pills: 3 items in a Row
  - suave    → color: #059669 (emerald), label: "🟢 Suave"
  - picante  → color: #EA580C (orange),  label: "🟠 Picante"
  - intenso  → color: #A21CAF (fuchsia), label: "🔴 Intenso"
selected: filled color + scale 1.05; unselected: surface @ 60% + border
```

### TimeSelector
```
props: { int? seconds, ValueChanged<int?> onChanged }
children: SliderTheme(5..120) + 3 preset OutlinedButtons ("15s", "30s", "60s")
behavior: preset tap → slider moves → onChanged(slider.value)
         slider drag → preset highlight clears → onChanged(new value)
default: null (no timer) when slider at min
```

### CtaButtonWidget
```
props: { String label, bool isLoading, VoidCallback? onPressed }
style: gradient(fuchsiaAccent → violet #7C3AED, diagonal, 45°), 
       borderRadius 16, glow shadow (fuchsiaAccent @ 35%, blur 16, offset 0,8)
       scale 0.95 on press (AnimatedScale, 120ms, easeOut)
states: enabled (gradient + glow) | loading (CPI, overlay) | disabled (grey, no glow)
```

## Layout / Spacing

| Section | Widget | Padding | Height |
|---------|--------|---------|--------|
| Preview | CardPreviewWidget | EdgeInsets symmetric h: 16, t: 8, b: 16 | ~200dp (aspect 0.68, ~60% width) |
| Instrucción | GamingTextField | EdgeInsets symmetric h: 16, b: 16 | maxLines: 3 |
| Categoría | CategorySelector | EdgeInsets symmetric h: 16, b: 16 | ~48dp (chip height) |
| Nivel | LevelSelector | EdgeInsets symmetric h: 16, b: 16 | ~48dp (pill height) |
| Configuración | TimeSelector + GamingTextField | EdgeInsets symmetric h: 16, b: 16 | ~120dp (slider + presets + field) |
| CTA | CtaButtonWidget | EdgeInsets symmetric h: 16, b: 32 | 52dp |

## Color / Design Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `inputBg` | `surface` (#1A1A2E) @ 60% opacity (via `withValues(alpha: 0.6)`) | Unselected chip, field bg |
| `inputBorder` | `Colors.white` @ 10% opacity | Unfocused field, unselected chip |
| `glow` | `fuchsiaAccent` (#A21CAF) @ 30% opacity | Focused field border, selected chip glow |
| `shadowGlow` | `fuchsiaAccent` (#A21CAF) @ 35% opacity, blur 16, y 8 | CTA button glow |
| `emerald` | #059669 | Verdad cat, Suave level |
| `orange` | #EA580C | Reto cat, Picante level |
| `fuchsia` | #A21CAF | Deseo cat, Intenso level |
| `violet` | #7C3AED | Sin Límites cat |

## Animation Specs

| Element | Property | Duration | Curve | Value |
|---------|----------|----------|-------|-------|
| CTA press | scale | 120ms | easeOut | 0.95 → 1.0 |
| Chip select | color + scale | 150ms | easeOut | 1.0 → 1.05 |
| Glow border | color + width | 200ms | easeInOut | via FocusNode/FocusColor |

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/presentation/widgets/card_editor/card_preview_widget.dart` | Create | Live card preview |
| `lib/presentation/widgets/card_editor/category_selector_widget.dart` | Create | Category chip selector |
| `lib/presentation/widgets/card_editor/level_selector_widget.dart` | Create | Level pill selector |
| `lib/presentation/widgets/card_editor/time_selector_widget.dart` | Create | Time slider + presets |
| `lib/presentation/widgets/card_editor/texto_field_widget.dart` | Create | Gaming text input |
| `lib/presentation/widgets/card_editor/cta_button_widget.dart` | Create | Premium gradient button |
| `lib/presentation/widgets/card_form_widget.dart` | Modify | Compose sub-widgets, keep public API |
| `test/presentation/widgets/card_form_widget_test.dart` | Rewrite | T1–T13 per spec test plan |

## Testing Strategy

| Layer | What | Approach |
|-------|------|----------|
| Widget | CardPreviewWidget | Renders placeholder text, updates on prop change, shows correct icon per category |
| Widget | GamingTextField | Shows label, glow on focus, calls validator, shows error text |
| Widget | CategorySelector | 4 chips visible, tap calls onChanged, selected chip highlighted |
| Widget | LevelSelector | 3 pills visible, default Suave selected, tap changes selection, scale anim |
| Widget | TimeSelector | Slider 5–120, presets 15/30/60, tap preset → slider moves, drag updates value |
| Widget | CtaButtonWidget | 3 states (enabled/loading/disabled), gradient visible, scale on press |
| Integration | CardFormWidget (create) | All 6 sub-widgets render, texto validates, save → box.put → onSaved |
| Integration | CardFormWidget (edit) | Pre-populates all fields, update → same ID → onSaved |
| Integration | Public API | Constructor unchanged, works in IndexedStack |

## Migration / Rollout

No migration required. `CardFormWidget` constructor unchanged. FreeScreen's `IndexedStack` continues working because the widget returns a `SingleChildScrollView` wrapping the same `Column` structure — only the internal children change.

## Open Questions

- [ ] Should GamingTextField use a shared `FocusNode` for glow animation, or is an `AnimatedContainer` sufficient?
- [ ] TimeSelector: when slider is at min (5), should `tiempoSegundos` be `null` (no timer) or `5`? Spec R4 is ambiguous.

## Spec Conflicts Resolved

| Spec provision | Design decision | Rationale |
|----------------|----------------|-----------|
| R4: "slider + presets" (spec) vs "chips + custom input" (user prompt) | Follow spec: slider + 3 presets | Spec is authoritative; slider gives fine-grained control |
| File location: `card_editor/card_editor_widget.dart` (spec) vs keeping `card_form_widget.dart` | Keep `card_form_widget.dart` | AD-1: zero import changes, public API preserved |
