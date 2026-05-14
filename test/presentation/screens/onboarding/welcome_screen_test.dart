import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:desea_mvp/presentation/screens/onboarding/welcome_screen.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';

void main() {
  testWidgets('renders all text elements after entrance animation',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const WelcomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.tagline), findsOneWidget);
    expect(find.text(AppStrings.statsLine), findsOneWidget);
    expect(find.text(AppStrings.comenzar), findsOneWidget);
    expect(find.text(AppStrings.howToPlay), findsOneWidget);
  });

  testWidgets('starts invisible with all Opacity widgets at ~0',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const WelcomeScreen(),
        ),
      ),
    );
    // Pump zero duration so the initial frame is built at t=0
    await tester.pump(Duration.zero);

    // Each _AnimatedItem wraps its child in an Opacity widget
    final opacities =
        tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    expect(opacities.length, equals(4));
    for (final o in opacities) {
      expect(o.opacity, closeTo(0.0, 0.01));
    }
  });

  testWidgets('title animation completes before how-to at 600ms',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const WelcomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    final opacities =
        tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    expect(opacities.length, equals(4));

    // Title animation interval 0.0-0.4 is done by 480ms
    expect(opacities[0].opacity, closeTo(1.0, 0.01));

    // How-to animation interval 0.45-0.75 is at 0.167 progress at 600ms
    // with easeOutCubic: ~0.42 — definitely less than 1.0
    expect(opacities[3].opacity, lessThan(opacities[0].opacity));
  });

  testWidgets('all elements fully visible after 1200ms', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const WelcomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.comenzar), findsOneWidget);
    expect(find.text(AppStrings.howToPlay), findsOneWidget);

    final opacities =
        tester.widgetList<Opacity>(find.byType(Opacity)).toList();
    expect(opacities.length, equals(4));
    for (final o in opacities) {
      expect(o.opacity, closeTo(1.0, 0.01));
    }
  });

  testWidgets('Comenzar navigates to /onboarding/age', (tester) async {
    final router = GoRouter(
      initialLocation: '/onboarding/welcome',
      routes: [
        GoRoute(
          path: '/onboarding/welcome',
          builder: (_, __) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/onboarding/age',
          builder: (_, __) => const Scaffold(
            body: Text('Age page'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));

    await tester.tap(find.text(AppStrings.comenzar));
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/onboarding/age',
    );
  });

  testWidgets('how to play shows bottom sheet with GestureItems',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const WelcomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));

    await tester.tap(find.text(AppStrings.howToPlay));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(AppStrings.swipeGesture), findsOneWidget);
    expect(find.text(AppStrings.guardarGesture), findsOneWidget);
    expect(find.text(AppStrings.comodinGesture), findsOneWidget);
    expect(find.text(AppStrings.modoExplicacion), findsOneWidget);
  });

  testWidgets('controllers dispose without error', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const WelcomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1200));

    // Remove from tree to trigger dispose on the controllers
    await tester.pumpWidget(const SizedBox());

    // Verify the widget is no longer in the tree
    expect(find.text(AppStrings.appName), findsNothing);
  });
}
