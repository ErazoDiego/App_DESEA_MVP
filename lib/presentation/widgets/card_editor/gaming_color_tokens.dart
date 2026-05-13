import 'package:flutter/material.dart';

/// Gaming-specific color tokens for the card editor.
///
/// These extend [AppColors] with the gaming palette: emerald (verdad/suave),
/// orange (reto/picante), fuchsia (deseo/intenso), and violet (sinLimites).
/// Use [withValues] for opacity variants.
class GamingColorTokens {
  GamingColorTokens._();

  /// Emerald — Verdad category, Suave level.
  static const Color emerald = Color(0xFF059669);

  /// Orange — Reto category, Picante level.
  static const Color orange = Color(0xFFEA580C);

  /// Fuchsia — Deseo category, Intenso level.
  static const Color fuchsia = Color(0xFFA21CAF);

  /// Violet — Sin Límites category.
  static const Color violet = Color(0xFF7C3AED);

  /// Azul — Guardadas library section.
  static const Color azul = Color(0xFF2563EB);
}
