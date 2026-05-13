import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:desea_mvp/presentation/screens/onboarding/age_screen.dart';
import 'package:desea_mvp/presentation/providers/perfil_providers.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';
import 'package:desea_mvp/domain/entities/perfil.dart';
import '../../../helpers/fake_perfil_repository.dart';

Widget createAgeApp({Perfil? perfil}) {
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
      home: const AgeScreen(),
    ),
  );
}

void main() {
  testWidgets('renders title, slider and confirm button', (tester) async {
    await tester.pumpWidget(createAgeApp());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.onboardingAgeTitle), findsOneWidget);
    expect(find.text(AppStrings.confirmarEdad), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('button disabled when slider value below 18', (tester) async {
    await tester.pumpWidget(createAgeApp());
    await tester.pumpAndSettle();

    // At default 18, button should be enabled
    final buttonFinder = find.widgetWithText(
      ElevatedButton,
      AppStrings.confirmarEdad,
    );
    ElevatedButton button = tester.widget(buttonFinder);
    expect(button.onPressed, isNotNull);

    // Tap the slider at the far left edge to set value near minimum
    final sliderRect = tester.getRect(find.byType(Slider));
    await tester.tapAt(Offset(sliderRect.left + 5, sliderRect.center.dy));
    await tester.pumpAndSettle();

    // Button should now be disabled (value < 18)
    button = tester.widget(buttonFinder);
    expect(button.onPressed, isNull);
  });

  testWidgets('button enabled when slider at 18 or above', (tester) async {
    await tester.pumpWidget(createAgeApp());
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, AppStrings.confirmarEdad),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('slider displays label in años format', (tester) async {
    await tester.pumpWidget(createAgeApp());
    await tester.pumpAndSettle();

    // Default value at 18 should show "18 años"
    expect(find.text('18 años'), findsOneWidget);

    // Tap slider to near max (100)
    final sliderRect = tester.getRect(find.byType(Slider));
    await tester.tapAt(
      Offset(sliderRect.right - 10, sliderRect.center.dy),
    );
    await tester.pumpAndSettle();

    // Label should show current value
    expect(find.text('100 años'), findsOneWidget);
  });

  testWidgets('tapping with age >= 18 navigates to preferences',
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
      initialLocation: '/onboarding/age',
      routes: [
        GoRoute(
          path: '/onboarding/age',
          builder: (_, __) => const AgeScreen(),
        ),
        GoRoute(
          path: '/onboarding/preferences',
          builder: (_, __) => const Scaffold(
            body: Text('Preferences page'),
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

    // Tap the confirm button
    await tester.tap(
      find.widgetWithText(ElevatedButton, AppStrings.confirmarEdad),
    );
    await tester.pumpAndSettle();

    // Should have navigated to /onboarding/preferences
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/onboarding/preferences',
    );
  });

  testWidgets('creates new Perfil when no profile exists (catch branch)',
      (tester) async {
    final fake = FakePerfilRepository(shouldThrowOnGet: true);

    final container = ProviderContainer(
      overrides: [
        perfilRepositoryProvider.overrideWithValue(fake),
      ],
    );
    addTearDown(() => container.dispose());

    final router = GoRouter(
      initialLocation: '/onboarding/age',
      routes: [
        GoRoute(
          path: '/onboarding/age',
          builder: (_, __) => const AgeScreen(),
        ),
        GoRoute(
          path: '/onboarding/preferences',
          builder: (_, __) => const Scaffold(
            body: Text('Preferences page'),
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

    // Default slider value is 18 (button enabled), tap confirm
    await tester.tap(
      find.widgetWithText(ElevatedButton, AppStrings.confirmarEdad),
    );
    await tester.pumpAndSettle();

    // Verify getPerfil was called (and threw → catch branch)
    expect(fake.wasGetPerfilCalled, isTrue);

    // Verify a new Perfil was created and saved in the catch block
    expect(fake.ultimoPerfilGuardado, isNotNull);
    expect(fake.ultimoPerfilGuardado!.edad, 18);
    expect(fake.ultimoPerfilGuardado!.id, 'default');

    // Verify navigation to preferences
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/onboarding/preferences',
    );
  });
}
