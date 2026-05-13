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
import 'package:desea_mvp/presentation/providers/carta_providers.dart';
import 'package:desea_mvp/presentation/providers/sesion_providers.dart';
import 'package:desea_mvp/presentation/screens/game/sesion_screen.dart';
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
    tempDir = Directory.systemTemp.createTempSync('sesion_screen_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    testGuardadasBox = await Hive.openBox<CartaGuardadaModel>('test_guardadas');
    testCartasBox = await Hive.openBox<CartaModel>('test_cartas');
    testSesionesBox = await Hive.openBox<SesionModel>('test_sesiones');
    await testGuardadasBox.clear();
    await testCartasBox.clear();
    await testSesionesBox.clear();
  });

  tearDown(() async {
    await testGuardadasBox.close();
    await testCartasBox.close();
    await testSesionesBox.close();
  });

  group('SesionScreen', () {
    testWidgets('renders mode description and comenzar button', (tester) async {
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
          child: const MaterialApp(home: SesionScreen(mazoId: 'test_mazo')),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.modoSesionDesc), findsOneWidget);
      expect(find.text(AppStrings.comenzar), findsOneWidget);
    });

    testWidgets('starts session and navigates to CartaActivaScreen on tap',
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
          child: const MaterialApp(home: SesionScreen(mazoId: 'test_mazo')),
        ),
      );
      await tester.pump();

      // Tap "Comenzar"
      await tester.tap(find.text(AppStrings.comenzar));
      await tester.pumpAndSettle();

      // After session starts, CartaActivaScreen should show
      // The navigation in the orignial SesionScreen navigates via
      // Navigator pushReplacement to CartaActivaScreen
      // Let's verify by checking for progress bar content
      expect(find.textContaining('/20 · '), findsOneWidget);
    });
  });
}
