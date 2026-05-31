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

    group('pausable', () {
      testWidgets('stops countdown when isPaused becomes true',
          (tester) async {
        bool isPaused = false;

        Widget buildFrame() => MaterialApp(
              home: Scaffold(
                body: TimerBar(
                  seconds: 120,
                  onComplete: () {},
                  isPaused: isPaused,
                ),
              ),
            );

        await tester.pumpWidget(buildFrame());
        await tester.pump(const Duration(seconds: 1));

        // After 1 second should show 1:59
        expect(find.text('1:59'), findsOneWidget);

        // Pause
        isPaused = true;
        await tester.pumpWidget(buildFrame());
        await tester.pump(const Duration(seconds: 3));

        // Time should still be 1:59 — countdown stopped
        expect(find.text('1:59'), findsOneWidget);
      });

      testWidgets('resumes from same value when isPaused becomes false',
          (tester) async {
        bool isPaused = false;

        Widget buildFrame() => MaterialApp(
              home: Scaffold(
                body: TimerBar(
                  seconds: 120,
                  onComplete: () {},
                  isPaused: isPaused,
                ),
              ),
            );

        await tester.pumpWidget(buildFrame());
        await tester.pump(const Duration(seconds: 2));

        // After 2 seconds should show 1:58
        expect(find.text('1:58'), findsOneWidget);

        // Pause
        isPaused = true;
        await tester.pumpWidget(buildFrame());
        await tester.pump(const Duration(seconds: 3));

        // Still 1:58
        expect(find.text('1:58'), findsOneWidget);

        // Resume
        isPaused = false;
        await tester.pumpWidget(buildFrame());
        await tester.pump(const Duration(seconds: 1));

        // After 1 more second should show 1:57
        expect(find.text('1:57'), findsOneWidget);
      });

      testWidgets('progress bar maintains position when paused and resumed',
          (tester) async {
        bool isPaused = false;

        Widget buildFrame() => MaterialApp(
              home: Scaffold(
                body: TimerBar(
                  seconds: 120,
                  onComplete: () {},
                  isPaused: isPaused,
                ),
              ),
            );

        await tester.pumpWidget(buildFrame());
        await tester.pump(const Duration(seconds: 2));

        final progressBar = find.byType(LinearProgressIndicator);

        // Capture progress value before pause
        final valueBefore = tester.widget<LinearProgressIndicator>(progressBar).value;
        expect(valueBefore, isNotNull);

        // Pause
        isPaused = true;
        await tester.pumpWidget(buildFrame());
        await tester.pump(const Duration(seconds: 2));

        // Progress should be unchanged during pause
        final valueDuring = tester.widget<LinearProgressIndicator>(progressBar).value;
        expect(valueDuring, closeTo(valueBefore!, 0.01));

        // Resume
        isPaused = false;
        await tester.pumpWidget(buildFrame());
        await tester.pump(const Duration(seconds: 1));

        // Progress should have advanced after resume
        final valueAfter = tester.widget<LinearProgressIndicator>(progressBar).value;
        expect(valueAfter, greaterThan(valueDuring!));
      });

      testWidgets('does not call onComplete while paused', (tester) async {
        bool isPaused = false;
        int completeCount = 0;

        Widget buildFrame() => MaterialApp(
              home: Scaffold(
                body: TimerBar(
                  seconds: 3,
                  onComplete: () => completeCount++,
                  isPaused: isPaused,
                ),
              ),
            );

        await tester.pumpWidget(buildFrame());
        await tester.pump(const Duration(seconds: 1));

        // Pause before timer completes
        isPaused = true;
        await tester.pumpWidget(buildFrame());
        await tester.pump(const Duration(seconds: 5));

        // Should NOT have completed while paused
        expect(completeCount, 0);

        // Resume
        isPaused = false;
        await tester.pumpWidget(buildFrame());
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Should complete now after resuming
        expect(completeCount, 1);
      });
    });
  });
}
