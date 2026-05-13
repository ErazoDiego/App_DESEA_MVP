import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/datasources/hive_datasource.dart';
import 'package:desea_mvp/data/models/carta_guardada_model.dart';
import 'package:desea_mvp/hive_registrar.g.dart';
import 'package:desea_mvp/presentation/routes/app_router.dart';
import 'package:desea_mvp/presentation/providers/libre_providers.dart';
import 'package:desea_mvp/presentation/providers/perfil_providers.dart';
import 'package:desea_mvp/presentation/providers/sesion_providers.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';
import 'package:desea_mvp/domain/entities/perfil.dart';
import '../../helpers/fake_guardadas_box.dart';
import '../../helpers/fake_personalizadas_box.dart';
import '../../helpers/fake_perfil_repository.dart';

/// Pumps the app with the given onboarding state and returns the GoRouter.
Future<GoRouter> pumpApp({
  required WidgetTester tester,
  required bool onboardingCompletado,
  Box<CartaGuardadaModel>? guardadasBox,
}) async {
  // Default to a fake box if none provided
  final effectiveGuardadasBox = guardadasBox ?? FakeGuardadasBox();

  final container = ProviderContainer(
    overrides: [
      guardadasBoxProvider.overrideWithValue(
        AsyncValue.data(effectiveGuardadasBox),
      ),
      perfilRepositoryProvider.overrideWithValue(
        FakePerfilRepository(
          perfil: Perfil(
            id: 'default',
            edad: 25,
            onboardingCompletado: onboardingCompletado,
            creadoEn: DateTime(2026),
          ),
        ),
      ),
      guardadasBoxProvider2.overrideWith((ref) => FakeGuardadasBox()),
      personalizadasBoxProvider2.overrideWithValue(FakePersonalizadasBox()),
    ],
  );
  addTearDown(() => container.dispose());

  final router = container.read(routerProvider);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );

  await tester.pumpAndSettle();

  return router;
}

void main() {
  late Directory tempDir;
  late Box<CartaGuardadaModel> testGuardadasBox;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('app_router_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  setUp(() async {
    testGuardadasBox = await Hive.openBox<CartaGuardadaModel>('test_guardadas_ar');
    await testGuardadasBox.clear();
  });

  tearDown(() async {
    await testGuardadasBox.close();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('AppRouter redirect — Given a user with onboarding state', () {
    testWidgets(
        'When user has NOT completed onboarding '
        'Then navigating to /home redirects to /onboarding/welcome',
        (WidgetTester tester) async {
      final router = await pumpApp(
        tester: tester,
        onboardingCompletado: false,
      );

      router.go('/home');
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path,
          '/onboarding/welcome');
    });

    testWidgets(
        'When user HAS completed onboarding '
        'Then navigating to /home stays at /home',
        (WidgetTester tester) async {
      final router = await pumpApp(
        tester: tester,
        onboardingCompletado: true,
      );

      router.go('/home');
      await tester.pumpAndSettle();

      expect(
          router.routerDelegate.currentConfiguration.uri.path, '/home');
    });

    testWidgets(
        'When user has NOT completed onboarding '
        'Then navigating to /onboarding/welcome stays on onboarding',
        (WidgetTester tester) async {
      final router = await pumpApp(
        tester: tester,
        onboardingCompletado: false,
      );

      router.go('/onboarding/welcome');
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path,
          '/onboarding/welcome');
    });

    testWidgets(
        'When user HAS completed onboarding '
        'Then navigating to /onboarding/welcome redirects to /home',
        (WidgetTester tester) async {
      final router = await pumpApp(
        tester: tester,
        onboardingCompletado: true,
      );

      router.go('/onboarding/welcome');
      await tester.pumpAndSettle();

      expect(
          router.routerDelegate.currentConfiguration.uri.path, '/home');
    });
  });

  group('/game/guardadas route', () {
    testWidgets('renders SavedCardsScreen when navigated to',
        (WidgetTester tester) async {
      final router = await pumpApp(
        tester: tester,
        onboardingCompletado: true,
      );

      router.go('/game/guardadas');
      await tester.pumpAndSettle();

      expect(
        find.text(AppStrings.savedCardsTitle),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.savedCardsEmpty),
        findsOneWidget,
      );
    });
  });
}
