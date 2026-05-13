import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/core/constants/app_colors.dart';
import 'package:desea_mvp/presentation/widgets/session/pause_modal.dart';

void main() {
  group('PauseModal', () {
    testWidgets('renders title and card info', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PauseModal(
            currentCard: 7,
            fase: 'tension',
            onContinue: () {},
            onRestart: () {},
          ),
        ),
      ));

      expect(find.text('Sesión pausada'), findsOneWidget);
      expect(find.text('Carta 7 · tension'), findsOneWidget);
    });

    testWidgets('renders Continue and Restart buttons', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PauseModal(
            currentCard: 3,
            fase: 'calentamiento',
            onContinue: () {},
            onRestart: () {},
          ),
        ),
      ));

      expect(find.text('Continuar'), findsOneWidget);
      expect(find.text('Reiniciar sesión'), findsOneWidget);
    });

    testWidgets('calls onContinue when Continue button is tapped',
        (tester) async {
      int continueCalls = 0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PauseModal(
            currentCard: 5,
            fase: 'tension',
            onContinue: () => continueCalls++,
            onRestart: () {},
          ),
        ),
      ));

      await tester.tap(find.text('Continuar'));
      expect(continueCalls, 1);
    });

    testWidgets('calls onRestart when Restart button is tapped',
        (tester) async {
      int restartCalls = 0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PauseModal(
            currentCard: 10,
            fase: 'climax',
            onContinue: () {},
            onRestart: () => restartCalls++,
          ),
        ),
      ));

      await tester.tap(find.text('Reiniciar sesión'));
      expect(restartCalls, 1);
    });

    testWidgets('displays fuchsia accent on title', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PauseModal(
            currentCard: 1,
            fase: 'calentamiento',
            onContinue: () {},
            onRestart: () {},
          ),
        ),
      ));

      final title = tester.widget<Text>(find.text('Sesión pausada'));
      expect(title.style?.color, AppColors.fuchsiaAccent);
    });
  });
}
