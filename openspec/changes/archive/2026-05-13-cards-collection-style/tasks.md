# Tasks: Cards Collection Style

## Phase 1: Foundation — Shared CollectionCardTile

- [x] **T-101** Create `lib/presentation/widgets/collection_card_tile.dart`:
  - `accentColorFor(String tipo)` → emerald/verdad, orange/reto, fuchsia/deseo, violet/sinLimites (use `withValues(alpha:)`)
  - `gradientFor(String tipo)` → LinearGradient top accent→surface with glow shadow
  - `CollectionCardTile` (StatelessWidget): props `text`, `tipo`, `nivel`, `imageUrl?`, `dateLabel?`, `tipoLabel?`, `onTap?`, `onDelete`
  - Container: gradient bg, radius 16, glow shadow
  - Top ~40%: `Image.network` if `imageUrl != null` (with gradient overlay), else gradient area + category icon fallback
  - Bottom ~60%: text (maxLines: 3, ellipsis), then Row: tipoLabel + LevelBadge + dateLabel
  - Delete overlay: `Positioned(top:4, right:4)` with `Material(black38, radius:14)` + `Icons.delete_outline` 16px
  - Press animation: `GestureDetector` + `AnimatedScale(0.95, 120ms)` matching deck_card_grid pattern

## Phase 2: Integration — Screen Rewiring

- [x] **T-201** Modify `lib/presentation/screens/game/saved_cards_screen.dart`:
  - Remove `_SavedCardTile` class
  - Replace `ListView.builder` → `GridView.builder`: crossAxisCount:2, childAspectRatio:0.72, mainAxisSpacing:16, crossAxisSpacing:12
  - Map: `card.texto→text`, `card.tipo→tipo`, `card.nivel→nivel`, formatted date→`dateLabel`
  - Keep filter chips, loading/error/empty states untouched

- [x] **T-202** Modify `lib/presentation/screens/game/mis_cartas_screen.dart`:
  - Remove `_PersonalCardTile` class, replace with same GridView + CollectionCardTile pattern
  - Map: `card.categoria→tipo`, `card.imagenUrl→imageUrl`, `() => _editCard(card)→onTap`
  - Keep filter chips, loading/error/empty states, edit navigation untouched

## Phase 3: Testing — Update for Grid & DeleteOverlay

- [x] **T-301** Update `test/presentation/screens/game/saved_cards_screen_test.dart`:
  - Change all `find.byIcon(Icons.delete)` → `find.byIcon(Icons.delete_outline)`
  - Update assertions for grid viewport (off-screen cards removed, icon count adjusted)

- [x] **T-302** Update `test/presentation/screens/game/mis_cartas_screen_test.dart`:
  - Same `Icons.delete` → `Icons.delete_outline` migration
  - Update assertions for grid viewport (off-screen cards removed, icon count adjusted)
