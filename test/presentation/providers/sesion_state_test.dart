import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/domain/entities/carta.dart';
import 'package:desea_mvp/presentation/providers/sesion_state.dart';

void main() {
  group('SesionActivaState', () {
    final sampleCartas = List.generate(20, (i) {
      final prefix = i < 5
          ? 'suave'
          : i < 13
              ? 'picante'
              : i < 19
                  ? 'intenso'
                  : 'cierre';
      final tipo = i.isEven ? TipoCarta.verdad : TipoCarta.reto;
      return Carta(
        id: '${prefix}_$i',
        tipo: tipo,
        texto: 'Carta $i',
        dirigida: Dirigida.mixta,
      );
    });

    group('constructor defaults', () {
      test('creates state with all default values', () {
        const state = SesionActivaState();

        expect(state.sesion, isNull);
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
        const state = SesionActivaState();
        final modified = state.copyWith(
          currentIndex: 5,
          isLoading: true,
        );

        expect(modified.currentIndex, 5);
        expect(modified.isLoading, true);
        expect(modified.cartas, isEmpty);
        expect(modified.isPaused, false);
        expect(modified.isCompleted, false);
      });

      test('copyWith without args returns equal instance', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 2,
        );
        expect(state.copyWith(), state);
      });
    });

    group('currentCarta', () {
      test('returns the carta at currentIndex', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 2,
        );
        expect(state.currentCarta.id, 'suave_2');
      });

      test('returns first carta when currentIndex is 0', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 0,
        );
        expect(state.currentCarta.id, 'suave_0');
      });
    });

    group('totalCartas', () {
      test('returns cartas length when non-empty', () {
        final state = SesionActivaState(cartas: sampleCartas);
        expect(state.totalCartas, 20);
      });

      test('returns 0 when cartas is empty', () {
        const state = SesionActivaState();
        expect(state.totalCartas, 0);
      });
    });

    group('progreso', () {
      test('at first card returns (1/20)', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 0,
        );
        expect(state.progreso, closeTo(0.05, 0.001));
      });

      test('at last card returns 1.0', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 19,
        );
        expect(state.progreso, closeTo(1.0, 0.001));
      });

      test('at card 5 returns (6/20)', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 5,
        );
        expect(state.progreso, closeTo(0.3, 0.001));
      });

      test('returns 0 when cartas is empty', () {
        const state = SesionActivaState();
        expect(state.progreso, 0);
      });
    });

    group('faseActual', () {
      test('index 0 returns calentamiento', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 0,
        );
        expect(state.faseActual, 'calentamiento');
      });

      test('index 4 returns calentamiento (boundary)', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 4,
        );
        expect(state.faseActual, 'calentamiento');
      });

      test('index 5 returns tension', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 5,
        );
        expect(state.faseActual, 'tension');
      });

      test('index 12 returns tension (boundary)', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 12,
        );
        expect(state.faseActual, 'tension');
      });

      test('index 13 returns climax', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 13,
        );
        expect(state.faseActual, 'climax');
      });

      test('index 18 returns climax (boundary)', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 18,
        );
        expect(state.faseActual, 'climax');
      });

      test('index 19 returns cierre', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 19,
        );
        expect(state.faseActual, 'cierre');
      });
    });

    group('nivelActual', () {
      test('index 0 returns suave', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 0,
        );
        expect(state.nivelActual, 'suave');
      });

      test('index 4 returns suave (boundary)', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 4,
        );
        expect(state.nivelActual, 'suave');
      });

      test('index 5 returns picante', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 5,
        );
        expect(state.nivelActual, 'picante');
      });

      test('index 12 returns picante (boundary)', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 12,
        );
        expect(state.nivelActual, 'picante');
      });

      test('index 13 returns intenso', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 13,
        );
        expect(state.nivelActual, 'intenso');
      });

      test('index 19 returns intenso', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 19,
        );
        expect(state.nivelActual, 'intenso');
      });
    });

    group('isFirstCard / isLastCard', () {
      test('isFirstCard true when index is 0', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 0,
        );
        expect(state.isFirstCard, true);
      });

      test('isFirstCard false when index > 0', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 1,
        );
        expect(state.isFirstCard, false);
      });

      test('isLastCard true when index is last', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 19,
        );
        expect(state.isLastCard, true);
      });

      test('isLastCard false when not at last index', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 18,
        );
        expect(state.isLastCard, false);
      });
    });

    group('canGoBack', () {
      test('false when isFirstCard', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 0,
        );
        expect(state.canGoBack, false);
      });

      test('true when previous card is not saved', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 2,
          savedCardIds: {'suave_2'},
        );
        expect(state.canGoBack, true);
      });

      test('true even when previous card is saved', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 2,
          savedCardIds: {'suave_1'},
        );
        expect(state.canGoBack, true);
      });
    });

    group('canSkipAhead', () {
      test('true when not last card', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 18,
        );
        expect(state.canSkipAhead, true);
      });

      test('false when is last card', () {
        final state = SesionActivaState(
          cartas: sampleCartas,
          currentIndex: 19,
        );
        expect(state.canSkipAhead, false);
      });
    });
  });
}
