import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desea_mvp/data/datasources/hive_datasource.dart';
import 'package:desea_mvp/data/models/carta_guardada_model.dart';
import 'package:desea_mvp/presentation/screens/home/game_hub_screen.dart';
import 'package:desea_mvp/core/constants/app_strings.dart';
import '../../../helpers/fake_guardadas_box.dart';
import '../../../helpers/fake_personalizadas_box.dart';

/// Builds a [GameHubScreen] wrapped in a [ProviderScope] with fake
/// [guardadasBoxProvider] and [personalizadasBoxProvider].
Widget buildApp({int savedCardsCount = 0}) {
  final cards = <dynamic, CartaGuardadaModel>{};
  for (var i = 0; i < savedCardsCount; i++) {
    final id = 'card_$i';
    cards[id] = CartaGuardadaModel(
      id: id,
      cartaId: 'carta_$i',
      tipo: 'verdad',
      texto: 'Test card $i',
      nivel: 'suave',
      guardadaEn: DateTime(2026, 5, 10),
    );
  }

  return ProviderScope(
    overrides: [
      guardadasBoxProvider.overrideWithValue(
        AsyncValue.data(FakeGuardadasBox(initial: cards)),
      ),
      personalizadasBoxProvider.overrideWithValue(
        AsyncValue.data(FakePersonalizadasBox()),
      ),
    ],
    child: const MaterialApp(home: GameHubScreen()),
  );
}

void main() {
  testWidgets('renders title and all mode cards', (tester) async {
    await tester.pumpWidget(buildApp());

    // Header
    expect(find.text(AppStrings.gameHubTitle), findsOneWidget);

    // First card — Sesión
    expect(find.text(AppStrings.modoSesion), findsOneWidget);
    expect(find.text(AppStrings.modoSesionDesc), findsOneWidget);

    // Second card — Libre
    expect(find.text(AppStrings.modoLibre), findsOneWidget);
    expect(find.text(AppStrings.libreCardDescription), findsOneWidget);

    // Third card — Saved Cards
    expect(find.text(AppStrings.savedCardsHubTitle), findsOneWidget);
  });

  testWidgets('shows saved cards count badge with N guardadas',
      (tester) async {
    await tester.pumpWidget(buildApp(savedCardsCount: 3));

    expect(find.text('3 guardadas'), findsOneWidget);
  });

  testWidgets('shows 0 guardadas when box is empty', (tester) async {
    await tester.pumpWidget(buildApp(savedCardsCount: 0));

    expect(find.text('0 guardadas'), findsOneWidget);
  });
}
