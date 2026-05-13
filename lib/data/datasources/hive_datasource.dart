import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../hive_registrar.g.dart';
import '../models/carta_model.dart';
import '../models/carta_guardada_model.dart';
import '../models/carta_personalizada_model.dart';
import '../models/mazo_model.dart';
import '../models/perfil_model.dart';
import '../models/sesion_model.dart';
import 'card_seed.dart';

bool _hiveInitialized = false;

/// Initialize Hive CE for the application.
///
/// Safe to call multiple times — uses an internal flag to prevent
/// re-initialization after the first successful call.
/// Also safe if Hive was already initialized manually (e.g. in tests).
Future<void> initHive() async {
  if (_hiveInitialized) return;

  try {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
  } catch (_) {
    // In tests or environments without Flutter binding,
    // Hive is typically initialized manually beforehand.
  }

  try {
    Hive.registerAdapters();
  } catch (_) {
    // Adaptadores ya registrados (tests o segunda llamada).
  }

  _hiveInitialized = true;
}

/// Open all application boxes and seed initial cartas.
///
/// Call this from main() BEFORE runApp() to guarantee that every
/// box FutureProvider resolves synchronously on the first frame —
/// eliminating the flash of error/white screen at startup.
Future<void> openAllBoxes() async {
  await Future.wait([
    Hive.openBox<CartaModel>('cartas'),
    Hive.openBox<CartaGuardadaModel>('guardadas'),
    Hive.openBox<CartaPersonalizadaModel>('personalizadas'),
    Hive.openBox<MazoModel>('mazos'),
    Hive.openBox<PerfilModel>('perfil'),
    Hive.openBox<SesionModel>('sesiones'),
  ]);

  // Seed bundled cartas (one-time, only if box is empty).
  final cartasBox = Hive.box<CartaModel>('cartas');
  await seedCartasIfNeeded(cartasBox);
}

// ---------------------------------------------------------------------------
// Box providers
// ---------------------------------------------------------------------------

final perfilBoxProvider = FutureProvider<Box<PerfilModel>>((ref) async {
  await initHive();
  return Hive.openBox<PerfilModel>('perfil');
});

final cartaBoxProvider = FutureProvider<Box<CartaModel>>((ref) async {
  await initHive();
  return Hive.openBox<CartaModel>('cartas');
});

/// Seeds the cartas box from bundled JSON. Must be called after
/// [cartaBoxProvider] resolves (i.e. after the box is open).
final seedCartasProvider = FutureProvider<void>((ref) async {
  final box = await ref.watch(cartaBoxProvider.future);
  await seedCartasIfNeeded(box);
});

final mazoBoxProvider = FutureProvider<Box<MazoModel>>((ref) async {
  await initHive();
  return Hive.openBox<MazoModel>('mazos');
});

final sesionBoxProvider = FutureProvider<Box<SesionModel>>((ref) async {
  await initHive();
  return Hive.openBox<SesionModel>('sesiones');
});

final guardadasBoxProvider = FutureProvider<Box<CartaGuardadaModel>>((ref) async {
  await initHive();
  return Hive.openBox<CartaGuardadaModel>('guardadas');
});

final personalizadasBoxProvider
    = FutureProvider<Box<CartaPersonalizadaModel>>((ref) async {
  await initHive();
  return Hive.openBox<CartaPersonalizadaModel>('personalizadas');
});


