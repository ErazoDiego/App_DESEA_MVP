# Tasks: GameHub Screen — Immersive Gaming Home

## Task Breakdown

| Ref | Task | Phase | Depends On |
|-----|------|-------|------------|
| T-1 | Define new AppStrings (gameHubColeccionSection, gameHubImmersionSubtitle, gameHubCtaSesion) + add azul token to GamingColorTokens | Foundation | — |
| T-2 | Rewrite game_hub_screen.dart: _HeroSection, _SectionHeader, _GameModeCard, _LibraryCard composition with microinteractions | Core Rewrite | T-1 |
| T-3 | Add 5 new test scenarios (hero, section header, library, counts) while preserving all 3 existing tests | Verification | T-2 |
| T-4 | Run full test suite — 0 regressions | Final | T-3 |
| T-5 | Archive: sync specs, move change folder, commit and push | Archive | T-4 |

## TDD Workflow

Each task follows: write test → run → expect fail → implement → run → expect pass.

### T-1: Foundation (AppStrings + Color Token)

**Files to modify:**
- `lib/core/constants/app_strings.dart` — add 3 strings
- `lib/presentation/widgets/card_editor/gaming_color_tokens.dart` — add `azul`

**Acceptance:**
- `AppStrings.gameHubColeccionSection` == 'Tu colección'
- `AppStrings.gameHubImmersionSubtitle` == 'La noche empieza acá'
- `AppStrings.gameHubCtaSesion` == 'Empezar sesión'
- `GamingColorTokens.azul` == `Color(0xFF2563EB)`
- All existing tests still pass

### T-2: Core Rewrite

**Files to modify:**
- `lib/presentation/screens/home/game_hub_screen.dart` — full rewrite

**Acceptance:**
- Hero section renders at ~280px with "DESEA", subtitle, CTA
- "Elegí cómo jugar" section header visible
- Sesión card: violet gradient, Icons.auto_awesome, title, description
- Libre card: orange gradient, Icons.construction, title, description
- "Tu colección" section header visible
- Guardadas card with count badge
- Mis Cartas card with count badge
- All 4 routes navigate correctly
- Scale animation on press (0.96, 120ms)
- All 3 existing tests pass unchanged

### T-3: Tests

**Files to add/modify:**
- `test/presentation/screens/home/game_hub_screen_test.dart` — add 5 scenarios

**Acceptance:**
- 8 total tests (3 existing + 5 new) all passing
- New tests cover: hero section, section header, library card, counts

### T-4: Full Test Suite

**Command:** `flutter test`

**Acceptance:**
- 327+ tests passing
- 0 failures, 0 errors

### T-5: Archive

**Actions:**
- Sync delta specs to main specs
- Move change folder to archive
- Save Engram artifacts
- Commit and push
