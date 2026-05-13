# Design: Cards Collection Style

## Technical Approach

Create a single shared `CollectionCardTile` widget (stateless, model-agnostic) that renders as a 2-column grid tile with gradient background, optional image, delete overlay, and press animation. Both `SavedCardsScreen` and `MisCartasScreen` replace their `ListView.builder` + private tile widgets with a `GridView.builder` + `CollectionCardTile`. All existing loading/error/empty/filter state logic remains untouched.

## Architecture Decisions

### Decision: Shared vs. private tile widget

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Two private tiles | Duplicate layout code, harder to maintain | ❌ Rejected |
| One shared `CollectionCardTile` | Single source of truth, props-based, mudah to test | ✅ Chosen |

Rationale: Both screens need identical visual layout. The only behavioral difference (tap=edit vs. tap=noop) is handled via optional `onTap` prop.

### Decision: Color mapping key — tipo/categoria vs. nivel

| Option | Tradeoff | Decision |
|--------|----------|----------|
| By `nivel` (like DeckCardGrid) | Wrong semantics — collection cards group by type, not intensity | ❌ Rejected |
| By `tipo`/`categoria` string | Matches filter UI, visually distinguishes categories | ✅ Chosen |

Rationale: Collection screens filter by tipo/categoria, so tiles should be color-coded by the same dimension. Nivel is shown via LevelBadge inside the tile.

### Decision: Filter chip extraction

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Extract shared `FilterChipBar` | +reuse, -premature abstraction for 2 uses | ❌ Rejected |
| Keep duplicated in both screens | +self-contained, DRY enough at ~20 LOC each | ✅ Chosen |

### Decision: Image approach for MisCartas

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Always show gradient, image on top | Clean fallback, predictable layout | ✅ Chosen |
| Image fills entire top, gradient overlay | More complex, text contrast risk | ❌ Rejected |

Rationale: Gradient is the base background. When `imagenUrl` is present, it occupies the top ~40% with gradient overlay at bottom for text legibility.

## Widget Tree

```
CollectionCardTile (StatelessWidget)
├── GestureDetector (onTapDown/Up/Cancel for AnimatedScale)
│   └── AnimatedScale (0.95→1.0, 120ms easeOut)
│       └── AspectRatio (0.72)
│           └── Container (gradient background + border radius 16 + shadow)
│               └── Stack
│                   ├── Column (main content)
│                   │   ├── [Top] Image.network OR gradient area with icon
│                   │   │   └── If imagenUrl != null: Image.network + gradient overlay
│                   │   │   └── Else: Container with accent gradient + Icon
│                   │   ├── [Middle] Text (maxLines: 3, overflow: ellipsis)
│                   │   └── [Bottom] Row
│                   │       ├── Category label (uppercase, accent color)
│                   │       ├── LevelBadge
│                   │       └── Date (day/month/year)
│                   └── Positioned (top-right, delete overlay)
│                       └── Material (circle, dark semi-transparent)
│                           └── Icon(Icons.delete_outline, 16, white60)
```

## Props Interface

```dart
class CollectionCardTile extends StatelessWidget {
  final String text;
  final String tipo;         // 'verdad'|'reto'|'deseo'|'sinLimites'
  final String nivel;        // 'suave'|'picante'|'intenso'
  final String? imageUrl;    // null = gradient + icon fallback
  final String? dateLabel;   // preformatted date string
  final String? tipoLabel;   // preformatted tipo display label
  final VoidCallback? onTap; // null = not tappable (SavedCards)
  final VoidCallback onDelete;
}
```

Rationale: Model-agnostic by accepting primitives. Screens map model fields to props, keeping data layer decoupled from presentation. Date and tipo label are preformatted to keep tile pure.

## Color Helpers

```dart
// Color for accent (text, glow, delete overlay bg)
Color accentColorFor(String tipo) {
  switch (tipo) {
    case 'verdad':     return const Color(0xFF059669); // emerald
    case 'reto':       return const Color(0xFFEA580C); // orange
    case 'deseo':      return const Color(0xFFA21CAF); // fuchsia
    case 'sinLimites': return const Color(0xFF7C3AED); // violet
    default:           return const Color(0xFF9E9E9E); // grey fallback
  }
}

// Gradient colors (top → bottom: accent → surface)
LinearGradient gradientFor(String tipo) => LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [accentColorFor(tipo).withValues(alpha: 0.55), AppColors.surface],
);
```

## Grid Configuration

```dart
GridView.builder(
  clipBehavior: Clip.none,
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 24,
    crossAxisSpacing: 16,
    childAspectRatio: 0.72,
  ),
  itemCount: cards.length,
  itemBuilder: (context, index) { ... },
)
```

## Animation & Delete Overlay

Press feedback: Identical to `_DeckCardTile` — `GestureDetector` with `onTapDown`/`Up`/`Cancel` + `AnimatedScale(scale: 0.95, 120ms)`.

Delete overlay: Identical position and style — `Positioned(top: 4, right: 4)` with `Material(color: Colors.black38, borderRadius: 14)` + `Icon(Icons.delete_outline, 16, white60)`. This replaces the `IconButton` in the current tiles.

## Empty/Loading/Error States

No changes. Both screens retain their existing `_isLoading` → `CircularProgressIndicator`, `_error` → error text + retry button, empty → centered message, and `_filteredCards.isEmpty` → `AppStrings.savedCardsNoMatch` patterns.

## Integration

**SavedCardsScreen**: Replace `ListView.builder` with `GridView.builder` using `CollectionCardTile`. Map `card.texto→text`, `card.tipo→tipo`, `card.nivel→nivel`, `null→imageUrl`, formatted date→dateLabel, `_tipoLabel(card.tipo)→tipoLabel`, `null→onTap` (no edit). Keep filter bar and all state logic.

**MisCartasScreen**: Same grid replacement. Map `card.texto→text`, `card.categoria→tipo`, `card.nivel→nivel`, `card.imagenUrl→imageUrl`, formatted date→dateLabel, `_categoriaLabel(card.categoria)→tipoLabel`, `() => _editCard(card)→onTap`. Keep filter bar and all state logic.

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/presentation/widgets/collection_card_tile.dart` | **Create** | Shared tile widget + color helpers |
| `lib/presentation/screens/game/saved_cards_screen.dart` | **Modify** | GridView + CollectionCardTile; remove _SavedCardTile |
| `lib/presentation/screens/game/mis_cartas_screen.dart` | **Modify** | GridView + CollectionCardTile; remove _PersonalCardTile |
| `test/presentation/screens/game/saved_cards_screen_test.dart` | **Modify** | Update for grid + delete overlay (delete icon is now inside Positioned, not IconButton) |
| `test/presentation/screens/game/mis_cartas_screen_test.dart` | **Modify** | Same grid/delete-overlay test updates |

## Testing Strategy

| Layer | What | Approach |
|-------|------|----------|
| Widget (unit) | `CollectionCardTile` renders text, tipo colors, LevelBadge, delete overlay, image fallback | `tester.pumpWidget` with direct instantiation; verify colors, icons, text presence |
| Widget (integration) | SavedCardsScreen grid renders all cards after loading | Existing test structure — replace `find.byIcon(Icons.delete)` with `find.byIcon(Icons.delete_outline)`, verify grid has correct itemCount |
| Widget (integration) | MisCartasScreen tap navigates to edit | Existing test — verify `onTap` on card tile triggers edit path |
| Widget (integration) | Delete flow still works (dialog → confirm → removed) | Existing test patterns unchanged |
| Widget (integration) | Image tile renders when `imagenUrl` provided | New test: create personal card with imageUrl, verify `Image.network` appears |

## Migration / Rollout

No migration required. Data models untouched. Rollback: `git checkout HEAD -- lib/presentation/widgets/collection_card_tile.dart lib/presentation/screens/game/saved_cards_screen.dart lib/presentation/screens/game/mis_cartas_screen.dart`

## Open Questions

- None. All decisions resolved in proposal + this design.
