import 'package:desea_mvp/domain/entities/perfil.dart';
import 'package:desea_mvp/domain/repositories/perfil_repository.dart';

/// Fake repository con estado mutable para tests de onboarding.
///
/// Percibe un [Perfil] opcional y mantiene estado interno,
/// permitiendo verificar interacciones de lectura/escritura
/// sin necesidad de Hive o persistencia real.
///
/// Soporta [shouldThrowOnGet] para simular errores en getPerfil(),
/// permitiendo testear el flujo de creación inicial de Perfil.
class FakePerfilRepository implements PerfilRepository {
  Perfil _perfil;
  final bool _shouldThrowOnGet;
  bool _getPerfilCalled;
  Perfil? _ultimoPerfilGuardado;

  FakePerfilRepository({
    Perfil? perfil,
    bool shouldThrowOnGet = false,
  })  : _perfil = perfil ?? Perfil(
          id: 'default',
          edad: 25,
          creadoEn: DateTime(2026, 5, 9),
        ),
        _shouldThrowOnGet = shouldThrowOnGet,
        _getPerfilCalled = false;

  @override
  Future<Perfil> getPerfil() async {
    _getPerfilCalled = true;
    if (_shouldThrowOnGet) {
      throw Exception('No profile found');
    }
    return _perfil;
  }

  @override
  Future<bool> hasCompletadoOnboarding() async => _perfil.onboardingCompletado;

  @override
  Future<void> guardarPerfil(Perfil perfil) async {
    _ultimoPerfilGuardado = perfil;
    _perfil = perfil;
  }

  /// Retorna `true` si [getPerfil] fue invocado al menos una vez.
  bool get wasGetPerfilCalled => _getPerfilCalled;

  /// Retorna el último [Perfil] pasado a [guardarPerfil], o `null` si nunca
  /// se llamó.
  Perfil? get ultimoPerfilGuardado => _ultimoPerfilGuardado;
}
