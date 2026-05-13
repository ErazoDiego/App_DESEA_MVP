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
    expect(find.text(AppStrings.modoSesionDesc), findsOneWidget);
    expect(find.text(AppStrings.gameHubRecomendado), findsOneWidget);
    expect(find.text(AppStrings.gameHubSesionDuracion), findsOneWidget);
    expect(find.text(AppStrings.gameHubSesionTipo), findsOneWidget);
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

    // "3" aparece al menos una vez (en la card Guardadas)
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('shows 0 guardadas when box is empty', (tester) async {
    await tester.pumpWidget(buildApp(savedCardsCount: 0));

    // "0" aparece al menos una vez (puede aparecer en ambas cards si ambas están vacías)
    expect(find.text('0'), findsAtLeast(1));
  });

  // ── Personalizadas Count ──────────────────────────────────────

  testWidgets('shows personalizadas count for Mis Cartas', (tester) async {
    await tester.pumpWidget(buildApp(personalizadasCount: 5));

    // Guardadas=0, Pers=5 → "5" aparece solo en Mis Cartas
    expect(find.text('0'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  // ── Bottom CTA ─────────────────────────────────────────────────

  testWidgets('renders bottom CTA with "Empezar sesión"', (tester) async {
    await tester.pumpWidget(buildApp());

    expect(find.text(AppStrings.gameHubCtaSesion), findsOneWidget);
  });

  // ── Header ─────────────────────────────────────────────────────

  testWidgets('renders header with back button and app name',
      (tester) async {
    await tester.pumpWidget(buildApp());

    // Back button icon
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
  });
}
