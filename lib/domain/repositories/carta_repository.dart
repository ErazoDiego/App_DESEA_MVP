import 'package:desea_mvp/domain/entities/carta.dart';

/// Repositorio abstracto para acceder a entidades [Carta].
///
/// Define el contrato para operaciones de datos de cartas que deben
/// ser implementado por fuentes de datos concretas.
abstract class CartaRepository {
  /// Retorna todas las cartas disponibles.
  Future<List<Carta>> getCartas();

  /// Obtiene una carta específica por su [id], o `null` si no existe.
  Future<Carta?> getCartaById(String id);
}
