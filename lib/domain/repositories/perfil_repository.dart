import 'package:desea_mvp/domain/entities/perfil.dart';

/// Repositorio abstracto para acceder a entidades [Perfil].
///
/// Define el contrato para operaciones de datos del perfil de usuario
/// que deben ser implementado por fuentes de datos concretas.
abstract class PerfilRepository {
  /// Obtiene el perfil del usuario.
  ///
  /// Lanza una [Exception] si no se ha creado ningún perfil aún.
  Future<Perfil> getPerfil();

  /// Persiste el [perfil] proporcionado en el almacenamiento.
  Future<void> guardarPerfil(Perfil perfil);

  /// Retorna si el usuario ha completado el flujo de onboarding.
  Future<bool> hasCompletadoOnboarding();
}
