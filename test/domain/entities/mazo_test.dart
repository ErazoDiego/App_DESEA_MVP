import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/domain/entities/mazo.dart';

void main() {
  group('Mazo', () {
    group('constructor', () {
      test('creates mazo with all required fields', () {
        const mazo = Mazo(
          id: '1',
          nombre: 'Clásico',
        );

        expect(mazo.id, '1');
        expect(mazo.nombre, 'Clásico');
        expect(mazo.nivel, Nivel.suave);
        expect(mazo.cartaIds, isEmpty);
      });

      test('creates mazo with explicit nivel and cartaIds', () {
        const mazo = Mazo(
          id: '2',
          nombre: 'Picante',
          nivel: Nivel.picante,
          cartaIds: ['c1', 'c2', 'c3'],
        );

        expect(mazo.nivel, Nivel.picante);
        expect(mazo.cartaIds, ['c1', 'c2', 'c3']);
      });

      test('creates mazo with nivel intenso', () {
        const mazo = Mazo(
          id: '3',
          nombre: 'Intenso',
          nivel: Nivel.intenso,
        );

        expect(mazo.nivel, Nivel.intenso);
      });
    });

    group('equality', () {
      test('mazos with same values are equal', () {
        const mazo1 = Mazo(
          id: '1',
          nombre: 'Clásico',
          nivel: Nivel.suave,
          cartaIds: ['c1'],
        );
        const mazo2 = Mazo(
          id: '1',
          nombre: 'Clásico',
          nivel: Nivel.suave,
          cartaIds: ['c1'],
        );

        expect(mazo1, equals(mazo2));
        expect(mazo1.hashCode, equals(mazo2.hashCode));
      });

      test('different ids make mazos not equal', () {
        const mazo1 = Mazo(
          id: '1',
          nombre: 'Clásico',
        );
        const mazo2 = Mazo(
          id: '2',
          nombre: 'Clásico',
        );

        expect(mazo1, isNot(equals(mazo2)));
      });

      test('different niveles make mazos not equal', () {
        const mazo1 = Mazo(
          id: '1',
          nombre: 'Clásico',
          nivel: Nivel.suave,
        );
        const mazo2 = Mazo(
          id: '1',
          nombre: 'Clásico',
          nivel: Nivel.picante,
        );

        expect(mazo1, isNot(equals(mazo2)));
      });
    });

    group('copyWith', () {
      test('creates copy with modified fields', () {
        const mazo = Mazo(
          id: '1',
          nombre: 'Original',
          nivel: Nivel.suave,
        );

        final modified = mazo.copyWith(nombre: 'Modificado', nivel: Nivel.intenso);
        expect(modified.nombre, 'Modificado');
        expect(modified.nivel, Nivel.intenso);
        expect(modified.id, '1');
      });

      test('copyWith without args returns equal instance', () {
        const mazo = Mazo(
          id: '1',
          nombre: 'Clásico',
          nivel: Nivel.suave,
        );

        expect(mazo.copyWith(), equals(mazo));
      });
    });
  });
}
