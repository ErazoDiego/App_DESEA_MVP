# Exploration: Setup Fundamentos — DESEA-MVP (Fase 0)

## Current State

**Greenfield project**. El directorio `/home/pc_dae/DESEA-MVP/` existe con `.atl/skill-registry.md` pero **no hay proyecto Flutter creado aún**. Se necesita `flutter create` como primer paso.

**Flutter**: 3.41.9 (stable) — Dart 3.11.5 — Linux SDK en `~/flutter/bin`

---

## 6 Áreas Investigadas

---

### 1. 🏗️ Folder Structure (Clean Architecture)

```
DESEA-MVP/
├── lib/
│   ├── main.dart                              # Entry point: ProviderScope + bootstrap
│   ├── app.dart                               # MaterialApp.router + Theme + GoRouter
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart                # Color constants (hex)
│   │   │   └── app_strings.dart               # String constants
│   │   ├── theme/
│   │   │   └── app_theme.dart                 # ThemeData + AppColorsThemeExtension
│   │   ├── errors/
│   │   │   └── failures.dart                  # Failure/sealed classes
│   │   └── utils/
│   │       └── extensions.dart                # Extension helpers
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── carta_model.dart               # Hive-annotated model + toEntity()
│   │   │   ├── mazo_model.dart
│   │   │   ├── sesion_model.dart
│   │   │   └── perfil_model.dart
│   │   ├── repositories/
│   │   │   ├── carta_repository_impl.dart
│   │   │   ├── mazo_repository_impl.dart
│   │   │   ├── sesion_repository_impl.dart
│   │   │   └── perfil_repository_impl.dart
│   │   └── datasources/
│   │       └── local/
│   │           ├── carta_local_datasource.dart
│   │           ├── mazo_local_datasource.dart
│   │           ├── sesion_local_datasource.dart
│   │           └── perfil_local_datasource.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── carta.dart                     # Pure Dart entity (no Hive)
│   │   │   ├── mazo.dart
│   │   │   ├── sesion.dart
│   │   │   └── perfil.dart
│   │   ├── repositories/
│   │   │   ├── carta_repository.dart          # Abstract interface
│   │   │   ├── mazo_repository.dart
│   │   │   ├── sesion_repository.dart
│   │   │   └── perfil_repository.dart
│   │   └── usecases/                          # Opcional para MVP
│   │       ├── get_cartas.dart
│   │       ├── get_mazos.dart
│   │       └── iniciar_sesion.dart
│   │
│   └── presentation/
│       ├── providers/
│       │   ├── carta_providers.dart           # Riverpod providers for Cartas
│       │   ├── mazo_providers.dart
│       │   ├── sesion_providers.dart
│       │   ├── perfil_providers.dart
│       │   └── theme_provider.dart
│       ├── routes/
│       │   └── app_router.dart                # GoRouter config (as Riverpod provider)
│       ├── screens/
│       │   ├── onboarding/
│       │   │   ├── welcome_screen.dart
│       │   │   ├── age_screen.dart
│       │   │   ├── preferences_screen.dart
│       │   │   ├── tutorial_screen.dart
│       │   │   └── ready_screen.dart
│       │   ├── home/
│       │   │   └── home_screen.dart
│       │   └── game/
│       │       ├── sesion_screen.dart
│       │       └── libre_screen.dart
│       └── widgets/
│           ├── carta_card.dart
│           ├── mazo_card.dart
│           └── shared/
│               ├── app_button.dart
│               └── app_text.dart
│
├── test/
│   ├── data/
│   │   └── models/
│   ├── domain/
│   │   └── entities/
│   └── presentation/
│       └── providers/
│
├── pubspec.yaml
└── .atl/
    └── skill-registry.md
```

**Principios**:
- **Domain layer**: 0 dependencias externas. Pure Dart.
- **Data layer**: Hive CE, path_provider. Models tienen `toEntity()` / `fromEntity()`.
- **Presentation layer**: Flutter + Riverpod + go_router. Providers median entre UI y repos.
- **Repository pattern**: `PerfilRepository` (abstract) → `PerfilRepositoryImpl` (concreto).
- **MVP pragmatismo**: Use cases son opcionales. Si un provider es trivial, puede llamar al repo directamente.

---

### 2. 🎨 Theme Configuration

**Colores base**:
| Token | Hex | Uso |
|-------|-----|-----|
| `background` | `#07000F` | Fondo general (Scaffold) |
| `fuchsiaAccent` | `#A21CAF` | Botones, acentos, highlights |
| `surface` | `#1A1A2E` | Cards, elevation surfaces |
| `onSurface` | `#E0E0E0` | Texto principal |
| `onSurfaceSecondary` | `#9E9E9E` | Texto secundario |

**Arquitectura recomendada**:

```dart
// core/theme/app_theme.dart

// 1. Custom ThemeExtension para colores de la app
class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  final Color background;
  final Color fuchsiaAccent;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceSecondary;

  // constructor, copyWith, lerp
}

// 2. ThemeData builder
ThemeData buildDarkTheme() {
  final colorScheme = ColorScheme.dark(
    primary: const Color(0xFFA21CAF),       // fuchsia
    surface: const Color(0xFF1A1A2E),
    onSurface: const Color(0xFFE0E0E0),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF07000F),
    colorScheme: colorScheme,
    extensions: [
      AppColorsTheme(
        background: const Color(0xFF07000F),
        fuchsiaAccent: const Color(0xFFA21CAF),
        surface: const Color(0xFF1A1A2E),
        onSurface: const Color(0xFFE0E0E0),
        onSurfaceSecondary: const Color(0xFF9E9E9E),
      ),
    ],
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA21CAF),
        foregroundColor: Colors.white,
      ),
    ),
    // ... más overrides
  );
}
```

**Por qué ThemeExtension y no solo ColorScheme**:
- ColorScheme tiene slots limitados. Con ThemeExtension tenemos colores semánticos de dominio (ej: `fuchsiaAccent`).
- Es type-safe: `context.extension<AppColorsTheme>()!.fuchsiaAccent`.
- Escalable: podemos agregar colores sin romper nada.

**Provider opcional**: `themeProvider` como `StateProvider<ThemeMode>` si queremos toggle dark/light en el futuro.

---

### 3. 📦 Model Definitions

#### Carta (typeId: 0)

```dart
@HiveType(typeId: 0)
class CartaModel extends HiveObject {
  @HiveField(0)
  final String id;                    // UUID

  @HiveField(1)
  final String tipo;                  // "verdad" | "reto" | "deseo"

  @HiveField(2)
  final String texto;                 // El contenido de la carta

  @HiveField(3)
  final String dirigida;              // "mixta" | "para_el" | "para_ella"

  @HiveField(4)
  final int? tiempoSegundos;          // null = sin tiempo

  // Constructor, toEntity(), fromEntity()
}
```

**Domain entity**:
```dart
class Carta {
  final String id;
  final TipoCarta tipo;           // Enum: verdad, reto, deseo
  final String texto;
  final Dirigida dirigida;        // Enum: mixta, paraEl, paraElla
  final Duration? tiempoLimite;   // Domain usa Duration, no int
}
```

**Enums del dominio**:
```dart
enum TipoCarta { verdad, reto, deseo }
enum Dirigida { mixta, paraEl, paraElla }
enum Nivel { suave, picante, intenso }
enum Fase { calentamiento, tension, climax, cierre }
enum Modo { sesion, libre }
```

#### Mazo (typeId: 1)

```dart
@HiveType(typeId: 1)
class MazoModel extends HiveObject {
  @HiveField(0)
  final String id;                    // UUID

  @HiveField(1)
  final String nombre;                // "Clásico", "Picante", etc.

  @HiveField(2)
  final String nivel;                 // "suave" | "picante" | "intenso"

  @HiveField(3)
  final List<String> cartaIds;        // Referencias a IDs de CartaModel
}
```

**Nota**: Guardamos `cartaIds` en lugar de objetos anidados para mantener la normalización. Las cartas se resuelven desde su propio box.

#### Sesion (typeId: 2)

```dart
@HiveType(typeId: 2)
class SesionModel extends HiveObject {
  @HiveField(0)
  final String id;                    // UUID

  @HiveField(1)
  final String modo;                  // "sesion" | "libre"

  @HiveField(2)
  final String fase;                  // "calentamiento" | "tension" | "climax" | "cierre"

  @HiveField(3)
  final int currentCardIndex;         // Índice actual en la lista de cartas

  @HiveField(4)
  final List<String> cartasUsadasIds; // IDs de cartas ya reveladas

  @HiveField(5)
  final DateTime? iniciadaEn;         // Timestamp de inicio

  @HiveField(6)
  final DateTime? completadaEn;       // Timestamp de finalización (null si activa)
}
```

#### Perfil (typeId: 3)

```dart
@HiveType(typeId: 3)
class PerfilModel extends HiveObject {
  @HiveField(0)
  final String id;                    // UUID (único, uno por dispositivo)

  @HiveField(1)
  final int edad;                     // Edad del usuario

  @HiveField(2)
  final bool onboardingCompletado;    // Flag de onboarding

  @HiveField(3)
  final Map<String, dynamic> settings; // Mapa flexible: {"notificaciones": true, ...}

  @HiveField(4)
  final DateTime? creadoEn;           // Fecha de creación del perfil
}
```

**TypeIds reservados**:
| typeId | Modelo |
|--------|--------|
| 0 | CartaModel |
| 1 | MazoModel |
| 2 | SesionModel |
| 3 | PerfilModel |

> **IMPORTANTE**: Con hive_ce, los `typeId` deben ser **globalmente únicos** en toda la app. No se pueden repetir entre modelos. Los IDs 0-3 están reservados; futuros modelos usan 4+.

---

### 4. 📦 Dependency Versions (pubspec.yaml)

**ALERTA CRÍTICA**: El Hive original (`hive`, `hive_flutter`, `hive_generator`) está **ABANDONADO** — último release hace ~3 años. `hive_generator 2.0.1` tiene constraints `analyzer <0.40` que son **incompatibles con Dart 3.11**. **Solución: usar `hive_ce` (Community Edition)** — fork activo y verificado con Dart 3.11.

```yaml
name: desea_mvp
description: DESEA - Cartas para parejas
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: ^3.11.0
  flutter: ^3.41.0

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^3.3.1
  riverpod_annotation: ^4.0.2

  # Navigation
  go_router: ^17.2.3

  # Local Storage (Hive CE — Community Edition fork)
  hive_ce: ^2.19.3
  hive_ce_flutter: ^2.3.4
  path_provider: ^2.1.5

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.15.0
  hive_ce_generator: ^1.11.1
  riverpod_generator: ^4.0.3
  go_router_builder: ^4.3.0

  # Lints
  flutter_lints: ^5.0.0
```

**Versiones verificadas** con Flutter 3.41.9 / Dart 3.11.5:

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| flutter_riverpod | ^3.3.1 | State management |
| riverpod_annotation | ^4.0.2 | Anotaciones @riverpod |
| go_router | ^17.2.3 | Routing declarativo |
| hive_ce | ^2.19.3 | Base de datos KV local |
| hive_ce_flutter | ^2.3.4 | Inicialización Flutter para Hive CE |
| path_provider | ^2.1.5 | Paths del sistema de archivos |
| build_runner | ^2.15.0 | Motor de code generation |
| hive_ce_generator | ^1.11.1 | Generación de TypeAdapters |
| riverpod_generator | ^4.0.3 | Generación de providers |
| go_router_builder | ^4.3.0 | Generación de rutas tipadas |
| flutter_lints | ^5.0.0 | Lints oficiales Flutter |

---

### 5. 🧭 Route Definitions (go_router)

**Estructura**:

```
/                           → redirect (según onboarding)
/onboarding/welcome         → WelcomeScreen
/onboarding/age             → AgeScreen
/onboarding/preferences     → PreferencesScreen
/onboarding/tutorial        → TutorialScreen
/onboarding/ready           → ReadyScreen
/home                       → HomeScreen (main screen)
/game/sesion/:mazoId        → SesionScreen
/game/libre                 → LibreScreen
```

**Implementación como Riverpod Provider** (para reactividad con el estado de onboarding):

```dart
// presentation/routes/app_router.dart

final routerProvider = Provider<GoRouter>((ref) {
  final perfilAsync = ref.watch(perfilProvider);

  return GoRouter(
    initialLocation: '/onboarding/welcome',
    redirect: (context, state) {
      return perfilAsync.whenOrNull(
        data: (perfil) {
          final onOnboarding = state.matchedLocation.startsWith('/onboarding');
          final onboardingComplete = perfil.onboardingCompletado;

          if (!onboardingComplete && !onOnboarding) return '/onboarding/welcome';
          if (onboardingComplete && onOnboarding) return '/home';
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: '/onboarding/welcome',
        name: 'welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/age',
        name: 'age',
        builder: (_, __) => const AgeScreen(),
      ),
      GoRoute(
        path: '/onboarding/preferences',
        name: 'preferences',
        builder: (_, __) => const PreferencesScreen(),
      ),
      GoRoute(
        path: '/onboarding/tutorial',
        name: 'tutorial',
        builder: (_, __) => const TutorialScreen(),
      ),
      GoRoute(
        path: '/onboarding/ready',
        name: 'ready',
        builder: (_, __) => const ReadyScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
        routes: [
          // Sub-rutas del home si son necesarias (ej: modal sheets)
        ],
      ),
      GoRoute(
        path: '/game/sesion/:mazoId',
        name: 'sesion',
        builder: (_, state) => SesionScreen(
          mazoId: state.pathParameters['mazoId']!,
        ),
      ),
      GoRoute(
        path: '/game/libre',
        name: 'libre',
        builder: (_, __) => const LibreScreen(),
      ),
    ],
  );
});
```

**Por qué el router es un Provider**:
1. Puede `watch` el estado de onboarding y redirigir automáticamente.
2. El `redirect` se re-ejecuta cuando el perfil cambia.
3. Evita pasar `ref` manualmente.

**Alternativa considerada**: go_router_builder con rutas tipadas (`@TypedGoRoute`). Es más verboso al inicio pero da type-safety. Recomendado para Fase 0 si queremos escalar. Para MVP inicial, la versión manual (arriba) es suficiente.

---

### 6. ⚡ Riverpod Provider Organization

**Estructura general**:

```
presentation/providers/
├── theme_provider.dart        # ThemeMode / tema actual
├── perfil_providers.dart      # PerfilState, completar onboarding, settings
├── carta_providers.dart       # Cartas CRUD, filtros por tipo/dirigida
├── mazo_providers.dart        # Mazos disponibles, cartas del mazo
└── sesion_providers.dart      # Sesión actual, fase, timer
```

**Patrón por capa**:

```dart
// ─── 1. Data Source (acceso directo a Hive) ───
// Se mantiene en data/datasources/local/, no en providers/

// ─── 2. Repository Providers ───
final perfilRepositoryProvider = Provider<PerfilRepository>((ref) {
  final box = ref.watch(perfilBoxProvider).requireValue;
  return PerfilRepositoryImpl(
    localDataSource: PerfilLocalDataSource(box),
  );
});

// ─── 3. Feature Providers (Notifier / AsyncNotifier) ───
@riverpod
class Perfil extends _$Perfil {
  @override
  FutureOr<PerfilState> build() async {
    final repo = ref.watch(perfilRepositoryProvider);
    final perfil = await repo.getPerfil();
    return PerfilState.fromEntity(perfil);
  }

  Future<void> completarOnboarding(int edad) async { ... }
  Future<void> updateSettings(Map<String, dynamic> s) async { ... }
}
```

**Provider tree recomendado**:

| Provider | Tipo | Depende de |
|----------|------|------------|
| `hiveInitProvider` | `FutureProvider<void>` | Nada (init) |
| `perfilBoxProvider` | `FutureProvider<Box<PerfilModel>>` | `hiveInitProvider` |
| `cartaBoxProvider` | `FutureProvider<Box<CartaModel>>` | `hiveInitProvider` |
| `mazoBoxProvider` | `FutureProvider<Box<MazoModel>>` | `hiveInitProvider` |
| `perfilRepositoryProvider` | `Provider` | `perfilBoxProvider` |
| `perfilProvider` | `AsyncNotifierProvider` | `perfilRepositoryProvider` |
| `routerProvider` | `Provider<GoRouter>` | `perfilProvider` |
| `cartaRepositoryProvider` | `Provider` | `cartaBoxProvider` |
| `cartasProvider` | `AsyncNotifierProvider` | `cartaRepositoryProvider` |
| `mazoRepositoryProvider` | `Provider` | `mazoBoxProvider` |
| `mazosProvider` | `AsyncNotifierProvider` | `mazoRepositoryProvider` |
| `sesionProvider` | `NotifierProvider` | `mazosProvider` |

**Patrón de Estado (State class)**:

```dart
@freezed  // o manual
class PerfilState with _$PerfilState {
  const factory PerfilState({
    required String id,
    required int edad,
    required bool onboardingCompletado,
    required Map<String, dynamic> settings,
    required DateTime creadoEn,
  }) = _PerfilState;

  factory PerfilState.fromEntity(Perfil entity) { ... }
}
```

**2 enfoques para MVP**:
1. **Manual** (recomendado para Fase 0): States manuales con copyWith. Menos boilerplate de generación, más fácil de debuggear.
2. **Con freezed**: Type-safe, sealed unions, copyWith generado. Mejor para escalar.

---

## Recomendación General

| Dimensión | Decisión | Por qué |
|-----------|----------|---------|
| **Hive** | Usar **hive_ce** (NO hive original) | Hive original abandonado, incompatible con Dart 3.11 |
| **Router** | `Provider<GoRouter>` (no builder manual) | Reactivo al estado de onboarding |
| **Code gen** | Solo `hive_ce_generator` en Fase 0 | Riverpod gen y go_router builder agregar después |
| **Tema** | `ThemeExtension` + `ThemeData.dark()` | Type-safe, extensible, semántico |
| **Provider pattern** | Clases Notifier (no solo StateProvider) | Escalable, testable, con lógica encapsulada |
| **States** | Clases manuales con copyBy | Sin dependencia extra (freezed después si necesario) |
| **Clean Architecture** | Sí, los 3 layers | Separación de concerns, testabilidad |

## Próximos Pasos

1. `flutter create --org com.desea desea_mvp` en el directorio
2. Agregar dependencias al `pubspec.yaml`
3. Crear estructura de carpetas completa
4. Implementar modelos + adapters Hive CE
5. Configurar tema + router
6. Inicializar Hive en `main()` / `bootstrap()`

## Ready for Proposal

**Sí**. Todos los hallazgos están claros. Hay una decisión crítica (hive_ce vs hive original) que debe reflejarse en el proposal para evitar errores de compatibilidad.
