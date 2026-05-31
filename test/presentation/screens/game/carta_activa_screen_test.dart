import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/datasources/hive_datasource.dart';
import 'package:desea_mvp/data/models/carta_guardada_model.dart';
import 'package:desea_mvp/data/models/carta_model.dart';
import 'package:desea_mvp/data/models/sesion_model.dart';
import 'package:desea_mvp/domain/entities/carta.dart';
import 'package:desea_mvp/domain/entities/sesion.dart';
import 'package:desea_mvp/domain/repositories/carta_repository.dart';
import 'package:desea_mvp/domain/repositories/sesion_repository.dart';
import 'package:desea_mvp/hive_registrar.g.dart';
import 'package:desea_mvp/presentation/widgets/session/carta_card.dart';
import 'package:desea_mvp/presentation/providers/carta_providers.dart';
import 'package:desea_mvp/presentation/providers/sesion_providers.dart';
import 'package:desea_mvp/presentation/providers/sesion_state.dart';
import 'package:desea_mvp/presentation/screens/game/carta_activa_screen.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';

// ---------------------------------------------------------------------------
// Fake repositories
// ---------------------------------------------------------------------------

class FakeCartaRepository implements CartaRepository {
  final List<Carta> _cartas;

  FakeCartaRepository(this._cartas);

  @override
  Future<List<Carta>> getCartas() async => _cartas;

  @override
  Future<Carta?> getCartaById(String id) async {
    try {
      return _cartas.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

class FakeSesionRepository implements SesionRepository {
  Sesion? ultimaSesionCreada;
  Sesion? ultimaSesionActualizada;

  @override
  Future<Sesion> crearSesion(Sesion sesion) async {
    ultimaSesionCreada = sesion;
    return sesion;
  }

  @override
  Future<void> actualizarSesion(Sesion sesion) async {
    ultimaSesionActualizada = sesion;
  }

  @override
  Future<Sesion?> getSesionActiva() async => ultimaSesionCreada;
}

// ---------------------------------------------------------------------------
// Test-only notifiers for specific states
// ---------------------------------------------------------------------------

class _LoadingNotifier extends SesionActivaNotifier {
  @override
  SesionActivaState build() =>
      const SesionActivaState(isLoading: true);
}

class _ErrorNotifier extends SesionActivaNotifier {
  @override
  SesionActivaState build() =>
      const SesionActivaState(isLoading: false, error: 'Test error');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Carta> _buildTestCartas() {
  final cartas = <Carta>[];
  int index = 0;

  for (var i = 0; i < 6; i++) {
    cartas.add(Carta(
      id: 'suave_$index',
      tipo: TipoCarta.verdad,
      texto: 'Suave $i',
      dirigida: Dirigida.mixta,
    ));
    index++;
  }

  for (var i = 0; i < 7; i++) {
    cartas.add(Carta(
      id: 'picante_$index',
      tipo: TipoCarta.reto,
      texto: 'Picante $i',
      dirigida: Dirigida.mixta,
    ));
    index++;
  }

  for (var i = 0; i < 6; i++) {
    cartas.add(Carta(
      id: 'intenso_$index',
      tipo: TipoCarta.deseo,
      texto: 'Intenso $i',
      dirigida: Dirigida.mixta,
    ));
    index++;
  }

  for (var i = 0; i < 2; i++) {
    cartas.add(Carta(
      id: 'cierre_$index',
      tipo: TipoCarta.verdad,
      texto: 'Cierre $i',
      dirigida: Dirigida.mixta,
    ));
    index++;
  }

  return cartas;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;
  late Box<CartaGuardadaModel> testGuardadasBox;
  late Box<CartaModel> testCartasBox;
  late Box<SesionModel> testSesionesBox;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('carta_activa_screen_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    testGuardadasBox = await Hive.openBox<CartaGuardadaModel>('test_guardadas_ca');
    testCartasBox = await Hive.openBox<CartaModel>('test_cartas_ca');
    testSesionesBox = await Hive.openBox<SesionModel>('test_sesiones_ca');
    await testGuardadasBox.clear();
    await testCartasBox.clear();
    await testSesionesBox.clear();
  });

  tearDown(() async {
    await testGuardadasBox.close();
  });

  group('CartaActivaScreen', () {
    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sesionActivaProvider.overrideWith(
              () => _LoadingNotifier(),
            ),
          ],
          child: const MaterialApp(home: CartaActivaScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sesionActivaProvider.overrideWith(
              () => _ErrorNotifier(),
            ),
          ],
          child: const MaterialApp(home: CartaActivaScreen()),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.text(AppStrings.reintentar), findsOneWidget);
    });

    testWidgets('shows no session state with iniciar button',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider.overrideWithValue(AsyncValue.data(testCartasBox)),
            sesionBoxProvider.overrideWithValue(AsyncValue.data(testSesionesBox)),
            cartaRepositoryProvider.overrideWithValue(
              FakeCartaRepository(_buildTestCartas()),
            ),
            sesionRepositoryProvider.overrideWithValue(
              FakeSesionRepository(),
            ),
            guardadasBoxProvider2.overrideWithValue(testGuardadasBox),
          ],
          child: const MaterialApp(home: CartaActivaScreen()),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.noSesionActiva), findsOneWidget);
      expect(find.text(AppStrings.iniciarSesion), findsOneWidget);
    });

    testWidgets('starts session and shows first card when button is tapped',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider.overrideWithValue(AsyncValue.data(testCartasBox)),
            sesionBoxProvider.overrideWithValue(AsyncValue.data(testSesionesBox)),
            cartaRepositoryProvider.overrideWithValue(
              FakeCartaRepository(_buildTestCartas()),
            ),
            sesionRepositoryProvider.overrideWithValue(
              FakeSesionRepository(),
            ),
            guardadasBoxProvider2.overrideWithValue(testGuardadasBox),
          ],
          child: const MaterialApp(home: CartaActivaScreen()),
        ),
      );
      await tester.pump();

      // Tap "Iniciar sesión"
      await tester.tap(find.text(AppStrings.iniciarSesion));
      await tester.pumpAndSettle();

      // Should show progress bar with first card info
      expect(find.textContaining('/20 · '), findsOneWidget);
      // Should show the "Siguiente" button
      expect(find.text(AppStrings.siguiente), findsOneWidget);
    });

    testWidgets('shows pause overlay when isPaused', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider.overrideWithValue(AsyncValue.data(testCartasBox)),
            sesionBoxProvider.overrideWithValue(AsyncValue.data(testSesionesBox)),
            cartaRepositoryProvider.overrideWithValue(
              FakeCartaRepository(_buildTestCartas()),
            ),
            sesionRepositoryProvider.overrideWithValue(
              FakeSesionRepository(),
            ),
            guardadasBoxProvider2.overrideWithValue(testGuardadasBox),
          ],
          child: const MaterialApp(home: CartaActivaScreen()),
        ),
      );
      await tester.pump();

      // Start session
      await tester.tap(find.text(AppStrings.iniciarSesion));
      await tester.pumpAndSettle();

      // Tap "Pausar"
      await tester.tap(find.text(AppStrings.pausar));
      await tester.pump();

      // Should show pause modal
      expect(find.text(AppStrings.sesionPausada), findsOneWidget);
      expect(find.text(AppStrings.continuar), findsOneWidget);
      expect(find.text(AppStrings.reiniciarSesion), findsOneWidget);
    });

    testWidgets('shows completada screen when session completes',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider.overrideWithValue(AsyncValue.data(testCartasBox)),
            sesionBoxProvider.overrideWithValue(AsyncValue.data(testSesionesBox)),
            cartaRepositoryProvider.overrideWithValue(
              FakeCartaRepository(_buildTestCartas()),
            ),
            sesionRepositoryProvider.overrideWithValue(
              FakeSesionRepository(),
            ),
            guardadasBoxProvider2.overrideWithValue(testGuardadasBox),
          ],
          child: const MaterialApp(home: CartaActivaScreen()),
        ),
      );
      await tester.pump();

      // Start session
      await tester.tap(find.text(AppStrings.iniciarSesion));
      await tester.pumpAndSettle();

      // Navigate through all 19 cards (indices 0-18)
      for (var i = 0; i < 19; i++) {
        await tester.tap(find.text(AppStrings.siguiente));
        await tester.pumpAndSettle();
      }

      // Now on last card - should show "Finalizar" button
      expect(find.text(AppStrings.finalizar), findsOneWidget);

      // Tap Finalizar
      await tester.tap(find.text(AppStrings.finalizar));
      await tester.pumpAndSettle();

      // Should show completed overlay
      expect(find.text(AppStrings.sesionCompletada), findsOneWidget);
      expect(find.text(AppStrings.volverInicio), findsOneWidget);
    });

    testWidgets('save button appears on active card', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider.overrideWithValue(AsyncValue.data(testCartasBox)),
            sesionBoxProvider.overrideWithValue(AsyncValue.data(testSesionesBox)),
            cartaRepositoryProvider.overrideWithValue(
              FakeCartaRepository(_buildTestCartas()),
            ),
            sesionRepositoryProvider.overrideWithValue(
              FakeSesionRepository(),
            ),
            guardadasBoxProvider2.overrideWithValue(testGuardadasBox),
          ],
          child: const MaterialApp(home: CartaActivaScreen()),
        ),
      );
      await tester.pump();

      // Start session to see active card
      await tester.tap(find.text(AppStrings.iniciarSesion));
      await tester.pumpAndSettle();

      // Flip card to reveal content and save button
      await tester.tap(find.byType(CartaCard));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // The CartaCard should show a save button (Guardar)
      expect(find.text(AppStrings.guardar), findsOneWidget);
    });

    testWidgets('shows Anterior button when not on first card', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider.overrideWithValue(AsyncValue.data(testCartasBox)),
            sesionBoxProvider.overrideWithValue(AsyncValue.data(testSesionesBox)),
            cartaRepositoryProvider.overrideWithValue(
              FakeCartaRepository(_buildTestCartas()),
            ),
            sesionRepositoryProvider.overrideWithValue(
              FakeSesionRepository(),
            ),
            guardadasBoxProvider2.overrideWithValue(testGuardadasBox),
          ],
          child: const MaterialApp(home: CartaActivaScreen()),
        ),
      );
      await tester.pump();

      // Start session
      await tester.tap(find.text(AppStrings.iniciarSesion));
      await tester.pumpAndSettle();

      // Advance to second card
      await tester.tap(find.text(AppStrings.siguiente));
      await tester.pumpAndSettle();

      // Now on card 2 → Anterior button should be visible
      expect(find.text(AppStrings.anterior), findsOneWidget);
    });

    testWidgets('hides Anterior button when on first card', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider.overrideWithValue(AsyncValue.data(testCartasBox)),
            sesionBoxProvider.overrideWithValue(AsyncValue.data(testSesionesBox)),
            cartaRepositoryProvider.overrideWithValue(
              FakeCartaRepository(_buildTestCartas()),
            ),
            sesionRepositoryProvider.overrideWithValue(
              FakeSesionRepository(),
            ),
            guardadasBoxProvider2.overrideWithValue(testGuardadasBox),
          ],
          child: const MaterialApp(home: CartaActivaScreen()),
        ),
      );
      await tester.pump();

      // Start session — on first card, canGoBack = false
      await tester.tap(find.text(AppStrings.iniciarSesion));
      await tester.pumpAndSettle();

      // Anterior should NOT be visible on first card
      expect(find.text(AppStrings.anterior), findsNothing);
    });

    testWidgets('tapping Anterior navigates back to previous card',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartaBoxProvider.overrideWithValue(AsyncValue.data(testCartasBox)),
            sesionBoxProvider.overrideWithValue(AsyncValue.data(testSesionesBox)),
            cartaRepositoryProvider.overrideWithValue(
              FakeCartaRepository(_buildTestCartas()),
            ),
            sesionRepositoryProvider.overrideWithValue(
              FakeSesionRepository(),
            ),
            guardadasBoxProvider2.overrideWithValue(testGuardadasBox),
          ],
          child: const MaterialApp(home: CartaActivaScreen()),
        ),
      );
      await tester.pump();

      // Start session
      await tester.tap(find.text(AppStrings.iniciarSesion));
      await tester.pumpAndSettle();

      // Advance to second card
      await tester.tap(find.text(AppStrings.siguiente));
      await tester.pumpAndSettle();

      // Verify Anterior is visible on card 2
      expect(find.text(AppStrings.anterior), findsOneWidget);

      // Tap Anterior to go back
      await tester.tap(find.text(AppStrings.anterior));
      await tester.pumpAndSettle();

      // Now back on card 1 → Anterior should be hidden again
      expect(find.text(AppStrings.anterior), findsNothing);
    });
  });
}
