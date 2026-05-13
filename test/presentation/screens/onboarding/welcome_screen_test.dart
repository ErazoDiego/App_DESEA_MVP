import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desea_mvp/presentation/screens/onboarding/welcome_screen.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';

void main() {
  testWidgets('renders logo, tagline, stats and button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const WelcomeScreen(),
        ),
      ),
    );

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.tagline), findsOneWidget);
    expect(find.text(AppStrings.statsLine), findsOneWidget);
    expect(find.text(AppStrings.comenzar), findsOneWidget);
  });
}
