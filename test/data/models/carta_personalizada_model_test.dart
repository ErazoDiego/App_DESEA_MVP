import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/data/models/carta_personalizada_model.dart';
import 'package:desea_mvp/domain/entities/carta_personalizada.dart';

void main() {
  group('CartaPersonalizadaModel', () {
    final now = DateTime(2026, 5, 11, 10, 30);

    group('fromEntity', () {
      test('creates correct model with default optional values', () {
        final entity = CartaPersonalizada(
          id: '1',
          texto: 'Di tu secreto',
          nivel: 'suave',
          creadaEn: now,
        );

        final model = CartaPersonalizadaModel.fromEntity(entity);

        expect(model.id, '1');
        expect(model.texto, 'Di tu secreto');
        expect(model.nivel, 'suave');
        expect(model.creadaEn, now);
        expect(model.categoria, isNull);
        expect(model.tiempoSegundos, isNull);
        expect(model.dirigida, isNull);
      });

      test('creates model with all fields populated', () {
        final entity = CartaPersonalizada(
          id: '2',
          texto: 'Cuenta un secreto',
          categoria: 'verdad',
          nivel: 'picante',
          tiempoSegundos: const Duration(seconds: 60),
          dirigida: 'paraEl',
          creadaEn: now,
        );

        final model = CartaPersonalizadaModel.fromEntity(entity);

        expect(model.id, '2');
        expect(model.texto, 'Cuenta un secreto');
        expect(model.categoria, 'verdad');
        expect(model.nivel, 'picante');
        expect(model.tiempoSegundos, 60);
        expect(model.dirigida, 'paraEl');
        expect(model.creadaEn, now);
      });

      test('converts Duration to seconds', () {
        final entity = CartaPersonalizada(
          id: '3',
          texto: 'Besa por 30 segundos',
          nivel: 'picante',
          tiempoSegundos: const Duration(seconds: 30),
          creadaEn: now,
        );

        final model = CartaPersonalizadaModel.fromEntity(entity);

        expect(model.tiempoSegundos, 30);
      });
    });

    group('toEntity', () {
      test('creates correct domain entity with default values', () {
        final model = CartaPersonalizadaModel(
          id: '1',
          texto: 'Di tu secreto',
          nivel: 'suave',
          creadaEn: now,
        );

        final entity = model.toEntity();

        expect(entity.id, '1');
        expect(entity.texto, 'Di tu secreto');
        expect(entity.nivel, 'suave');
        expect(entity.creadaEn, now);
        expect(entity.categoria, isNull);
        expect(entity.tiempoSegundos, isNull);
        expect(entity.dirigida, isNull);
      });

      test('creates entity with all fields from model', () {
        final model = CartaPersonalizadaModel(
          id: '2',
          texto: 'Cuenta un secreto',
          categoria: 'verdad',
          nivel: 'picante',
          tiempoSegundos: 60,
          dirigida: 'paraEl',
          creadaEn: now,
        );

        final entity = model.toEntity();

        expect(entity.id, '2');
        expect(entity.texto, 'Cuenta un secreto');
        expect(entity.categoria, 'verdad');
        expect(entity.nivel, 'picante');
        expect(entity.tiempoSegundos, const Duration(seconds: 60));
        expect(entity.dirigida, 'paraEl');
        expect(entity.creadaEn, now);
      });

      test('converts seconds back to Duration', () {
        final model = CartaPersonalizadaModel(
          id: '3',
          texto: 'Besa por 30 segundos',
          nivel: 'picante',
          tiempoSegundos: 30,
          creadaEn: now,
        );

        final entity = model.toEntity();

        expect(entity.tiempoSegundos, const Duration(seconds: 30));
      });
    });

    group('round-trip', () {
      test('entity -> model -> entity preserves all values', () {
        final entity = CartaPersonalizada(
          id: '1',
          texto: 'Texto de prueba con tiempo',
          categoria: 'deseo',
          nivel: 'intenso',
          tiempoSegundos: const Duration(seconds: 90),
          dirigida: 'paraElla',
          creadaEn: now,
        );

        final model = CartaPersonalizadaModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
        expect(result.tiempoSegundos, const Duration(seconds: 90));
      });

      test('round-trip with null optional fields', () {
        final entity = CartaPersonalizada(
          id: '2',
          texto: 'Sin opcionales',
          nivel: 'suave',
          creadaEn: now,
        );

        final model = CartaPersonalizadaModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
        expect(result.categoria, isNull);
        expect(result.tiempoSegundos, isNull);
        expect(result.dirigida, isNull);
      });

      test('round-trip with categoria sinLimites', () {
        final entity = CartaPersonalizada(
          id: '3',
          texto: 'Sin límites',
          categoria: 'sinLimites',
          nivel: 'intenso',
          creadaEn: now,
        );

        final model = CartaPersonalizadaModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
        expect(result.categoria, 'sinLimites');
      });

      test('round-trip preserves DateTime', () {
        final entity = CartaPersonalizada(
          id: '4',
          texto: 'Con fecha',
          nivel: 'picante',
          creadaEn: now,
        );

        final model = CartaPersonalizadaModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result.creadaEn, now);
        expect(result.creadaEn, equals(entity.creadaEn));
      });
    });
  });
}
