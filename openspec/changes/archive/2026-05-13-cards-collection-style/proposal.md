# Proposal: Cards Collection Style

## Intent

Redesign SavedCardsScreen and MisCartasScreen from flat ListView+Card to a **trading-card-grid** visual style (like Pokémon cards). Same transformation applied to deck cards (DeckCardGrid), but for individual cards: each card is a single front face with gradient, accent color, optional image, and grid layout.

## Scope

### In Scope
- Shared `CollectionCardTile` widget (model-agnostic, props-based)
- Both screens: SavedCardsScreen + MisCartasScreen → 2-column GridView
- Color coding by tipo/categoria (Verdad→emerald, Reto→orange, Deseo→fuchsia, Sin Límites→purple)
- Delete overlay (semi-transparent circle, top-right) on both
- Image support: MisCartas shows `imagenUrl` on front face; SavedCards has no image
- Tap behavior: MisCartas → edit navigation; SavedCards → no-op (delete only)
- Filter chips preserved exactly as-is in both screens

### Out of Scope
- No ghost cards (stacked effect) — that's for mazos only
- No card-back design — these show front face always
- No changes to data models, providers, or routes
- No changes to DeckCardGrid or mazo screens

## Capabilities

### New Capabilities
- `collection-card-display`: Visual presentation of individual cards as grid-based trading-card-style tiles with color-coded gradients, optional images, and delete overlay.

### Modified Capabilities
- None — pure UI refactor, no spec-level behavior changes.

## Approach

1. Create `lib/presentation/widgets/collection_card_tile.dart` — shared stateless widget accepting: text, tipo, nivel, imagenUrl?, onTap?, onDelete. Color mapping (tipo→accent/gradient/gradientTop) defined as top-level helpers.
2. Extract duplicate filter-chip logic in both screens into a small shared `_FilterChipBar` or keep duplicated (2 uses, not worth extracting).
3. Replace ListView.builder → GridView.builder (2 columns, aspectRatio ~0.72) in both screens. Preserve loading/error/empty states and filter bar.
4. Card structure (top→bottom): optional image (top 40%), divider-gradient, text area (bottom 60%) with texto, tipo label + nvl badge + date. Delete overlay top-right.
5. Color scheme:
   - Verdad: accent=#059669 (emerald 600), gradient top=emerald 500, glow=emerald 600 @ 0.25
   - Reto: accent=#EA580C (orange 600), gradient top=orange 500, glow=orange 600 @ 0.25
   - Deseo: accent=#A21CAF (fuchsia 600), gradient top=fuchsia 500, glow=fuchsia 600 @ 0.25
   - Sin Límites: accent=#7C3AED (violet 600), gradient top=violet 500, glow=violet 600 @ 0.25

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/presentation/widgets/collection_card_tile.dart` | New | Shared card tile widget |
| `lib/presentation/screens/game/saved_cards_screen.dart` | Modified | Grid layout + card tile swap |
| `lib/presentation/screens/game/mis_cartas_screen.dart` | Modified | Grid layout + card tile swap |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Existing filter+delete logic breaks during refactor | Low | Extract only the tile widget + grid builder; keep all state/logic intact |
| Image loading for MisCartas blocks grid scroll | Low | Wrap Image.network with placeholder/error + loadingBuilder |
| Layout overflow on small screens with image+text | Low | Clamp text to maxLines=3 with ellipsis; clip content with ClipRRect |

## Rollback Plan

Revert 3 files using git:
```
git checkout HEAD -- lib/presentation/widgets/collection_card_tile.dart
git checkout HEAD -- lib/presentation/screens/game/saved_cards_screen.dart
git checkout HEAD -- lib/presentation/screens/game/mis_cartas_screen.dart
```
If `collection_card_tile.dart` doesn't exist on HEAD (e.g. new file), just `rm` it. No migration needed — data models are untouched.

## Success Criteria

- [ ] Both screens render cards in a 2-column grid matching the trading-card style
- [ ] Color coding by tipo/categoria applies correctly across all 4 types
- [ ] MisCartas shows image when `imagenUrl` is present, text-only without
- [ ] Delete overlay works on both screens (same UX confirmation dialog as before)
- [ ] MisCartas tap → navigates to edit form; SavedCards tap → no-op
- [ ] All existing tests pass (flutter test)
