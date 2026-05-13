import 'package:desea_mvp/domain/entities/sesion.dart';

/// Repositorio abstracto para acceder a entidades [Sesion].
///
/// Define el contrato para operaciones de datos de sesiones que deben
/// ser implementado por fuentes de datos concretas.
abstract class SesionRepository {
  /// Crea una nueva sesión y la persiste en el almacenamiento.
  Future<Sesion> crearSesion(Sesion sesion);

  /// Actualiza el estado de una sesión existente.
  Future<void> actualizarSesion(Sesion sesion);

  /// Obtiene la sesión activa actual, o `null` si no hay ninguna.
  Future<Sesion?> getSesionActiva();
}
