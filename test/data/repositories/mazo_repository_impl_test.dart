import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/models/mazo_model.dart';
import 'package:desea_mvp/data/repositories/mazo_repository_impl.dart';
import 'package:desea_mvp/domain/entities/mazo.dart';
import 'package:desea_mvp/hive_registrar.g.dart';
import 'dart:io';

void main() {
  late Directory tempDir;
  late Box<MazoModel> box;
  late MazoRepositoryImpl repository;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_test_mr_');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  setUp(() async {
    box = await Hive.openBox<MazoModel>('test_mazos');
    repository = MazoRepositoryImpl(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('test_mazos');
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('crearMazo', () {
    test('creates and stores a new mazo', () async {
      const mazo = Mazo(
        id: '1',
        nombre: 'Mazo nuevo',
        nivel: Nivel.suave,
        cartaIds: ['a', 'b'],
      );

      await repository.crearMazo(mazo);

      final stored = box.get('1');
      expect(stored, isNotNull);
      expect(stored?.nombre, 'Mazo nuevo');
      expect(stored?.nivel, 'suave');
      expect(stored?.cartaIds, ['a', 'b']);
    });

    test('added mazo is retrievable via getMazos', () async {
      const mazo = Mazo(
        id: '1',
        nombre: 'Mazo test',
        nivel: Nivel.intenso,
      );

      await repository.crearMazo(mazo);

      final mazos = await repository.getMazos();
      expect(mazos.length, 1);
      expect(mazos.first.id, '1');
      expect(mazos.first.nombre, 'Mazo test');
    });
  });

  group('actualizarMazo', () {
    test('updates an existing mazo', () async {
      const original = Mazo(
        id: '1',
        nombre: 'Original',
        nivel: Nivel.suave,
        cartaIds: ['a'],
      );
      await repository.crearMazo(original);

      const updated = Mazo(
        id: '1',
        nombre: 'Actualizado',
        nivel: Nivel.picante,
        cartaIds: ['a', 'b', 'c'],
      );
      await repository.actualizarMazo(updated);

      final stored = box.get('1');
      expect(stored, isNotNull);
      expect(stored?.nombre, 'Actualizado');
      expect(stored?.nivel, 'picante');
      expect(stored?.cartaIds, ['a', 'b', 'c']);
    });

    test('creates mazo if it does not exist (upsert behavior)', () async {
      const mazo = Mazo(
        id: 'new',
        nombre: 'Nuevo por upsert',
        nivel: Nivel.intenso,
      );

      await repository.actualizarMazo(mazo);

      final stored = box.get('new');
      expect(stored, isNotNull);
      expect(stored?.nombre, 'Nuevo por upsert');
    });

    test('update is reflected in getAll', () async {
      const original = Mazo(
        id: '1',
        nombre: 'Antes',
        nivel: Nivel.suave,
      );
      await repository.crearMazo(original);

      const updated = Mazo(
        id: '1',
        nombre: 'Después',
        nivel: Nivel.intenso,
      );
      await repository.actualizarMazo(updated);

      final allMazos = await repository.getMazos();
      expect(allMazos.length, 1);
      expect(allMazos.first.nombre, 'Después');
    });
  });

  group('eliminarMazo', () {
    test('deletes an existing mazo', () async {
      const mazo = Mazo(
        id: '1',
        nombre: 'Para borrar',
        nivel: Nivel.picante,
      );
      await repository.crearMazo(mazo);

      await repository.eliminarMazo('1');

      final stored = box.get('1');
      expect(stored, isNull);
    });

    test('delete does not throw when id does not exist', () async {
      await repository.eliminarMazo('nonexistent');

      // Should not throw — implied by passing
      expect(true, isTrue);
    });

    test('delete removes only the specified mazo', () async {
      const mazo1 = Mazo(id: '1', nombre: 'Uno', nivel: Nivel.suave);
      const mazo2 = Mazo(id: '2', nombre: 'Dos', nivel: Nivel.picante);
      await repository.crearMazo(mazo1);
      await repository.crearMazo(mazo2);

      await repository.eliminarMazo('1');

      final mazos = await repository.getMazos();
      expect(mazos.length, 1);
      expect(mazos.first.id, '2');
    });
  });
}
