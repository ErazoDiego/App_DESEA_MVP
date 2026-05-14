import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:desea_mvp/presentation/screens/home/home_screen.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';

void main() {
  testWidgets('renders logo, tagline, stats and buttons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProviderScope(child: HomeScreen())),
    );
    // Pump enough for the 1200ms entrance animation to complete
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.tagline), findsOneWidget);
    expect(find.text(AppStrings.statsLine), findsOneWidget);
    expect(find.text(AppStrings.startNight), findsOneWidget);
    expect(find.text(AppStrings.howToPlay), findsOneWidget);
  });

  testWidgets('tapping Empezar noche navigates to /game-hub', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/game-hub',
          builder: (_, __) => const Scaffold(
            body: Text('GameHub page'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    // Let entrance animation complete
    await tester.pump(const Duration(milliseconds: 1500));

    await tester.tap(find.text(AppStrings.startNight));
    // Let navigation settle
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/game-hub',
    );
  });

  testWidgets('tapping Cómo se juega shows bottom sheet', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProviderScope(child: HomeScreen())),
    );
    // Let entrance animation complete
    await tester.pump(const Duration(milliseconds: 1500));

    await tester.tap(find.text(AppStrings.howToPlay));
    // Let bottom sheet animation complete
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(AppStrings.swipeGesture), findsOneWidget);
    expect(find.text(AppStrings.guardarGesture), findsOneWidget);
    expect(find.text(AppStrings.comodinGesture), findsOneWidget);
    expect(find.text(AppStrings.modoExplicacion), findsOneWidget);
  });
}
