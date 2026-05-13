import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/domain/entities/carta.dart';
import 'package:desea_mvp/core/constants/app_colors.dart';
import 'package:desea_mvp/presentation/widgets/session/carta_card.dart';

void main() {
  final testCarta = Carta(
    id: 'test_1',
    tipo: TipoCarta.verdad,
    texto: '¿Cuál es tu fantasía más secreta?',
    dirigida: Dirigida.mixta,
  );

  group('CartaCard', () {
    testWidgets('renders card text prominently', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'suave',
          ),
        ),
      ));

      expect(
        find.text('¿Cuál es tu fantasía más secreta?'),
        findsOneWidget,
      );
    });

    testWidgets('renders CategoryBadge and LevelBadge', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'picante',
          ),
        ),
      ));

      // CategoryBadge shows "VERDAD" for TipoCarta.verdad
      expect(find.text('VERDAD'), findsOneWidget);
      // LevelBadge shows "Picante" for nivel picante
      expect(find.text('Picante'), findsOneWidget);
    });

    testWidgets('shows save button when onSave is provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'suave',
            onSave: () {},
          ),
        ),
      ));

      expect(find.text('Guardar'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('shows saved state with filled icon and border',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'suave',
            isSaved: true,
            onSave: () {},
          ),
        ),
      ));

      expect(find.text('Guardada'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('does not show save button when onSave is null',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'suave',
          ),
        ),
      ));

      expect(find.text('Guardar'), findsNothing);
      expect(find.text('Guardada'), findsNothing);
    });

    testWidgets('calls onSwipeNext on left swipe', (tester) async {
      int swipeNextCalls = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'suave',
            onSwipeNext: () => swipeNextCalls++,
          ),
        ),
      ));

      await tester.fling(
        find.byType(CartaCard),
        const Offset(-300, 0),
        1000,
      );

      expect(swipeNextCalls, 1);
    });

    testWidgets('calls onSwipePrev on right swipe', (tester) async {
      int swipePrevCalls = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'suave',
            onSwipePrev: () => swipePrevCalls++,
          ),
        ),
      ));

      await tester.fling(
        find.byType(CartaCard),
        const Offset(300, 0),
        1000,
      );

      expect(swipePrevCalls, 1);
    });

    testWidgets('calls onSave when save button is pressed', (tester) async {
      int saveCalls = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'suave',
            onSave: () => saveCalls++,
          ),
        ),
      ));

      await tester.tap(find.text('Guardar'));
      expect(saveCalls, 1);
    });

    testWidgets('reto card shows CategoryBadge with RETO', (tester) async {
      final retoCarta = Carta(
        id: 'test_2',
        tipo: TipoCarta.reto,
        texto: 'Hacé un brindis',
        dirigida: Dirigida.mixta,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: retoCarta,
            nivel: 'intenso',
          ),
        ),
      ));

      expect(find.text('RETO'), findsOneWidget);
      expect(find.text('Intenso'), findsOneWidget);
    });

    testWidgets('saved card shows fuchsia border', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'suave',
            isSaved: true,
          ),
        ),
      ));

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });
}
