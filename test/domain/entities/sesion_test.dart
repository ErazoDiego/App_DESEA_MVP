import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/domain/entities/sesion.dart';

void main() {
  group('Sesion', () {
    group('constructor', () {
      test('creates sesion with all required fields', () {
        const sesion = Sesion(
          id: '1',
          modo: Modo.sesion,
        );

        expect(sesion.id, '1');
        expect(sesion.modo, Modo.sesion);
        expect(sesion.fase, Fase.calentamiento);
        expect(sesion.currentCardIndex, 0);
        expect(sesion.cartasUsadasIds, isEmpty);
        expect(sesion.iniciadaEn, isNull);
        expect(sesion.completadaEn, isNull);
      });

      test('creates sesion in modo libre', () {
        const sesion = Sesion(
          id: '2',
          modo: Modo.libre,
        );

        expect(sesion.modo, Modo.libre);
      });

      test('creates sesion with explicit fase', () {
        const sesion = Sesion(
          id: '3',
          modo: Modo.sesion,
          fase: Fase.tension,
        );

        expect(sesion.fase, Fase.tension);
      });

      test('creates sesion with all optional fields', () {
        final now = DateTime.now();
        const sesion = Sesion(
          id: '4',
          modo: Modo.sesion,
          fase: Fase.climax,
          currentCardIndex: 5,
          cartasUsadasIds: ['c1', 'c2'],
          iniciadaEn: null,
          completadaEn: null,
        );

        expect(sesion.currentCardIndex, 5);
        expect(sesion.cartasUsadasIds, ['c1', 'c2']);
      });
    });

    group('equality', () {
      test('sesiones with same values are equal', () {
        const sesion1 = Sesion(
          id: '1',
          modo: Modo.sesion,
          fase: Fase.calentamiento,
        );
        const sesion2 = Sesion(
          id: '1',
          modo: Modo.sesion,
          fase: Fase.calentamiento,
        );

        expect(sesion1, equals(sesion2));
        expect(sesion1.hashCode, equals(sesion2.hashCode));
      });

      test('different ids make sesiones not equal', () {
        const sesion1 = Sesion(id: '1', modo: Modo.sesion);
        const sesion2 = Sesion(id: '2', modo: Modo.sesion);

        expect(sesion1, isNot(equals(sesion2)));
      });

      test('different modos make sesiones not equal', () {
        const sesion1 = Sesion(id: '1', modo: Modo.sesion);
        const sesion2 = Sesion(id: '1', modo: Modo.libre);

        expect(sesion1, isNot(equals(sesion2)));
      });

      test('different fases make sesiones not equal', () {
        const sesion1 = Sesion(
          id: '1',
          modo: Modo.sesion,
          fase: Fase.calentamiento,
        );
        const sesion2 = Sesion(
          id: '1',
          modo: Modo.sesion,
          fase: Fase.climax,
        );

        expect(sesion1, isNot(equals(sesion2)));
      });
    });

    group('copyWith', () {
      test('creates copy with modified fields', () {
        const sesion = Sesion(
          id: '1',
          modo: Modo.sesion,
          fase: Fase.calentamiento,
        );

        final modified = sesion.copyWith(
          fase: Fase.climax,
          currentCardIndex: 3,
        );
        expect(modified.fase, Fase.climax);
        expect(modified.currentCardIndex, 3);
        expect(modified.id, '1');
        expect(modified.modo, Modo.sesion);
      });

      test('copyWith without args returns equal instance', () {
        const sesion = Sesion(id: '1', modo: Modo.sesion);

        expect(sesion.copyWith(), equals(sesion));
      });
    });
  });
}
