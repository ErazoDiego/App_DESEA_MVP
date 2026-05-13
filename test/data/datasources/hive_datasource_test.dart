import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:desea_mvp/data/datasources/hive_datasource.dart';
import 'package:desea_mvp/data/models/carta_model.dart';
import 'package:desea_mvp/data/models/mazo_model.dart';
import 'package:desea_mvp/data/models/perfil_model.dart';
import 'package:desea_mvp/data/models/sesion_model.dart';
import 'package:desea_mvp/data/models/carta_personalizada_model.dart';
import 'package:desea_mvp/hive_registrar.g.dart';
import 'dart:io';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapters();
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Hive initialization', () {
    test('opens a properly typed box after initialization', () async {
      final box = await Hive.openBox<CartaModel>('test_cartas');
      expect(box, isA<Box<CartaModel>>());
      await box.close();
    });
  });

  group('Box providers', () {
    test('cartaBoxProvider is a FutureProvider<Box<CartaModel>>', () {
      expect(cartaBoxProvider, isA<FutureProvider<Box<CartaModel>>>());
    });

    test('mazoBoxProvider is a FutureProvider<Box<MazoModel>>', () {
      expect(mazoBoxProvider, isA<FutureProvider<Box<MazoModel>>>());
    });

    test('perfilBoxProvider is a FutureProvider<Box<PerfilModel>>', () {
      expect(perfilBoxProvider, isA<FutureProvider<Box<PerfilModel>>>());
    });

    test('sesionBoxProvider is a FutureProvider<Box<SesionModel>>', () {
      expect(sesionBoxProvider, isA<FutureProvider<Box<SesionModel>>>());
    });

    test(
        'personalizadasBoxProvider is a FutureProvider<Box<CartaPersonalizadaModel>>',
        () {
      expect(personalizadasBoxProvider,
          isA<FutureProvider<Box<CartaPersonalizadaModel>>>());
    });
  });
}
