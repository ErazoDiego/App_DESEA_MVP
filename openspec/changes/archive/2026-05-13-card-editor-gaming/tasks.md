# Tasks: Card Editor — Gaming Experience

## Phase 1: Foundation

- [x] **T-1.1** Create `lib/presentation/widgets/card_editor/` + shared tokens file with emerald (#059669), orange (#EA580C), fuchsia (#A21CAF), violet (#7C3AED) constants. No logic — just color consts and directory scaffold.

## Phase 2: Sub-widgets

- [x] **T-2.1** `card_editor/texto_field_widget.dart` — GamingTextField: surface @ 60% bg, 1px white@10% border, fuchsia glow (3px) on focus via FocusNode, validator passthrough, maxLines support.

- [x] **T-2.2** `card_editor/category_selector_widget.dart` — CategorySelector: 4 chips in Wrap — verdad (emerald/psychology), reto (orange/whatshot), deseo (fuchsia/favorite), sinLimites (violet/auto_awesome). Selected: filled accent + glow shadow.

- [x] **T-2.3** `card_editor/level_selector_widget.dart` — LevelSelector: 3 pills in Row — suave (emerald), picante (orange), intenso (fuchsia). Selected: filled color + scale 1.05 (150ms easeOut). Default: suave.

- [x] **T-2.4** `card_editor/time_selector_widget.dart` — TimeSelector: SliderTheme 5..120 + 3 preset OutlinedButtons (15s/30s/60s). Preset tap moves slider; slider drag clears preset highlight. Value 5 = null (no timer).

- [x] **T-2.5** `card_editor/card_preview_widget.dart` — CardPreviewWidget: AspectRatio 0.68, gradient card bg, top row (category icon + color), center (texto), bottom (tipo label + level dot + time badge). Pure render — no state.

- [x] **T-2.6** `card_editor/cta_button_widget.dart` — CtaButtonWidget: gradient fuchsia→violet 45°, borderRadius 16, glow shadow (fuchsia@35%, blur 16, y 8), scale 0.95 on press (120ms easeOut). States: enabled | loading (CPI) | disabled (grey).

## Phase 3: Integration

- [x] **T-3.1** Rewrite `lib/presentation/widgets/card_form_widget.dart` — keep as ConsumerStatefulWidget (needs ref for box.put in _save()). Form state via setState. Compose all 6 sub-widgets. Keep save logic + validation. Public API unchanged.

## Phase 4: Tests

- [x] **T-4.1** Rewrite `test/presentation/widgets/card_form_widget_test.dart` — 10 tests: 6 unit + 4 integration. Keep _FakePersBox helper.

## Phase 5: Cleanup

- [x] **T-5.1** Remove old Material imports from sub-widgets. Verify `flutter test` passes with ≥310 tests. Confirm IndexedStack compatibility.
