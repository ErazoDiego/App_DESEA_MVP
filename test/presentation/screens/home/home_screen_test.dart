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
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(ElevatedButton, AppStrings.startNight),
    );
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/game-hub',
    );
  });

  testWidgets('tapping Cómo se juega shows bottom sheet', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProviderScope(child: HomeScreen())),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(TextButton, AppStrings.howToPlay),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.swipeGesture), findsOneWidget);
    expect(find.text(AppStrings.guardarGesture), findsOneWidget);
    expect(find.text(AppStrings.comodinGesture), findsOneWidget);
    expect(find.text(AppStrings.modoExplicacion), findsOneWidget);
  });
}
