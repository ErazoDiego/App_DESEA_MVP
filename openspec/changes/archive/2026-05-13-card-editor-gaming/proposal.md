# Proposal: Card Editor — Gaming Experience

## Intent

Redesign `CardFormWidget` from a standard Material form into an immersive gaming/card-creation experience. NO admin forms, NO CRUD feel — must feel like "creating a special game card" (Hearthstone/Marvel Snap inspiration). Backed by user request for premium, interactive, tactile UX.

## Scope

### In Scope
- Split CardFormWidget into 6 sub-widgets (card_editor/ folder)
- Live card preview at top — updates as user types
- Gaming-styled inputs: translucent bg, glow on focus, subtle borders
- Category selector: visual cards with icons (💬 🔥 ❤️ ✨)
- Level selector: colored pills (🟢 Suave / 🟠 Picante / 🔴 Intenso)
- Time selector: slider 5s–120s OR preset chips (15s/30s/60s)
- Premium CTA: gradient, glow, shadow, scale on tap
- Preserve create + edit mode (pre-populate on existingCard)
- Fit both IndexedStack (LibreScreen tab) and standalone route (/game/mis-cartas/edit)
- Update all 6 existing tests to match new widget tree

### Out of Scope
- Sound effects, haptic feedback
- Image upload for card backgrounds
- Animation framework overhaul (stay with ImplicitlyAnimatedWidgets)
- Changes to data layer, save logic, or validation behavior

## Capabilities

### New Capabilities
None — no new spec-level functionality.

### Modified Capabilities
- `card-editor`: CardFormWidget UI completely redesigned. Visual interaction model changed from Material form fields to gaming-style selectors and inputs. Save logic, data model, validation rules unchanged.

## Approach

Maintain `CardFormWidget` as the ConsumerStatefulWidget container (owns controllers, validation, save). Decompose into sub-widgets under `lib/presentation/widgets/card_editor/`:

| Sub-widget | File | Role |
|---|---|---|
| `CardPreviewWidget` | `card_preview.dart` | Live card preview — reads current form state via passed values |
| `GamingTextField` | `gaming_text_field.dart` | Translucent input with glow on focus |
| `CategorySelector` | `category_selector.dart` | 4 visual cards with icons + accent color (emerald/orange/fuchsia/violet) |
| `LevelSelector` | `level_selector.dart` | 3 colored pills — green/orange/fuchsia |
| `TimeSelector` | `time_selector.dart` | Slider 5–120s OR preset buttons |
| `GamingButton` | `gaming_button.dart` | Gradient + glow + scale animation |

Live preview works because all state is local (TextEditingControllers + String values). Preview widget receives current values as constructor params → `build()` reacts naturally. No Riverpod splitting needed.

Both contexts (IndexedStack / standalone route) work because the widget is self-contained — no external layout dependency.

## Layout (top→bottom)

```
┌────────────────────────────┐
│   🃏 CardPreviewWidget     │  ← live preview card
│   (reads form values)      │
├────────────────────────────┤
│   📝 GamingTextField       │  ← "Instrucción" (required)
├────────────────────────────┤
│   CategorySelector         │  ← 4 icon cards in a row
├────────────────────────────┤
│   LevelSelector            │  ← 3 color pills
├────────────────────────────┤
│   TimeSelector             │  ← slider + labels
├────────────────────────────┤
│   GamingButton             │  ← "✨ Crear carta" / "🃏 Guardar carta"
└────────────────────────────┘
```

## Visual Design

| Element | Color / Style |
|---|---|
| Background | `AppColors.background` (#07000F) |
| Input surface | `AppColors.surface` (#1A1A2E) @ 60% opacity |
| Accent glow | `AppColors.fuchsiaAccent` (#A21CAF) on focus |
| Category colors | Emerald (#059669) / Orange (#EA580C) / Fuchsia (#A21CAF) / Violet (#7C3AED) |
| Level colors | Green / Orange / Fuchsia (matches `LevelBadge`) |
| CTA gradient | FuchsiaAccent → violet diagonal |
| Border | Subtle `Colors.white10`, 1px |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Widget split breaks LibreScreen (IndexedStack) | Medium | Verify widget renders at 0 intrinsic height; test in both contexts |
| Tests need complete rewrite | High | 6 tests rely on TextFormField/DropdownButtonFormField — all must update |
| Live preview rebuilds too often | Low | setState is already fine; preview widget is lightweight |
| TimeSelector value conflicts (slider vs presets) | Low | Use single source of truth: `_tiempoSegundos` int |

## Rollback Plan

1. `git checkout -- lib/presentation/widgets/card_form_widget.dart`
2. `git clean -fd lib/presentation/widgets/card_editor/`
3. `git checkout -- test/presentation/widgets/card_form_widget_test.dart`
4. Verify: `flutter test` passes, LibreScreen create form works

## Dependencies

- Existing color system (AppColors, LevelBadge, CollectionCardTile helpers)
- No new packages

## Success Criteria

- [ ] All 6 original test scenarios pass with new widget tree
- [ ] LibreScreen create flow works inside IndexedStack (no overflow, no scroll issues)
- [ ] Edit route pre-populates preview + all selectors correctly
- [ ] Live preview updates as user types in "Instrucción"
- [ ] Category/Level selectors show active state with correct accent colors
- [ ] Time slider ranges 5–120s, displays seconds value
