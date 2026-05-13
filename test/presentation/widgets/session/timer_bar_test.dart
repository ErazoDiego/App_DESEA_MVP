import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/core/constants/app_colors.dart';
import 'package:desea_mvp/presentation/widgets/session/timer_bar.dart';

void main() {
  group('TimerBar', () {
    testWidgets('renders initial time display', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimerBar(
            seconds: 120,
            onComplete: () {},
          ),
        ),
      ));

      // Shows initial time as 2:00
      expect(find.text('2:00'), findsOneWidget);
    });

    testWidgets('renders LinearProgressIndicator with correct color',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimerBar(
            seconds: 60,
            onComplete: () {},
          ),
        ),
      ));
      // Pump one frame to start the animation
      await tester.pump();

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      // Animation starts at 0, value will be near 0 initially
      expect(progress.value, closeTo(0.0, 0.01));
      expect(progress.valueColor?.value, AppColors.fuchsiaAccent);
    });

    testWidgets('updates time display after one second', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimerBar(
            seconds: 65,
            onComplete: () {},
          ),
        ),
      ));

      // Initially 1:05
      expect(find.text('1:05'), findsOneWidget);

      // After 1 second
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1:04'), findsOneWidget);
    });

    testWidgets('calls onComplete when timer reaches zero', (tester) async {
      bool completed = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimerBar(
            seconds: 2,
            onComplete: () => completed = true,
          ),
        ),
      ));

      // Pump to completion
      await tester.pump(const Duration(seconds: 2));
      // Let the animation controller complete
      await tester.pumpAndSettle();

      expect(completed, true);
    });
  });
}
