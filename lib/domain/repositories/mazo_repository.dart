import 'package:desea_mvp/domain/entities/mazo.dart';

/// Repositorio abstracto para acceder a entidades [Mazo].
///
/// Define el contrato para operaciones de datos de mazos que deben
/// ser implementado por fuentes de datos concretas.
abstract class MazoRepository {
  /// Retorna todos los mazos disponibles.
  Future<List<Mazo>> getMazos();

  /// Obtiene un mazo específico por su [id], o `null` si no existe.
  Future<Mazo?> getMazoById(String id);

  /// Crea un nuevo [mazo] y lo almacena.
  Future<void> crearMazo(Mazo mazo);

  /// Actualiza un [mazo] existente. Si no existe, lo crea (upsert).
  Future<void> actualizarMazo(Mazo mazo);

  /// Elimina el mazo con el [id] especificado.
  ///
  /// No lanza error si el [id] no existe.
  Future<void> eliminarMazo(String id);
}
