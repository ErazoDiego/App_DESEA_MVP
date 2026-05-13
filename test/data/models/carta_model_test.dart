import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/data/models/carta_model.dart';
import 'package:desea_mvp/domain/entities/carta.dart';

void main() {
  group('CartaModel', () {
    group('fromEntity', () {
      test('creates correct model with string enum values', () {
        const entity = Carta(
          id: '1',
          tipo: TipoCarta.verdad,
          texto: 'Di tu secreto más vergonzoso',
          dirigida: Dirigida.mixta,
        );

        final model = CartaModel.fromEntity(entity);

        expect(model.id, '1');
        expect(model.tipo, 'verdad');
        expect(model.texto, 'Di tu secreto más vergonzoso');
        expect(model.dirigida, 'mixta');
        expect(model.tiempoSegundos, isNull);
      });

      test('converts Duration to seconds', () {
        const entity = Carta(
          id: '2',
          tipo: TipoCarta.reto,
          texto: 'Besa por 30 segundos',
          dirigida: Dirigida.paraElla,
          tiempoSegundos: Duration(seconds: 30),
        );

        final model = CartaModel.fromEntity(entity);

        expect(model.tiempoSegundos, 30);
      });
    });

    group('toEntity', () {
      test('creates correct domain entity with enum values', () {
        const model = CartaModel(
          id: '1',
          tipo: 'verdad',
          texto: 'Di tu secreto',
          dirigida: 'mixta',
        );

        final entity = model.toEntity();

        expect(entity.id, '1');
        expect(entity.tipo, TipoCarta.verdad);
        expect(entity.texto, 'Di tu secreto');
        expect(entity.dirigida, Dirigida.mixta);
        expect(entity.tiempoSegundos, isNull);
      });

      test('converts seconds back to Duration', () {
        const model = CartaModel(
          id: '2',
          tipo: 'reto',
          texto: 'Besa por 30 segundos',
          dirigida: 'paraElla',
          tiempoSegundos: 30,
        );

        final entity = model.toEntity();

        expect(entity.tiempoSegundos, Duration(seconds: 30));
      });
    });

    group('round-trip', () {
      test('entity -> model -> entity preserves all values', () {
        const entity = Carta(
          id: '1',
          tipo: TipoCarta.deseo,
          texto: 'Texto de prueba con tiempo',
          dirigida: Dirigida.paraEl,
          tiempoSegundos: Duration(seconds: 60),
        );

        final model = CartaModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
        expect(result.tiempoSegundos, Duration(seconds: 60));
      });

      test('round-trip with null tiempoSegundos', () {
        const entity = Carta(
          id: '2',
          tipo: TipoCarta.verdad,
          texto: 'Sin límite de tiempo',
          dirigida: Dirigida.mixta,
        );

        final model = CartaModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
        expect(result.tiempoSegundos, isNull);
      });

      test('round-trip with all enum variants', () {
        final entities = [
          const Carta(
            id: 'a',
            tipo: TipoCarta.verdad,
            texto: 'Verdad',
            dirigida: Dirigida.mixta,
          ),
          const Carta(
            id: 'b',
            tipo: TipoCarta.reto,
            texto: 'Reto',
            dirigida: Dirigida.paraEl,
          ),
          const Carta(
            id: 'c',
            tipo: TipoCarta.deseo,
            texto: 'Deseo',
            dirigida: Dirigida.paraElla,
          ),
        ];

        for (final entity in entities) {
          final model = CartaModel.fromEntity(entity);
          final result = model.toEntity();
          expect(result, equals(entity),
              reason: 'Failed for ${entity.tipo}/${entity.dirigida}');
        }
      });
    });
  });
}
