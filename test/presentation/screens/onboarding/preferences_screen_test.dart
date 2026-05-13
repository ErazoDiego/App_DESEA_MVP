import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:desea_mvp/presentation/screens/onboarding/preferences_screen.dart';
import 'package:desea_mvp/presentation/providers/perfil_providers.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';
import 'package:desea_mvp/domain/entities/perfil.dart';
import '../../../helpers/fake_perfil_repository.dart';

Widget createPrefsApp({Perfil? perfil}) {
  final container = ProviderContainer(
    overrides: [
      perfilRepositoryProvider.overrideWithValue(
        FakePerfilRepository(perfil: perfil),
      ),
    ],
  );
  addTearDown(() => container.dispose());

  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: const PreferencesScreen(),
    ),
  );
}

void main() {
  testWidgets('renders title, mode cards and siguiente button',
      (tester) async {
    await tester.pumpWidget(createPrefsApp());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.seleccionaModo), findsOneWidget);
    expect(find.text(AppStrings.modoSesion), findsOneWidget);
    expect(find.text(AppStrings.modoLibre), findsOneWidget);
    expect(find.text(AppStrings.siguiente), findsOneWidget);
  });

  testWidgets('siguiente disabled when no mode selected', (tester) async {
    await tester.pumpWidget(createPrefsApp());
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, AppStrings.siguiente),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('tapping a card enables siguiente button', (tester) async {
    await tester.pumpWidget(createPrefsApp());
    await tester.pumpAndSettle();

    // Tap the "Sesión" card
    await tester.tap(find.text(AppStrings.modoSesion));
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, AppStrings.siguiente),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('tapping both cards toggles selection', (tester) async {
    await tester.pumpWidget(createPrefsApp());
    await tester.pumpAndSettle();

    // Tap Sesión
    await tester.tap(find.text(AppStrings.modoSesion));
    await tester.pumpAndSettle();

    // Button should be enabled
    ElevatedButton button = tester.widget(
      find.widgetWithText(ElevatedButton, AppStrings.siguiente),
    );
    expect(button.onPressed, isNotNull);

    // Tap Libre (toggles selection to Libre)
    await tester.tap(find.text(AppStrings.modoLibre));
    await tester.pumpAndSettle();

    // Button should still be enabled
    button = tester.widget(
      find.widgetWithText(ElevatedButton, AppStrings.siguiente),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('both mode cards show their descriptions', (tester) async {
    await tester.pumpWidget(createPrefsApp());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.modoSesionDesc), findsOneWidget);
    expect(find.text(AppStrings.modoLibreDesc), findsOneWidget);
  });

  testWidgets('tapping siguiente with mode selected navigates to tutorial',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        perfilRepositoryProvider.overrideWithValue(
          FakePerfilRepository(),
        ),
      ],
    );
    addTearDown(() => container.dispose());

    final router = GoRouter(
      initialLocation: '/onboarding/preferences',
      routes: [
        GoRoute(
          path: '/onboarding/preferences',
          builder: (_, __) => const PreferencesScreen(),
        ),
        GoRoute(
          path: '/onboarding/tutorial',
          builder: (_, __) => const Scaffold(
            body: Text('Tutorial page'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Select a mode
    await tester.tap(find.text(AppStrings.modoSesion));
    await tester.pumpAndSettle();

    // Tap Siguiente
    await tester.tap(
      find.widgetWithText(ElevatedButton, AppStrings.siguiente),
    );
    await tester.pumpAndSettle();

    // Should have navigated to /onboarding/tutorial
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/onboarding/tutorial',
    );
  });
}
