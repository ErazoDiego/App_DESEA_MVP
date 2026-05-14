import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:desea_mvp/presentation/screens/onboarding/ready_screen.dart';
import 'package:desea_mvp/presentation/providers/perfil_providers.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';
import 'package:desea_mvp/domain/entities/perfil.dart';
import '../../../helpers/fake_perfil_repository.dart';

void main() {
  testWidgets('renders title, summary and empezar button', (tester) async {
    final perfil = Perfil(
      id: 'default',
      edad: 30,
      settings: {'modo': 'sesion'},
      creadoEn: DateTime(2026),
    );

    final container = ProviderContainer(
      overrides: [
        perfilRepositoryProvider.overrideWithValue(
          FakePerfilRepository(perfil: perfil),
        ),
      ],
    );
    addTearDown(() => container.dispose());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: const ReadyScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.todoListo), findsOneWidget);
    expect(find.text(AppStrings.resumenConfig), findsOneWidget);
    expect(find.text(AppStrings.empezar), findsOneWidget);
  });

  testWidgets('shows edad in summary', (tester) async {
    final perfil = Perfil(
      id: 'default',
      edad: 25,
      settings: {'modo': 'libre'},
      creadoEn: DateTime(2026),
    );

    final container = ProviderContainer(
      overrides: [
        perfilRepositoryProvider.overrideWithValue(
          FakePerfilRepository(perfil: perfil),
        ),
      ],
    );
    addTearDown(() => container.dispose());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: const ReadyScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should show edad value
    expect(find.text('25 años'), findsOneWidget);
    // Modo should NOT be shown anymore
    expect(find.textContaining('Modo:'), findsNothing);
  });

  testWidgets('shows summary labels with correct format', (tester) async {
    final perfil = Perfil(
      id: 'default',
      edad: 30,
      settings: {'modo': 'sesion'},
      creadoEn: DateTime(2026),
    );

    final container = ProviderContainer(
      overrides: [
        perfilRepositoryProvider.overrideWithValue(
          FakePerfilRepository(perfil: perfil),
        ),
      ],
    );
    addTearDown(() => container.dispose());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: const ReadyScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify only "Edad:" label is displayed (Modo was removed)
    expect(find.textContaining('Edad:'), findsOneWidget);
    expect(find.textContaining('Modo:'), findsNothing);
    expect(find.text(AppStrings.modoSesion), findsNothing);
  });

  testWidgets('tapping empezar navigates to home and completes onboarding',
      (tester) async {
    final perfil = Perfil(
      id: 'default',
      edad: 25,
      settings: {'modo': 'sesion'},
      creadoEn: DateTime(2026),
    );

    final fakeRepo = FakePerfilRepository(perfil: perfil);

    final container = ProviderContainer(
      overrides: [
        perfilRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    addTearDown(() => container.dispose());

    final router = GoRouter(
      initialLocation: '/onboarding/ready',
      routes: [
        GoRoute(
          path: '/onboarding/ready',
          builder: (_, __) => const ReadyScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(
            body: Text('Home page'),
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

    await tester.tap(
      find.text(AppStrings.empezar),
    );
    await tester.pumpAndSettle();

    // Should navigate to /home
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/home',
    );

    // Verify onboarding was marked as completed
    final updatedPerfil = await fakeRepo.getPerfil();
    expect(updatedPerfil.onboardingCompletado, isTrue);
  });
}
