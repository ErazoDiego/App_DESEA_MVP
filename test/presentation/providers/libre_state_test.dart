import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/domain/entities/carta.dart';
import 'package:desea_mvp/presentation/providers/libre_state.dart';

void main() {
  group('LibreActivaState', () {
    final sampleCartas = [
      Carta(
        id: 'suave_0',
        tipo: TipoCarta.verdad,
        texto: 'Carta 0',
        dirigida: Dirigida.mixta,
      ),
      Carta(
        id: 'pers_1',
        tipo: TipoCarta.reto,
        texto: 'Carta 1',
        dirigida: Dirigida.mixta,
      ),
      Carta(
        id: 'intenso_2',
        tipo: TipoCarta.deseo,
        texto: 'Carta 2',
        dirigida: Dirigida.paraElla,
      ),
    ];

    group('constructor defaults', () {
      test('creates state with all default values', () {
        const state = LibreActivaState();

        expect(state.mazo, isNull);
        expect(state.cartas, isEmpty);
        expect(state.currentIndex, 0);
        expect(state.isPaused, false);
        expect(state.isCompleted, false);
        expect(state.savedCardIds, isEmpty);
        expect(state.remainingSeconds, isNull);
        expect(state.isLoading, false);
        expect(state.error, isNull);
      });
    });

    group('copyWith', () {
      test('creates new state with only specified fields changed', () {
        const state = LibreActivaState();
        final modified = state.copyWith(
          currentIndex: 2,
          isLoading: true,
        );

        expect(modified.currentIndex, 2);
        expect(modified.isLoading, true);
        expect(modified.cartas, isEmpty);
        expect(modified.isPaused, false);
        expect(modified.isCompleted, false);
      });

      test('copyWith without args returns equal instance', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 1,
        );
        expect(state.copyWith(), state);
      });
    });

    group('currentCarta', () {
      test('returns the carta at currentIndex', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 1,
        );
        expect(state.currentCarta.id, 'pers_1');
      });

      test('returns first carta when currentIndex is 0', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 0,
        );
        expect(state.currentCarta.id, 'suave_0');
      });
    });

    group('totalCartas', () {
      test('returns cartas length when non-empty', () {
        final state = LibreActivaState(cartas: sampleCartas);
        expect(state.totalCartas, 3);
      });

      test('returns 0 when cartas is empty', () {
        const state = LibreActivaState();
        expect(state.totalCartas, 0);
      });
    });

    group('progreso', () {
      test('at first card returns (1/3)', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 0,
        );
        expect(state.progreso, closeTo(1 / 3, 0.001));
      });

      test('at last card returns 1.0', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 2,
        );
        expect(state.progreso, closeTo(1.0, 0.001));
      });

      test('at middle card returns (2/3)', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 1,
        );
        expect(state.progreso, closeTo(2 / 3, 0.001));
      });

      test('returns 0 when cartas is empty', () {
        const state = LibreActivaState();
        expect(state.progreso, 0);
      });
    });

    group('isFirstCard / isLastCard', () {
      test('isFirstCard true when index is 0', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 0,
        );
        expect(state.isFirstCard, true);
      });

      test('isFirstCard false when index > 0', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 1,
        );
        expect(state.isFirstCard, false);
      });

      test('isLastCard true when index is last', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 2,
        );
        expect(state.isLastCard, true);
      });

      test('isLastCard false when not at last index', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 1,
        );
        expect(state.isLastCard, false);
      });
    });

    group('canGoBack', () {
      test('false when isFirstCard', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 0,
        );
        expect(state.canGoBack, false);
      });

      test('true when not first card', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 1,
        );
        expect(state.canGoBack, true);
      });

      test('true when not first card at last index', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 2,
        );
        expect(state.canGoBack, true);
      });
    });

    group('canSkipAhead', () {
      test('true when not last card', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 1,
        );
        expect(state.canSkipAhead, true);
      });

      test('false when is last card', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 2,
        );
        expect(state.canSkipAhead, false);
      });
    });

    group('equality', () {
      test('identical states are equal', () {
        final a = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 1,
          isPaused: true,
        );
        final b = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 1,
          isPaused: true,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different currentIndex makes states unequal', () {
        final a = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 0,
        );
        final b = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 1,
        );
        expect(a, isNot(equals(b)));
      });
    });

    group('toString', () {
      test('includes key state fields', () {
        final state = LibreActivaState(
          cartas: sampleCartas,
          currentIndex: 0,
        );
        final str = state.toString();
        expect(str, contains('LibreActivaState'));
        expect(str, contains('cartas: 3 cartas'));
        expect(str, contains('currentIndex: 0'));
      });
    });
  });
}
