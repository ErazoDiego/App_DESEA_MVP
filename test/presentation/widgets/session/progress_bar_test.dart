import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/core/constants/app_colors.dart';
import 'package:desea_mvp/presentation/widgets/session/progress_bar.dart';
import 'package:desea_mvp/presentation/widgets/session/category_badge.dart';
import 'package:desea_mvp/presentation/widgets/session/level_badge.dart';

void main() {
  group('SessionProgressBar', () {
    testWidgets('renders calentamiento fase with green label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const SessionProgressBar(
            current: 2,
            total: 20,
            fase: 'calentamiento',
          ),
        ),
      ));

      expect(find.text('2/20 · Calentamiento'), findsOneWidget);

      final text = tester.widget<Text>(find.text('2/20 · Calentamiento'));
      expect(text.style?.color, Colors.green);
    });

    testWidgets('renders tension fase with orange label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const SessionProgressBar(
            current: 7,
            total: 20,
            fase: 'tension',
          ),
        ),
      ));

      expect(find.text('7/20 · Tensión'), findsOneWidget);

      final text = tester.widget<Text>(find.text('7/20 · Tensión'));
      expect(text.style?.color, Colors.orange);
    });

    testWidgets('renders climax fase with fuchsia label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const SessionProgressBar(
            current: 15,
            total: 20,
            fase: 'climax',
          ),
        ),
      ));

      expect(find.text('15/20 · Clímax'), findsOneWidget);

      final text = tester.widget<Text>(find.text('15/20 · Clímax'));
      expect(text.style?.color, AppColors.fuchsiaAccent);
    });

    testWidgets('renders cierre fase with faded fuchsia label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const SessionProgressBar(
            current: 19,
            total: 20,
            fase: 'cierre',
          ),
        ),
      ));

      expect(find.text('19/20 · Cierre'), findsOneWidget);

      final text = tester.widget<Text>(find.text('19/20 · Cierre'));
      expect(text.style?.color, AppColors.fuchsiaAccent.withValues(alpha: 0.8));
    });

    testWidgets('renders LinearProgressIndicator with correct value',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const SessionProgressBar(
            current: 5,
            total: 20,
            fase: 'calentamiento',
          ),
        ),
      ));

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, closeTo(0.25, 0.001));
    });

    testWidgets('handles total=0 without crash', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const SessionProgressBar(
            current: 0,
            total: 0,
            fase: 'calentamiento',
          ),
        ),
      ));

      expect(find.text('0/0 · Calentamiento'), findsOneWidget);

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 0);
    });

    testWidgets('default fase renders with fuchsia color', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const SessionProgressBar(
            current: 1,
            total: 10,
            fase: 'desconocida',
          ),
        ),
      ));

      expect(find.text('1/10 · desconocida'), findsOneWidget);

      final text = tester.widget<Text>(find.text('1/10 · desconocida'));
      expect(text.style?.color, AppColors.fuchsiaAccent);
    });
  });

  group('CategoryBadge', () {
    testWidgets('renders VERDAD for verdad', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const CategoryBadge(tipo: 'verdad'),
        ),
      ));

      expect(find.text('VERDAD'), findsOneWidget);
    });

    testWidgets('renders RETO for reto', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const CategoryBadge(tipo: 'reto'),
        ),
      ));

      expect(find.text('RETO'), findsOneWidget);
    });

    testWidgets('renders DESEO for deseo', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const CategoryBadge(tipo: 'deseo'),
        ),
      ));

      expect(find.text('DESEO'), findsOneWidget);
    });
  });

  group('LevelBadge', () {
    testWidgets('renders Suave with green color', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const LevelBadge(nivel: 'suave'),
        ),
      ));

      expect(find.text('Suave'), findsOneWidget);

      final text = tester.widget<Text>(find.text('Suave'));
      expect(text.style?.color, Colors.green);
    });

    testWidgets('renders Picante with orange color', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const LevelBadge(nivel: 'picante'),
        ),
      ));

      expect(find.text('Picante'), findsOneWidget);

      final text = tester.widget<Text>(find.text('Picante'));
      expect(text.style?.color, Colors.orange);
    });

    testWidgets('renders Intenso with fuchsia color', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const LevelBadge(nivel: 'intenso'),
        ),
      ));

      expect(find.text('Intenso'), findsOneWidget);

      final text = tester.widget<Text>(find.text('Intenso'));
      expect(text.style?.color, AppColors.fuchsiaAccent);
    });
  });
}
