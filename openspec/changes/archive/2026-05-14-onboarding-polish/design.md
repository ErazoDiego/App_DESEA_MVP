# Design: Onboarding Polish

## Technical Approach

**Part A**: Convert `WelcomeScreen` from `ConsumerWidget` → `ConsumerStatefulWidget` with `TickerProviderStateMixin`, replicating the exact dual-controller + `_AnimatedItem` pattern from `HomeScreen`. Three visual treatments: ShaderMask two-tone logo, staggered entrance (4 intervals over 1200ms), and a subtle 8s color-shifting background loop.

**Part B**: File-level cleanup — delete `preferences_screen.dart` + its test, remove the route + import from `app_router.dart`, redirect `AgeScreen` navigation target, strip the modo `_SummaryRow` from `ReadyScreen`.

---

## Architecture Decisions

### Decision: Dual AnimationController pattern (mirror HomeScreen)

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Single controller for everything | Simpler but can't independently loop background | ❌ |
| Dual controller (stagger + bg loop) | Matches HomeScreen 1:1; tested pattern | ✅ |
| Implicit animations (AnimatedContainer) | No `dispose()` risk but can't do staggered intervals | ❌ |

**Rationale**: HomeScreen already proves this pattern works. Two `AnimationController`s with `TickerProviderStateMixin`, both disposed in `dispose()`. Zero new risk.

### Decision: Private _AnimatedItem (duplicated, not shared)

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Extract to shared widgets/ | Would touch 2 files, break boundary, scope creep | ❌ |
| Duplicate private class | 12 lines repeated; proposal explicitly out-of-scope | ✅ |

**Rationale**: Proposal marks extraction as out-of-scope. Duplicating a 12-line private class is negligible tech debt. If DRY becomes warranted, it's a trivial future refactor.

### Decision: Inline Color constants (no AppColors changes)

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Add to AppColors | Would modify shared constant file; `_homeBackground`/`_homeBgDeep` are only used in HomeScreen | ❌ |
| Private file-level consts in welcome_screen.dart | Mirrors HomeScreen exactly; zero side effects | ✅ |

**Rationale**: The color-shift endpoints (`0xFF0D0010`, `0xFF1A0020`) and the `_deseaShader` function are identical to HomeScreen's private constants. No need to promote them to `AppColors` unless another consumer emerges.

### Decision: delete preferences files, don't deprecate

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Deprecate + keep file | Dead code; linter warning; confusion | ❌ |
| Delete file + route atomically | Clean removal; git revert is rollback | ✅ |

**Rationale**: `settings['modo']` is only read in `ready_screen.dart`, which is updated in the same change (confirmed via grep). No other consumer. Safe to delete.

---

## Component Tree

```
WelcomeScreen (ConsumerStatefulWidget, TickerProviderStateMixin)
├── AnimatedBuilder (listens: _bgColorAnim)
│   └── Container (color: _bgColorAnim.value)
│       └── SafeArea
│           └── Padding (horizontal: 24)
│               └── Column
│                   ├── Spacer(flex: 2)
│                   ├── _AnimatedItem (animation: _titleAnim)  ← stagger 0.0–0.4
│                   │   └── Column
│                   │       ├── ShaderMask (shaderCallback: _deseaShader, BlendMode.srcIn)
│                   │       │   └── Text("DESEA", size: 52, w900, letterSpacing: 6)
│                   │       └── Text(AppStrings.tagline, violet #9933ff)
│                   ├── SizedBox(h: 20)
│                   ├── _AnimatedItem (animation: _statsAnim)  ← stagger 0.2–0.5
│                   │   └── Text(AppStrings.statsLine, violet #BF5FFF)
│                   ├── Spacer(flex: 3)
│                   ├── _AnimatedItem (animation: _ctaAnim)    ← stagger 0.35–0.65
│                   │   └── SizedBox(w: double.infinity)
│                   │       └── Material(elevation: 8, shadowColor, borderRadius: 16)
│                   │           └── InkWell(onTap: → /onboarding/age)
│                   │               └── Container(fuchsia bg, boxShadow glow)
│                   │                   └── Row
│                   │                       ├── Icon(Icons.play_arrow_rounded)
│                   │                       └── Text("Comenzar")
│                   ├── SizedBox(h: 14)
│                   ├── _AnimatedItem (animation: _howToAnim)  ← stagger 0.45–0.75
│                   │   └── GestureDetector(onTap: → _showHowToPlay)
│                   │       └── Container(outline border fuchsia)
│                   │           └── Row
│                   │               ├── Icon(Icons.help_outline, fuchsia)
│                   │               └── Text("¿Cómo se juega?")
│                   └── SizedBox(h: 24)
```

### _AnimatedItem

```
_AnimatedItem (extends AnimatedWidget)
└── Opacity(opacity: anim.value)
    └── Transform.translate(offset: 0, 24 * (1 - anim.value))
        └── child
```

---

## State Management

### AnimationControllers (WelcomeScreen only)

| Controller | Duration | Behavior | Disposed in |
|-----------|----------|----------|-------------|
| `_controller` | 1200ms | `.forward()` once on initState | `dispose()` |
| `_bgController` | 8s | `.repeat(reverse: true)` on initState | `dispose()` |

### Curves / Intervals

| Animation | Interval | Curve |
|-----------|----------|-------|
| `_titleAnim` (DESEA + tagline) | 0.0 – 0.4 | `Curves.easeOutCubic` |
| `_statsAnim` (stats line) | 0.2 – 0.5 | `Curves.easeOutCubic` |
| `_ctaAnim` (Comenzar button) | 0.35 – 0.65 | `Curves.easeOutCubic` |
| `_howToAnim` (¿Cómo se juega?) | 0.45 – 0.75 | `Curves.easeOutCubic` |

### Lifecycle

```
initState()
├── _controller = AnimationController(vsync: this, duration: 1200ms)
├── _titleAnim = CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.4))
├── _statsAnim = CurvedAnimation(parent: _controller, curve: Interval(0.2, 0.5))
├── _ctaAnim   = CurvedAnimation(parent: _controller, curve: Interval(0.35, 0.65))
├── _howToAnim = CurvedAnimation(parent: _controller, curve: Interval(0.45, 0.75))
├── _controller.forward()
├── _bgController = AnimationController(vsync: this, duration: 8s)
├── _bgController.repeat(reverse: true)
└── _bgColorAnim = ColorTween(begin: 0xFF0D0010, end: 0xFF1A0020).animate(easeInOut)

dispose()
├── _controller.dispose()
├── _bgController.dispose()
└── super.dispose()
```

### State variables

- **WelcomeScreen**: None beyond animation controllers (purely presentational)
- **AgeScreen**: Only `_edad` (already exists; navigation string changes only)
- **ReadyScreen**: No state change; remove `modo`/`modoLabel` locals

---

## Data Flow

### Part A — WelcomeScreen

```
User action          →   Widget             →   Router
─────────────────────────────────────────────────────
Tap "Comenzar"       →   InkWell.onTap      →   context.go('/onboarding/age')
Tap "¿Cómo se juega?"→   GestureDetector     →   showModalBottomSheet(...)
```

No Riverpod providers, no repository calls. Zero data dependencies.

### Part B — Navigation Rewire

```
Before:              After:
AgeScreen            AgeScreen
  │                    │
  ▼                    ▼
/onboarding/preferences → /onboarding/tutorial
  │
  ▼ (deleted)
PreferencesScreen
```

### Part B — ReadyScreen Modo Removal

```
Before:                                After:
Perfil.settings['modo'] → modoLabel    (removed)
_SummaryRow(label: "Modo")             (removed)
```

---

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/presentation/screens/onboarding/welcome_screen.dart` | Modify | Rewrite to ConsumerStatefulWidget + TickerProviderStateMixin; add ShaderMask logo, dual AnimationControllers, _AnimatedItem, premium CTA, outline how-to button, _showHowToPlay bottom sheet |
| `lib/presentation/screens/onboarding/preferences_screen.dart` | Delete | Remove entire file |
| `lib/presentation/screens/onboarding/age_screen.dart` | Modify | Change `context.go('/onboarding/preferences')` → `/onboarding/tutorial` (both branches: try and catch) |
| `lib/presentation/screens/onboarding/ready_screen.dart` | Modify | Remove `modo` variable, `modoLabel` variable, and `_SummaryRow` for modo; keep edad row only |
| `lib/presentation/routes/app_router.dart` | Modify | Remove `import '../screens/onboarding/preferences_screen.dart'`; remove `GoRoute(path: '/onboarding/preferences', ...)` |
| `test/presentation/screens/onboarding/preferences_screen_test.dart` | Delete | Remove entire file |
| `test/presentation/screens/onboarding/welcome_screen_test.dart` | Modify | Update for ConsumerStatefulWidget; use `tester.pump(Duration)` instead of `pumpAndSettle`; test ShaderMask, stagger, each animated element |
| `test/presentation/screens/onboarding/age_screen_test.dart` | Modify | Change nav expectations from `/onboarding/preferences` → `/onboarding/tutorial`; update GoRoute stubs in both nav tests |
| `test/presentation/screens/onboarding/ready_screen_test.dart` | Modify | Remove `settings: {'modo': ...}` from Perfil fixtures in tests; assert "Modo:" NOT present; remove modo assertions |

---

## Shader & Color Constants

```dart
// Private to welcome_screen.dart (mirrors home_screen.dart)
const Color _welcomeBackground = Color(0xFF0D0010);
const Color _welcomeBgDeep = Color(0xFF1A0020);

Shader _deseaShader(Rect bounds) {
  return const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFff40ff), Colors.white],
    stops: [0.0, 0.35],
  ).createShader(bounds);
}
```

---

## Widget Details — How-To-Play Bottom Sheet

```dart
void _showHowToPlay(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.howToPlay, ...),
          const SizedBox(height: 16),
          GestureItem(icon: Icons.swipe, description: AppStrings.swipeGesture),
          GestureItem(icon: Icons.bookmark, description: AppStrings.guardarGesture),
          GestureItem(icon: Icons.casino, description: AppStrings.comodinGesture),
          const SizedBox(height: 8),
          Text(AppStrings.modoExplicacion),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}
```

Identical to `HomeScreen._showHowToPlay`. Uses existing `GestureItem` widget. No new strings — all `AppStrings` references exist.

---

## Premium CTA Button Detail

```dart
SizedBox(
  width: double.infinity,
  child: Material(
    elevation: 8,
    shadowColor: Colors.black38,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go('/onboarding/age'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.fuchsiaAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.fuchsiaAccent.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              AppStrings.comenzar,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
)
```

---

## Testing Strategy

### Part A — WelcomeScreen Animation Tests

| Scenario | Approach |
|----------|----------|
| ShaderMask renders DESEA logo | `tester.pump()` → find `ShaderMask` wrapping `Text("DESEA")` |
| All 4 text elements present | `tester.pump(Duration(milliseconds: 1200))` → verify text widgets exist |
| After 0ms: all invisible | `tester.pump()` → verify opacity ≈ 0 via `_AnimatedItem` value |
| After 600ms: title visible, CTA still hidden | `tester.pump(Duration(milliseconds: 600))` → check visibility state |
| After 1200ms: all visible | `tester.pump(Duration(milliseconds: 1200))` → all opacity ≈ 1 |
| CTA navigates on tap | tap after pump(1200ms) → verify route |
| How-to-play shows bottom sheet | tap outline button → verify sheet with `GestureItem`s |
| Controllers dispose without error | mount → unmount → no "unmounted controller" in test log |
| Background color animates | pump to 4s → check `container.color` changed from initial |

**CRITICAL**: Use `tester.pump(Duration(...))` NOT `pumpAndSettle()` — the 8s looping `_bgController.repeat(reverse: true)` never settles.

### Part B — Navigation & Cleanup Tests

| Scenario | Approach |
|----------|----------|
| AgeScreen navigates to tutorial | Mount with router containing `/onboarding/tutorial` route; tap confirm → assert path |
| AgeScreen catch branch navigates to tutorial | Same but with `shouldThrowOnGet: true` |
| ReadyScreen no modo row | Assert `AppStrings.modo` NOT present in widget tree |
| ReadyScreen still shows edad row | Assert edad value IS present |
| PreferencesScreen deletion | `findsNothing` or file not found — test compilation ensures no dangling import |
| Router no longer has preferences route | Navigate to `/onboarding/preferences` → assert redirects to `/onboarding/welcome` (falls through to root redirect) |

---

## Migration / Rollout

No migration required. All changes are file-level (delete, edit, create). The `settings['modo']` key was only consumed in `ready_screen.dart`, which is updated atomically in the same change. No data schema changes — the `settings` map may contain an orphan `'modo'` key in existing profiles, but it will never be read.

---

## Open Questions

None. All decisions are mapped to proven patterns in the codebase. No blockers.
