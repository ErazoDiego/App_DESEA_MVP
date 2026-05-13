# Design: GameHub Screen Redesign — Immersive Gaming Home

## Technical Approach

Complete rewrite of `GameHubScreen` (ConsumerWidget, 105→~419 LoC) replacing the flat ListTile list with a scrollable Column inside a dark-gradient Scaffold. Four new private widgets (`_HeroSection`, `_GameModeCard`, `_LibraryCard`, `_SectionHeader`) decompose responsibility. All 4 routes, all 7 existing strings, and both box providers remain unchanged — zero impact on the rest of the app. Microinteractions use local `StatefulWidget` state (not Riverpod), keeping providers untouched.

## Architecture Decisions

### Decision: Azul Token Location

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Add `azul` to `GamingColorTokens` | Semantic mismatch — tokens map to game categories (verdad, reto, etc.), azul isn't one | ✅ RECOMMENDED |
| Local `const Color` in screen | Simple, but duplicated if other screens need it | ❌ Rejected |
| Add to `AppColors` | Overloads the base palette with UI-specific tokens | ❌ Rejected |

`static const Color azul = Color(0xFF2563EB);` goes in `GamingColorTokens`. Acceptable because `GamingColorTokens` already serves as the "extended gaming palette" beyond category colors.

### Decision: Microinteraction State

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Local `StatefulWidget` setState | Self-contained, no provider overhead | ✅ RECOMMENDED |
| Riverpod provider for animation state | Over-engineered — scale taps are ephemeral UI state | ❌ Rejected |

Each card widget extends `StatefulWidget` holding a single `double _scale` field. `GestureDetector.onTapDown/TapUp/TapCancel` drives it. `AnimatedScale` (120ms) + `AnimatedContainer` (300ms) wrap the card content.

### Decision: Hero CTA String

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Reuse `startNight` = "Empezar noche" | Wrong semantics — "noche" vs "sesión" | ❌ Rejected |
| Reuse `iniciarSesion` = "Iniciar sesión" | Close but not exact — spec says "Empezar sesión" | ❌ Rejected |
| Add `gameHubCtaSesion` = "Empezar sesión" | New string, no test impact | ✅ RECOMMENDED |

New string `gameHubCtaSesion`. Zero test impact — existing tests don't check for this text.

### Decision: Hero subtitle string

`AppStrings.tagline = "La noche empieza acá"` — identical to the hero subtitle. Added `gameHubImmersionSubtitle` for semantic independence despite duplicating `tagline`.

## Widget Tree

```
GameHubScreen (ConsumerWidget)
├── Scaffold (bg: AppColors.background, no AppBar, extendBodyBehindAppBar)
│   └── SingleChildScrollView
│       └── Column
│           ├── _HeroSection (StatelessWidget)
│           │   └── Stack
│           │       ├── Container (280px, LinearGradient fuchsia→bg)
│           │       │   └── Positioned (glow circle 200x200, fuchsia shadow)
│           │       └── SafeArea → Column
│           │           ├── Text("DESEA", headlineLarge, bold, fuchsia)
│           │           ├── Text(heroSubtitle, bodyLarge, onSurface)
│           │           └── ElevatedButton("Empezar sesión", gradient bg)
│           ├── _SectionHeader("Elegí cómo jugar")
│           ├── RepaintBoundary → _GameModeCard(Sesión, violet)
│           ├── RepaintBoundary → _GameModeCard(Libre, orange)
│           ├── _SectionHeader("Tu colección")
│           ├── RepaintBoundary → Consumer → _LibraryCard(Guardadas, azul, count)
│           └── RepaintBoundary → Consumer → _LibraryCard(Mis Cartas, fuchsia, count)
```

## Data Flow

```
Fake/RealGuardadasBox ──→ guardadasBoxProvider ──→ Consumer<GameHubScreen> ──→ _LibraryCard(title, count)
Fake/RealPersonalizadasBox ──→ personalizadasBoxProvider ──→ Consumer<GameHubScreen> ──→ _LibraryCard(title, count)
```

No new providers. Counts read reactively via `ref.watch(provider).asData?.value.length ?? 0`.

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/presentation/screens/home/game_hub_screen.dart` | Rewrite | Replace ListTile list with hero + animated cards layout |
| `lib/presentation/widgets/card_editor/gaming_color_tokens.dart` | Modify | Add `static const Color azul = Color(0xFF2563EB)` |
| `lib/core/constants/app_strings.dart` | Modify | Add `gameHubColeccionSection`, `gameHubImmersionSubtitle`, `gameHubCtaSesion` |

## Interfaces / Contracts

No new interfaces. New widget props contracts:

```dart
// Props for each widget
_HeroSection({ required VoidCallback onStartSession })
_GameModeCard({ required Color color, required IconData icon, 
                required String title, required String description, 
                required VoidCallback onTap })
_LibraryCard({ required Color color, required IconData icon, 
               required String title, required int count, 
               required VoidCallback onTap })
_SectionHeader({ required String title })
```

## Testing Strategy

| Layer | What | Approach |
|-------|------|----------|
| Regression | 3 existing tests pass unchanged | `game_hub_screen_test.dart` — no base removals |
| Visual | New elements render | 5 new test scenarios |

**Test compatibility matrix** (existing → new mapping):
| Test assertion | In new tree |
|---|---|
| `gameHubTitle` (1) | `_SectionHeader` title ✓ |
| `modoSesion` (1) | `_GameModeCard` title ✓ |
| `modoSesionDesc` (1) | `_GameModeCard` description ✓ |
| `modoLibre` (1) | `_GameModeCard` title ✓ |
| `libreCardDescription` (1) | `_GameModeCard` description ✓ |
| `savedCardsHubTitle` (1) | `_LibraryCard` title ✓ |
| `'N guardadas'` (1) | `_LibraryCard` count badge ✓ |

## Migration / Rollout

No migration. Pure UI rewrite — data layer unaffected. Rollback: `git checkout -- <3 files>`.

## Open Questions

- [ ] `gameHubImmersionSubtitle` duplicates `AppStrings.tagline` — worth it for semantic independence, or just reuse? (Resolved: added as independent string)
