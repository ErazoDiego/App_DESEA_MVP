import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/data/models/sesion_model.dart';
import 'package:desea_mvp/domain/entities/sesion.dart';

void main() {
  group('SesionModel', () {
    group('fromEntity', () {
      test('creates correct model from entity with default values', () {
        const entity = Sesion(
          id: '1',
        );

        final model = SesionModel.fromEntity(entity);

        expect(model.id, '1');
        expect(model.modo, 'sesion');
        expect(model.fase, 'calentamiento');
        expect(model.currentCardIndex, 0);
        expect(model.cartasUsadasIds, []);
        expect(model.iniciadaEn, isNull);
        expect(model.completadaEn, isNull);
      });

      test('creates model with all fields populated', () {
        final entity = Sesion(
          id: '2',
          modo: Modo.libre,
          fase: Fase.climax,
          currentCardIndex: 5,
          cartasUsadasIds: ['a', 'b', 'c'],
          iniciadaEn: DateTime(2026, 5, 9),
          completadaEn: DateTime(2026, 5, 9, 2, 30),
        );

        final model = SesionModel.fromEntity(entity);

        expect(model.id, '2');
        expect(model.modo, 'libre');
        expect(model.fase, 'climax');
        expect(model.currentCardIndex, 5);
        expect(model.cartasUsadasIds, ['a', 'b', 'c']);
        expect(model.iniciadaEn, DateTime(2026, 5, 9));
        expect(model.completadaEn, DateTime(2026, 5, 9, 2, 30));
      });
    });

    group('toEntity', () {
      test('creates correct domain entity from model with defaults', () {
        const model = SesionModel(
          id: '1',
          modo: 'sesion',
          fase: 'calentamiento',
        );

        final entity = model.toEntity();

        expect(entity.id, '1');
        expect(entity.modo, Modo.sesion);
        expect(entity.fase, Fase.calentamiento);
        expect(entity.currentCardIndex, 0);
        expect(entity.cartasUsadasIds, []);
        expect(entity.iniciadaEn, isNull);
        expect(entity.completadaEn, isNull);
      });

      test('creates entity with all fields from model', () {
        const model = SesionModel(
          id: '2',
          modo: 'libre',
          fase: 'tension',
          currentCardIndex: 3,
          cartasUsadasIds: ['x', 'y'],
          iniciadaEn: null,
          completadaEn: null,
        );

        final entity = model.toEntity();

        expect(entity.id, '2');
        expect(entity.modo, Modo.libre);
        expect(entity.fase, Fase.tension);
        expect(entity.currentCardIndex, 3);
        expect(entity.cartasUsadasIds, ['x', 'y']);
      });
    });

    group('round-trip', () {
      test('entity -> model -> entity preserves all values', () {
        final entity = Sesion(
          id: '1',
          modo: Modo.libre,
          fase: Fase.cierre,
          currentCardIndex: 10,
          cartasUsadasIds: ['c1', 'c2'],
          iniciadaEn: DateTime(2026, 5, 9),
          completadaEn: DateTime(2026, 5, 9, 1, 0),
        );

        final model = SesionModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
      });

      test('default Fase.calentamiento and Modo.sesion after round-trip', () {
        const entity = Sesion(
          id: '2',
        );

        expect(entity.modo, Modo.sesion);
        expect(entity.fase, Fase.calentamiento);

        final model = SesionModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
        expect(result.modo, Modo.sesion);
        expect(result.fase, Fase.calentamiento);
      });

      test('round-trip with optional dates null', () {
        const entity = Sesion(
          id: '3',
        );

        final model = SesionModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
        expect(result.iniciadaEn, isNull);
        expect(result.completadaEn, isNull);
      });
    });
  });
}
