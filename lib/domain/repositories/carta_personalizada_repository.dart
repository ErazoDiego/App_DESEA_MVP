import 'package:desea_mvp/domain/entities/carta_personalizada.dart';

/// Repositorio abstracto para acceder a entidades [CartaPersonalizada].
///
/// Define el contrato para operaciones CRUD de cartas personalizadas del
/// modo libre, que deben ser implementado por fuentes de datos concretas.
abstract class CartaPersonalizadaRepository {
  /// Retorna todas las cartas personalizadas almacenadas.
  Future<List<CartaPersonalizada>> getAll();

  /// Guarda una [carta] personalizada. Si ya existe con el mismo [id],
  /// la sobrescribe.
  Future<void> save(CartaPersonalizada carta);

  /// Elimina la carta personalizada con el [id] especificado.
  ///
  /// No lanza error si el [id] no existe.
  Future<void> delete(String id);
}
