import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/data/models/perfil_model.dart';
import 'package:desea_mvp/domain/entities/perfil.dart';

void main() {
  group('PerfilModel', () {
    group('fromEntity', () {
      test('creates correct model from entity with default values', () {
        final entity = Perfil(
          id: '1',
          edad: 30,
          creadoEn: DateTime(2026, 1, 1),
        );

        final model = PerfilModel.fromEntity(entity);

        expect(model.id, '1');
        expect(model.edad, 30);
        expect(model.onboardingCompletado, false);
        expect(model.settings, {});
        expect(model.creadoEn, DateTime(2026, 1, 1));
      });

      test('creates model with all fields populated', () {
        final entity = Perfil(
          id: '2',
          edad: 25,
          onboardingCompletado: true,
          settings: {'theme': 'dark', 'language': 'es'},
          creadoEn: DateTime(2026, 5, 9, 10, 30),
        );

        final model = PerfilModel.fromEntity(entity);

        expect(model.id, '2');
        expect(model.edad, 25);
        expect(model.onboardingCompletado, true);
        expect(model.settings['theme'], 'dark');
        expect(model.settings['language'], 'es');
        expect(model.creadoEn, DateTime(2026, 5, 9, 10, 30));
      });
    });

    group('toEntity', () {
      test('creates correct domain entity from model with defaults', () {
        final model = PerfilModel(
          id: '1',
          edad: 30,
          creadoEn: DateTime(2026, 1, 1),
        );

        final entity = model.toEntity();

        expect(entity.id, '1');
        expect(entity.edad, 30);
        expect(entity.onboardingCompletado, false);
        expect(entity.settings, {});
        expect(entity.creadoEn, DateTime(2026, 1, 1));
      });

      test('creates entity with all fields from model', () {
        final model = PerfilModel(
          id: '2',
          edad: 25,
          onboardingCompletado: true,
          settings: {'theme': 'dark'},
          creadoEn: DateTime(2026, 5, 9),
        );

        final entity = model.toEntity();

        expect(entity.id, '2');
        expect(entity.edad, 25);
        expect(entity.onboardingCompletado, true);
        expect(entity.settings['theme'], 'dark');
        expect(entity.creadoEn, DateTime(2026, 5, 9));
      });
    });

    group('round-trip', () {
      test('entity -> model -> entity preserves all values', () {
        final entity = Perfil(
          id: '1',
          edad: 30,
          onboardingCompletado: true,
          settings: {'theme': 'dark', 'notificaciones': true},
          creadoEn: DateTime(2026, 5, 9),
        );

        final model = PerfilModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
      });

      test('default onboardingCompletado is false after round-trip', () {
        final entity = Perfil(
          id: '2',
          edad: 25,
          creadoEn: DateTime(2026, 1, 1),
        );

        expect(entity.onboardingCompletado, false);

        final model = PerfilModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
        expect(result.onboardingCompletado, false);
      });

      test('round-trip preserves empty settings', () {
        final entity = Perfil(
          id: '3',
          edad: 35,
          settings: {},
          creadoEn: DateTime(2026, 3, 15),
        );

        final model = PerfilModel.fromEntity(entity);
        final result = model.toEntity();

        expect(result, equals(entity));
        expect(result.settings, isEmpty);
      });
    });
  });
}
