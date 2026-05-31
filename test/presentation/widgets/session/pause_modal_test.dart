import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/core/constants/app_colors.dart';
import 'package:desea_mvp/presentation/widgets/session/pause_modal.dart';

void _noop() {}

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

    testWidgets('hides card info line when currentCard and fase are null',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const PauseModal(
            currentCard: null,
            fase: null,
            onContinue: _noop,
            onRestart: _noop,
          ),
        ),
      ));

      // "Carta" text should not appear when both are null
      expect(find.textContaining('Carta'), findsNothing);
    });

    testWidgets('hides card info when only one param is provided',
        (tester) async {
      // Si solo uno es non-null, la info debe ocultarse
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const PauseModal(
            currentCard: null,
            fase: 'tension',
            onContinue: _noop,
            onRestart: _noop,
          ),
        ),
      ));

      expect(find.textContaining('Carta'), findsNothing);
    });

    testWidgets('shows card info line when currentCard and fase are provided',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const PauseModal(
            currentCard: 3,
            fase: 'tension',
            onContinue: _noop,
            onRestart: _noop,
          ),
        ),
      ));

      expect(find.text('Carta 3 · tension'), findsOneWidget);
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
