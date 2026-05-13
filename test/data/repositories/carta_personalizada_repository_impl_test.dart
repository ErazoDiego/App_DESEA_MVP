import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/models/carta_personalizada_model.dart';
import 'package:desea_mvp/data/repositories/carta_personalizada_repository_impl.dart';
import 'package:desea_mvp/domain/entities/carta_personalizada.dart';
import 'package:desea_mvp/hive_registrar.g.dart';
import 'dart:io';

void main() {
  late Directory tempDir;
  late Box<CartaPersonalizadaModel> box;
  late CartaPersonalizadaRepositoryImpl repository;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_test_cpr_');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  setUp(() async {
    box = await Hive.openBox<CartaPersonalizadaModel>('test_personalizadas');
    repository = CartaPersonalizadaRepositoryImpl(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('test_personalizadas');
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('getAll', () {
    test('returns empty list when no cards exist', () async {
      final cards = await repository.getAll();

      expect(cards, isEmpty);
    });

    test('returns all stored cards', () async {
      final now = DateTime(2026, 5, 11);
      final model1 = CartaPersonalizadaModel(
        id: '1',
        texto: 'Primera carta',
        nivel: 'suave',
        creadaEn: now,
      );
      final model2 = CartaPersonalizadaModel(
        id: '2',
        texto: 'Segunda carta',
        nivel: 'picante',
        creadaEn: now,
      );
      await box.put('1', model1);
      await box.put('2', model2);

      final cards = await repository.getAll();

      expect(cards.length, 2);
      expect(cards.any((c) => c.id == '1' && c.texto == 'Primera carta'),
          isTrue);
      expect(cards.any((c) => c.id == '2' && c.texto == 'Segunda carta'),
          isTrue);
    });

    test('returns entities mapped from models', () async {
      final now = DateTime(2026, 5, 11);
      final model = CartaPersonalizadaModel(
        id: '1',
        texto: 'Test',
        categoria: 'verdad',
        nivel: 'intenso',
        tiempoSegundos: 30,
        dirigida: 'paraEl',
        creadaEn: now,
      );
      await box.put('1', model);

      final cards = await repository.getAll();

      expect(cards.length, 1);
      expect(cards.first.id, '1');
      expect(cards.first.categoria, 'verdad');
      expect(cards.first.nivel, 'intenso');
      expect(cards.first.tiempoSegundos, const Duration(seconds: 30));
      expect(cards.first.dirigida, 'paraEl');
    });
  });

  group('save', () {
    test('saves a new carta to the box', () async {
      final now = DateTime(2026, 5, 11);
      final carta = CartaPersonalizada(
        id: '1',
        texto: 'Nueva carta',
        nivel: 'suave',
        creadaEn: now,
      );

      await repository.save(carta);

      final stored = box.get('1');
      expect(stored, isNotNull);
      expect(stored?.texto, 'Nueva carta');
    });

    test('updates an existing carta', () async {
      final now = DateTime(2026, 5, 11);
      final original = CartaPersonalizada(
        id: '1',
        texto: 'Original',
        nivel: 'suave',
        creadaEn: now,
      );
      await repository.save(original);

      final updated = CartaPersonalizada(
        id: '1',
        texto: 'Actualizada',
        nivel: 'intenso',
        creadaEn: now,
      );
      await repository.save(updated);

      final stored = box.get('1');
      expect(stored, isNotNull);
      expect(stored?.texto, 'Actualizada');
      expect(stored?.nivel, 'intenso');
    });

    test('can save and retrieve multiple cards', () async {
      final now = DateTime(2026, 5, 11);
      for (var i = 0; i < 5; i++) {
        await repository.save(CartaPersonalizada(
          id: '$i',
          texto: 'Carta $i',
          nivel: 'suave',
          creadaEn: now,
        ));
      }

      final cards = await repository.getAll();
      expect(cards.length, 5);
    });
  });

  group('delete', () {
    test('deletes an existing card', () async {
      final now = DateTime(2026, 5, 11);
      await repository.save(CartaPersonalizada(
        id: '1',
        texto: 'Para borrar',
        nivel: 'suave',
        creadaEn: now,
      ));

      await repository.delete('1');

      final stored = box.get('1');
      expect(stored, isNull);
    });

    test('delete does not throw when id does not exist', () async {
      await repository.delete('nonexistent');

      // Should not throw — implied by passing
      expect(true, isTrue);
    });

    test('delete removes only the specified card', () async {
      final now = DateTime(2026, 5, 11);
      await repository.save(CartaPersonalizada(
        id: '1',
        texto: 'Keep',
        nivel: 'suave',
        creadaEn: now,
      ));
      await repository.save(CartaPersonalizada(
        id: '2',
        texto: 'Remove',
        nivel: 'picante',
        creadaEn: now,
      ));

      await repository.delete('2');

      final cards = await repository.getAll();
      expect(cards.length, 1);
      expect(cards.first.id, '1');
    });
  });
}
