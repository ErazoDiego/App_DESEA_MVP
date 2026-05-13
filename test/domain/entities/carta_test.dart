import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/domain/entities/carta.dart';

void main() {
  group('Carta', () {
    group('constructor', () {
      test('creates carta with all required fields', () {
        const carta = Carta(
          id: '1',
          tipo: TipoCarta.verdad,
          texto: 'Di tu secreto más vergonzoso',
          dirigida: Dirigida.mixta,
        );

        expect(carta.id, '1');
        expect(carta.tipo, TipoCarta.verdad);
        expect(carta.texto, 'Di tu secreto más vergonzoso');
        expect(carta.dirigida, Dirigida.mixta);
        expect(carta.tiempoSegundos, isNull);
      });

      test('creates carta with optional tiempoSegundos', () {
        const carta = Carta(
          id: '2',
          tipo: TipoCarta.reto,
          texto: 'Besa a tu pareja por 10 segundos',
          dirigida: Dirigida.paraElla,
          tiempoSegundos: Duration(seconds: 30),
        );

        expect(carta.tiempoSegundos, Duration(seconds: 30));
      });
    });

    group('equality', () {
      test('cards with same values are equal', () {
        const carta1 = Carta(
          id: '1',
          tipo: TipoCarta.verdad,
          texto: 'Di tu secreto',
          dirigida: Dirigida.mixta,
        );
        const carta2 = Carta(
          id: '1',
          tipo: TipoCarta.verdad,
          texto: 'Di tu secreto',
          dirigida: Dirigida.mixta,
        );

        expect(carta1, equals(carta2));
        expect(carta1.hashCode, equals(carta2.hashCode));
      });

      test('different ids make cards not equal', () {
        const carta1 = Carta(
          id: '1',
          tipo: TipoCarta.verdad,
          texto: 'Texto',
          dirigida: Dirigida.mixta,
        );
        const carta2 = Carta(
          id: '2',
          tipo: TipoCarta.verdad,
          texto: 'Texto',
          dirigida: Dirigida.mixta,
        );

        expect(carta1, isNot(equals(carta2)));
      });

      test('different tipos make cards not equal', () {
        const carta1 = Carta(
          id: '1',
          tipo: TipoCarta.verdad,
          texto: 'Texto',
          dirigida: Dirigida.mixta,
        );
        const carta2 = Carta(
          id: '1',
          tipo: TipoCarta.reto,
          texto: 'Texto',
          dirigida: Dirigida.mixta,
        );

        expect(carta1, isNot(equals(carta2)));
      });
    });

    group('copyWith', () {
      test('creates copy with modified fields', () {
        const carta = Carta(
          id: '1',
          tipo: TipoCarta.verdad,
          texto: 'Original',
          dirigida: Dirigida.mixta,
        );

        final modified = carta.copyWith(texto: 'Modificado');
        expect(modified.texto, 'Modificado');
        expect(modified.id, '1');
        expect(modified.tipo, TipoCarta.verdad);
        expect(modified.dirigida, Dirigida.mixta);
      });

      test('copyWith without args returns equal instance', () {
        const carta = Carta(
          id: '1',
          tipo: TipoCarta.verdad,
          texto: 'Texto',
          dirigida: Dirigida.mixta,
        );

        expect(carta.copyWith(), equals(carta));
      });

      test('copyWith with null tiempoSegundos keeps null', () {
        const carta = Carta(
          id: '1',
          tipo: TipoCarta.deseo,
          texto: 'Texto',
          dirigida: Dirigida.paraEl,
        );

        final modified = carta.copyWith(tiempoSegundos: Duration(seconds: 60));
        expect(modified.tiempoSegundos, Duration(seconds: 60));
      });
    });
  });
}
