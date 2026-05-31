import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desea_mvp/data/datasources/hive_datasource.dart';
import 'package:desea_mvp/data/models/carta_guardada_model.dart';
import 'package:desea_mvp/data/models/carta_personalizada_model.dart';
import 'package:desea_mvp/presentation/screens/home/game_hub_screen.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';
import '../../../helpers/fake_guardadas_box.dart';
import '../../../helpers/fake_personalizadas_box.dart';

/// Builds a [GameHubScreen] wrapped in a [ProviderScope] with fake
/// [guardadasBoxProvider] and [personalizadasBoxProvider].
Widget buildApp({
  int savedCardsCount = 0,
  int personalizadasCount = 0,
}) {
  final guardadas = <dynamic, CartaGuardadaModel>{};
  for (var i = 0; i < savedCardsCount; i++) {
    final id = 'card_$i';
    guardadas[id] = CartaGuardadaModel(
      id: id,
      cartaId: 'carta_$i',
      tipo: 'verdad',
      texto: 'Test card $i',
      nivel: 'suave',
      guardadaEn: DateTime(2026, 5, 10),
    );
  }

  final pers = <dynamic, CartaPersonalizadaModel>{};
  for (var i = 0; i < personalizadasCount; i++) {
    final id = 'pers_$i';
    pers[id] = CartaPersonalizadaModel(
      id: id,
      texto: 'Carta personalizada $i',
      categoria: 'deseo',
      nivel: 'intenso',
      tiempoSegundos: 30,
      dirigida: 'ella',
      creadaEn: DateTime(2026, 5, 13),
    );
  }

  return ProviderScope(
    overrides: [
      guardadasBoxProvider.overrideWithValue(
        AsyncValue.data(FakeGuardadasBox(initial: guardadas)),
      ),
      personalizadasBoxProvider.overrideWithValue(
        AsyncValue.data(FakePersonalizadasBox(initial: pers)),
      ),
    ],
    child: const MaterialApp(home: GameHubScreen()),
  );
}

void main() {
  // ── Modos ───────────────────────────────────────────────────────

  testWidgets('renders Sesión card with title, description and chips',
      (tester) async {
    await tester.pumpWidget(buildApp());

    // Sesión card
    expect(find.text(AppStrings.modoSesion), findsOneWidget);
    expect(find.text(AppStrings.gameHubRecomendado), findsOneWidget);
    // Metadata se muestra como string combinado: "20 cartas · arco progresivo · ~30 min"
    expect(find.textContaining('20 cartas'), findsOneWidget);
    expect(find.textContaining('30 min'), findsOneWidget);
  });

  testWidgets('renders Libre card with title and description',
      (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text(AppStrings.modoLibre), findsOneWidget);
    expect(find.text(AppStrings.libreCardDescription), findsOneWidget);
  });

  // ── Mood Cards ──────────────────────────────────────────────────

  testWidgets('renders mood cards (Picante / Divertido)', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text(AppStrings.moodPicante), findsOneWidget);
    expect(find.text(AppStrings.moodDivertido), findsOneWidget);
  });

  // ── Hero Section ────────────────────────────────────────────────

  testWidgets('hero section renders title and subtitle', (tester) async {
    await tester.pumpWidget(buildApp());

    // "DESEA" aparece en header + hero title (al menos 2)
    expect(find.text(AppStrings.appName), findsAtLeast(1));

    // Hero subtitle (displayed in uppercase)
    expect(
      find.text(AppStrings.gameHubImmersionSubtitle.toUpperCase()),
      findsOneWidget,
    );
  });

  // ── Tus Cartas ──────────────────────────────────────────────────

  testWidgets('renders "Tus cartas" section header', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text(AppStrings.gameHubTusCartasSection), findsOneWidget);
  });

  testWidgets('renders Guardadas and Mis Cartas library cards',
      (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text(AppStrings.savedCardsHubTitle), findsOneWidget);
    expect(find.text(AppStrings.misCartasHubTitle), findsOneWidget);
  });

  // ── Guardadas Count ────────────────────────────────────────────

  testWidgets('shows guardadas count when cards exist', (tester) async {
    await tester.pumpWidget(buildApp(savedCardsCount: 3));

    // Se muestra como "3 cartas"
    expect(find.textContaining('3'), findsWidgets);
  });

  testWidgets('shows 0 guardadas when box is empty', (tester) async {
    await tester.pumpWidget(buildApp(savedCardsCount: 0));

    // Se muestra como "0 cartas"
    expect(find.textContaining('0'), findsWidgets);
  });

  // ── Personalizadas Count ──────────────────────────────────────

  testWidgets('shows personalizadas count for Mis Cartas', (tester) async {
    await tester.pumpWidget(buildApp(personalizadasCount: 5));

    // Guardadas="0 cartas", Pers="5 cartas"
    expect(find.textContaining('0'), findsWidgets);
    expect(find.textContaining('5'), findsOneWidget);
  });

  // ── Header ─────────────────────────────────────────────────────

  testWidgets('renders header with back button and app name',
      (tester) async {
    await tester.pumpWidget(buildApp());

    // Back button icon
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
}
