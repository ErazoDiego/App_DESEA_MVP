import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:desea_mvp/presentation/screens/game/session_end_screen.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';

void main() {
  group('SessionEndScreen', () {
    testWidgets('renders completada title and volver button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SessionEndScreen()),
      );

      expect(find.text(AppStrings.sesionCompletada), findsOneWidget);
      expect(find.text(AppStrings.volverInicio), findsOneWidget);
    });
  });
}
