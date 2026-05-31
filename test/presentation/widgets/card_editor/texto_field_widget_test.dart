import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:desea_mvp/presentation/widgets/card_editor/texto_field_widget.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrapInApp(Widget widget) {
  return MaterialApp(
    home: Scaffold(
      body: widget,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GamingTextField — maxLength', () {
    testWidgets('renders without counter when maxLength is null',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(_wrapInApp(
        GamingTextField(
          controller: controller,
          label: 'Test Label',
        ),
      ));
      await tester.pump();

      // Label should be present
      expect(find.text('Test Label'), findsOneWidget);

      // No counter should appear when maxLength is null
      // The counter renders as "X / Y" text, so "/200" should not exist
      expect(find.textContaining('/200'), findsNothing);
    });

    testWidgets('shows character counter when maxLength is set',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(_wrapInApp(
        GamingTextField(
          controller: controller,
          label: 'Test Label',
          maxLength: 200,
        ),
      ));
      await tester.pump();

      // Enter some text
      controller.text = 'Hola';
      await tester.pump();

      // Counter should show "4 / 200"
      expect(find.textContaining('/200'), findsOneWidget);
    });

    testWidgets('does not allow typing beyond maxLength', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(_wrapInApp(
        Form(
          key: GlobalKey<FormState>(),
          child: GamingTextField(
            controller: controller,
            label: 'Limited',
            maxLength: 5,
          ),
        ),
      ));
      await tester.pump();

      // Enter text that exceeds maxLength
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, '1234567890');
      await tester.pump();

      // The text should be truncated to maxLength
      expect(controller.text.length, lessThanOrEqualTo(5));
    });

    testWidgets('displays text shorter than limit normally', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(_wrapInApp(
        GamingTextField(
          controller: controller,
          label: 'Test Label',
          maxLength: 200,
        ),
      ));
      await tester.pump();

      // Enter short text
      controller.text = 'Texto corto';
      await tester.pump();

      // Text should be visible
      expect(find.text('Texto corto'), findsOneWidget);
    });
  });
}
