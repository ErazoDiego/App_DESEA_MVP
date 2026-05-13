import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/domain/entities/perfil.dart';

void main() {
  group('Perfil', () {
    final now = DateTime(2026, 5, 9);

    group('constructor', () {
      test('creates perfil with all required fields', () {
        final perfil = Perfil(
          id: '1',
          edad: 25,
          creadoEn: now,
        );

        expect(perfil.id, '1');
        expect(perfil.edad, 25);
        expect(perfil.onboardingCompletado, false);
        expect(perfil.settings, isEmpty);
        expect(perfil.creadoEn, now);
      });

      test('creates perfil with onboarding completado', () {
        final perfil = Perfil(
          id: '1',
          edad: 30,
          onboardingCompletado: true,
          creadoEn: now,
        );

        expect(perfil.onboardingCompletado, isTrue);
      });

      test('creates perfil with settings', () {
        final perfil = Perfil(
          id: '1',
          edad: 28,
          settings: {'notificaciones': true, 'idioma': 'es'},
          creadoEn: now,
        );

        expect(perfil.settings['notificaciones'], isTrue);
        expect(perfil.settings['idioma'], 'es');
      });
    });

    group('equality', () {
      test('perfiles with same values are equal', () {
        final p1 = Perfil(
          id: '1',
          edad: 25,
          onboardingCompletado: true,
          settings: {'tema': 'dark'},
          creadoEn: now,
        );
        final p2 = Perfil(
          id: '1',
          edad: 25,
          onboardingCompletado: true,
          settings: {'tema': 'dark'},
          creadoEn: now,
        );

        expect(p1, equals(p2));
        expect(p1.hashCode, equals(p2.hashCode));
      });

      test('different ids make perfiles not equal', () {
        final p1 = Perfil(id: '1', edad: 25, creadoEn: now);
        final p2 = Perfil(id: '2', edad: 25, creadoEn: now);

        expect(p1, isNot(equals(p2)));
      });

      test('different edades make perfiles not equal', () {
        final p1 = Perfil(id: '1', edad: 25, creadoEn: now);
        final p2 = Perfil(id: '1', edad: 30, creadoEn: now);

        expect(p1, isNot(equals(p2)));
      });
    });

    group('copyWith', () {
      test('creates copy with modified fields', () {
        final perfil = Perfil(
          id: '1',
          edad: 25,
          creadoEn: now,
        );

        final modified = perfil.copyWith(
          edad: 30,
          onboardingCompletado: true,
        );
        expect(modified.edad, 30);
        expect(modified.onboardingCompletado, isTrue);
        expect(modified.id, '1');
        expect(modified.creadoEn, now);
      });

      test('copyWith without args returns equal instance', () {
        final perfil = Perfil(id: '1', edad: 25, creadoEn: now);

        expect(perfil.copyWith(), equals(perfil));
      });
    });
  });
}
