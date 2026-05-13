import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/data/models/mazo_model.dart';
import 'package:desea_mvp/domain/entities/mazo.dart';

void main() {
  group('MazoModel', () {
    group('fromEntity', () {
      test('creates correct model from entity with default values', () {
        const entity = Mazo(
          id: '1',
          nombre: 'Picante',
        );

        final model = MazoModel.fromEntity(entity);

        expect(model.id, '1');
        expect(model.nombre, 'Picante');
        expect(model.nivel, 'suave');
        expect(model.cartaIds, []);
      });

      test('creates model with all fields populated', () {
        const entity = Mazo(
          id: '2',
          nombre: 'Intenso',
          nivel: Nivel.intenso,
          cartaIds: ['a', 'b', 'c'],
        );

        final model = MazoModel.fromEntity(entity);

        expect(model.id, '2');
        expect(model.nombre, 'Intenso');
        expect(model.nivel, 'intenso');
        expect(model.cartaIds, ['a', 'b', 'c']);
      });
    });

    group('toEntity', () {
      test('creates correct domain entity from model', () {
        const model = MazoModel(
          id: '1',
          nombre: 'Suave',
          nivel: 'suave',
        );

        final entity = model.toEntity();

        expect(entity.id, '1');
        expect(entity.nombre, 'Suave');
        expect(entity.nivel, Nivel.suave);
        expect(entity.cartaIds, []);
      });

      test('creates entity with all fields from model', () {
        const model = MazoModel(
          id: '2',
          nombre: 'Intenso',
          nivel: 'intenso',
          cartaIds: ['x', 'y'],
        );

        final entity = model.toEntity();

        expect(entity.id, '2');
        expect(entity.nombre, 'Intenso');
        expect(entity.nivel, Nivel.intenso);
        expect(entity.cartaIds, ['x', 'y']);
      });
    });

    group('round-trip', () {
      test('entity -> model -> entity preserves all values', () {
        const entity = Mazo(
          id: '1',
          nombre: 'Picante',
          nivel: Nivel.picante,
          cartaIds: ['c1', 'c2', 'c3'],
        );

        final model = MazoModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
      });

      test('default Nivel.suave after round-trip', () {
        const entity = Mazo(
          id: '2',
          nombre: 'Default',
        );

        expect(entity.nivel, Nivel.suave);

        final model = MazoModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
        expect(result.nivel, Nivel.suave);
      });

      test('round-trip preserves empty cartaIds', () {
        const entity = Mazo(
          id: '3',
          nombre: 'Empty',
          cartaIds: [],
        );

        final model = MazoModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
        expect(result.cartaIds, isEmpty);
      });
    });
  });
}
