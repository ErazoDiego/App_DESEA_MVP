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
    final router = GoRouter(
      initialLocation: '/onboarding/age',
      routes: [
        GoRoute(
          path: '/onboarding/age',
          builder: (_, __) => const AgeScreen(),
        ),
        GoRoute(
          path: '/onboarding/tutorial',
          builder: (_, __) => const Scaffold(
            body: Text('Tutorial page'),
          ),
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        perfilRepositoryProvider.overrideWithValue(
          FakePerfilRepository(),
        ),
      ],
    );
    addTearDown(() => container.dispose());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Verify button text is present at default 18
    expect(find.text(AppStrings.confirmarEdad), findsOneWidget);

    // Tap the slider at the far left edge to set value near minimum (below 18)
    final sliderRect = tester.getRect(find.byType(Slider));
    await tester.tapAt(Offset(sliderRect.left + 5, sliderRect.center.dy));
    await tester.pumpAndSettle();

    // Tap the confirm button — should NOT navigate because edad < 18
    await tester.tap(find.text(AppStrings.confirmarEdad));
    await tester.pumpAndSettle();

    // Should still be on the same page
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/onboarding/age',
    );
  });

  testWidgets('button enabled when slider at 18 or above', (tester) async {
    await tester.pumpWidget(createAgeApp());
    await tester.pumpAndSettle();

    // At default 18, the button text should be visible
    expect(find.text(AppStrings.confirmarEdad), findsOneWidget);
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

  testWidgets('tapping with age >= 18 navigates to tutorial',
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

    // Tap the confirm button
    await tester.tap(
      find.text(AppStrings.confirmarEdad),
    );
    await tester.pumpAndSettle();

    // Should have navigated to /onboarding/tutorial
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/onboarding/tutorial',
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

    // Default slider value is 18, tap confirm
    await tester.tap(
      find.text(AppStrings.confirmarEdad),
    );
    await tester.pumpAndSettle();

    // Verify getPerfil was called (and threw → catch branch)
    expect(fake.wasGetPerfilCalled, isTrue);

    // Verify a new Perfil was created and saved in the catch block
    expect(fake.ultimoPerfilGuardado, isNotNull);
    expect(fake.ultimoPerfilGuardado!.edad, 18);
    expect(fake.ultimoPerfilGuardado!.id, 'default');

    // Verify navigation to tutorial
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/onboarding/tutorial',
    );
  });
}
