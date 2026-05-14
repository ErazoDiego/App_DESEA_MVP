import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:desea_mvp/presentation/screens/onboarding/tutorial_screen.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';

void main() {
  testWidgets('renders title, 3 gesture items and entendido button',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TutorialScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.comoSeJuega), findsOneWidget);
    expect(find.text(AppStrings.swipeGesture), findsOneWidget);
    expect(find.text(AppStrings.guardarGesture), findsOneWidget);
    expect(find.text(AppStrings.comodinGesture), findsOneWidget);
    expect(find.text(AppStrings.entendido), findsOneWidget);
  });

  testWidgets('renders icons for all three gestures', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TutorialScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.swipe), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    expect(find.byIcon(Icons.casino), findsOneWidget);
  });

  testWidgets('tapping entendido navigates to ready screen',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/onboarding/tutorial',
      routes: [
        GoRoute(
          path: '/onboarding/tutorial',
          builder: (_, __) => const TutorialScreen(),
        ),
        GoRoute(
          path: '/onboarding/ready',
          builder: (_, __) => const Scaffold(
            body: Text('Ready page'),
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
      find.text(AppStrings.entendido),
    );
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/onboarding/ready',
    );
  });
}
