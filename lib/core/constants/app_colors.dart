import 'package:flutter/material.dart';

/// Paleta de colores centralizada para la aplicación DESEA.
///
/// Define los colores base usados en todo el tema de la app.
/// Todos los colores son constantes [Color] de Material.
class AppColors {
  AppColors._();

  /// Color de fondo profundo oscuro, casi negro con un toque violeta.
  static const Color background = Color(0xFF07000F);

  /// Acento fucsia vibrante usado en elementos UI primarios.
  static const Color fuchsiaAccent = Color(0xFFA21CAF);

  /// Color de superficie para tarjetas, paneles y contenedores elevados.
  static const Color surface = Color(0xFF1A1A2E);

  /// Color de texto primario sobre fondos de superficie.
  static const Color onSurface = Color(0xFFE0E0E0);

  /// Color de texto secundario para contenido menos prominente.
  static const Color onSurfaceSecondary = Color(0xFF9E9E9E);
}
