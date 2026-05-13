import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/domain/entities/carta_personalizada.dart';

void main() {
  group('CartaPersonalizada', () {
    final now = DateTime(2026, 5, 11);

    group('constructor', () {
      test('creates carta with all required fields', () {
        final carta = CartaPersonalizada(
          id: '1',
          texto: 'Haz algo divertido',
          nivel: 'suave',
          creadaEn: now,
        );

        expect(carta.id, '1');
        expect(carta.texto, 'Haz algo divertido');
        expect(carta.nivel, 'suave');
        expect(carta.creadaEn, now);
        expect(carta.categoria, isNull);
        expect(carta.tiempoSegundos, isNull);
        expect(carta.dirigida, isNull);
      });

      test('creates carta with all optional fields', () {
        final carta = CartaPersonalizada(
          id: '2',
          texto: 'Cuenta un secreto',
          categoria: 'verdad',
          nivel: 'picante',
          tiempoSegundos: const Duration(seconds: 60),
          dirigida: 'paraEl',
          creadaEn: now,
        );

        expect(carta.id, '2');
        expect(carta.texto, 'Cuenta un secreto');
        expect(carta.categoria, 'verdad');
        expect(carta.nivel, 'picante');
        expect(carta.tiempoSegundos, const Duration(seconds: 60));
        expect(carta.dirigida, 'paraEl');
        expect(carta.creadaEn, now);
      });

      test('creates carta with nivel intenso', () {
        final carta = CartaPersonalizada(
          id: '3',
          texto: 'Texto intenso',
          nivel: 'intenso',
          creadaEn: now,
        );

        expect(carta.nivel, 'intenso');
      });

      test('creates carta with categoria sinLimites', () {
        final carta = CartaPersonalizada(
          id: '4',
          texto: 'Sin límites',
          categoria: 'sinLimites',
          nivel: 'intenso',
          creadaEn: now,
        );

        expect(carta.categoria, 'sinLimites');
      });
    });

    group('equality', () {
      test('cards with same values are equal', () {
        final carta1 = CartaPersonalizada(
          id: '1',
          texto: 'Texto igual',
          nivel: 'suave',
          creadaEn: now,
        );
        final carta2 = CartaPersonalizada(
          id: '1',
          texto: 'Texto igual',
          nivel: 'suave',
          creadaEn: now,
        );

        expect(carta1, equals(carta2));
        expect(carta1.hashCode, equals(carta2.hashCode));
      });

      test('different ids make cards not equal', () {
        final carta1 = CartaPersonalizada(
          id: '1',
          texto: 'Texto',
          nivel: 'suave',
          creadaEn: now,
        );
        final carta2 = CartaPersonalizada(
          id: '2',
          texto: 'Texto',
          nivel: 'suave',
          creadaEn: now,
        );

        expect(carta1, isNot(equals(carta2)));
      });

      test('different textos make cards not equal', () {
        final carta1 = CartaPersonalizada(
          id: '1',
          texto: 'Uno',
          nivel: 'suave',
          creadaEn: now,
        );
        final carta2 = CartaPersonalizada(
          id: '1',
          texto: 'Otro',
          nivel: 'suave',
          creadaEn: now,
        );

        expect(carta1, isNot(equals(carta2)));
      });

      test('different niveles make cards not equal', () {
        final carta1 = CartaPersonalizada(
          id: '1',
          texto: 'Texto',
          nivel: 'suave',
          creadaEn: now,
        );
        final carta2 = CartaPersonalizada(
          id: '1',
          texto: 'Texto',
          nivel: 'picante',
          creadaEn: now,
        );

        expect(carta1, isNot(equals(carta2)));
      });
    });

    group('copyWith', () {
      test('creates copy with modified fields', () {
        final carta = CartaPersonalizada(
          id: '1',
          texto: 'Original',
          nivel: 'suave',
          creadaEn: now,
        );

        final modified = carta.copyWith(
          texto: 'Modificado',
          nivel: 'intenso',
        );
        expect(modified.texto, 'Modificado');
        expect(modified.nivel, 'intenso');
        expect(modified.id, '1');
        expect(modified.creadaEn, now);
      });

      test('copyWith without args returns equal instance', () {
        final carta = CartaPersonalizada(
          id: '1',
          texto: 'Texto',
          nivel: 'suave',
          creadaEn: now,
        );

        expect(carta.copyWith(), equals(carta));
      });

      test('copyWith with categoria sets value', () {
        final carta = CartaPersonalizada(
          id: '1',
          texto: 'Texto',
          nivel: 'suave',
          creadaEn: now,
        );

        final modified = carta.copyWith(categoria: 'deseo');
        expect(modified.categoria, 'deseo');
        expect(modified.texto, 'Texto');
      });

      test('copyWith with tiempoSegundos sets value', () {
        final carta = CartaPersonalizada(
          id: '1',
          texto: 'Texto',
          nivel: 'suave',
          creadaEn: now,
        );

        final modified = carta.copyWith(
          tiempoSegundos: const Duration(seconds: 120),
        );
        expect(modified.tiempoSegundos, const Duration(seconds: 120));
      });

      test('copyWith with dirigida sets value', () {
        final carta = CartaPersonalizada(
          id: '1',
          texto: 'Texto',
          nivel: 'suave',
          creadaEn: now,
        );

        final modified = carta.copyWith(dirigida: 'paraElla');
        expect(modified.dirigida, 'paraElla');
      });
    });

    group('toString', () {
      test('includes id and texto', () {
        final carta = CartaPersonalizada(
          id: '42',
          texto: 'Mi carta',
          nivel: 'picante',
          creadaEn: now,
        );

        final str = carta.toString();
        expect(str, contains('42'));
        expect(str, contains('Mi carta'));
        expect(str, contains('picante'));
      });
    });
  });
}
