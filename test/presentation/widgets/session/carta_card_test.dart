import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/domain/entities/carta.dart';
import 'package:desea_mvp/core/constants/app_colors.dart';
import 'package:desea_mvp/presentation/widgets/session/carta_card.dart';

/// Helper: toca la carta para girarla (flip) y espera la animación.
Future<void> _flipCard(WidgetTester tester) async {
  await tester.tap(find.byType(CartaCard));
  // La animación dura 500ms, pump de más para estar seguros
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  final testCarta = Carta(
    id: 'test_1',
    tipo: TipoCarta.verdad,
    texto: '¿Cuál es tu fantasía más secreta?',
    dirigida: Dirigida.mixta,
  );

  group('CartaCard', () {
    testWidgets('starts face down showing the card back', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'suave',
          ),
        ),
      ));

      // Al arrancar boca abajo NO debe mostrar el texto de la carta
      expect(
        find.text('¿Cuál es tu fantasía más secreta?'),
        findsNothing,
      );
      // Debe mostrar el hint "Toca para revelar"
      expect(find.text('Toca para revelar'), findsOneWidget);
    });

    testWidgets('renders card text after flip', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'suave',
          ),
        ),
      ));

      await _flipCard(tester);

      expect(
        find.text('¿Cuál es tu fantasía más secreta?'),
        findsOneWidget,
      );
    });

    testWidgets('renders badges after flip', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'picante',
          ),
        ),
      ));

      await _flipCard(tester);

      expect(find.text('VERDAD'), findsOneWidget);
      expect(find.text('Picante'), findsOneWidget);
    });

    testWidgets('shows save button after flip when onSave is provided',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'suave',
            onSave: () {},
          ),
        ),
      ));

      await _flipCard(tester);

      expect(find.text('Guardar'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('shows saved state with filled icon and border after flip',
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

      await _flipCard(tester);

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

      await _flipCard(tester);

      expect(find.text('Guardar'), findsNothing);
      expect(find.text('Guardada'), findsNothing);
    });

    testWidgets('calls onSwipeNext on left swipe after flip',
        (tester) async {
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

      await _flipCard(tester);

      await tester.fling(
        find.byType(CartaCard),
        const Offset(-300, 0),
        1000,
      );

      expect(swipeNextCalls, 1);
    });

    testWidgets('ignores swipes before flip', (tester) async {
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

      // Swipe sin hacer flip — no debe llamar al callback
      await tester.fling(
        find.byType(CartaCard),
        const Offset(-300, 0),
        1000,
      );

      expect(swipeNextCalls, 0);
    });

    testWidgets('calls onSwipePrev on right swipe after flip',
        (tester) async {
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

      await _flipCard(tester);

      await tester.fling(
        find.byType(CartaCard),
        const Offset(300, 0),
        1000,
      );

      expect(swipePrevCalls, 1);
    });

    testWidgets('calls onSave when save button is pressed after flip',
        (tester) async {
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

      await _flipCard(tester);

      await tester.tap(find.text('Guardar'));
      expect(saveCalls, 1);
    });

    testWidgets('reto card shows badges after flip', (tester) async {
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

      await _flipCard(tester);

      expect(find.text('RETO'), findsOneWidget);
      expect(find.text('Intenso'), findsOneWidget);
    });

    testWidgets('saved card shows fuchsia border after flip',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CartaCard(
            carta: testCarta,
            nivel: 'suave',
            isSaved: true,
          ),
        ),
      ));

      await _flipCard(tester);

      // Buscar un Container cuyo decoration tenga border fucsia
      final hasFuchsiaBorder = tester.widgetList<Container>(
        find.byType(Container),
      ).any((c) {
        final d = c.decoration;
        if (d is BoxDecoration && d.border != null) {
          return d.border!.top.color == AppColors.fuchsiaAccent;
        }
        return false;
      });
      expect(hasFuchsiaBorder, isTrue);
    });
  });
}
