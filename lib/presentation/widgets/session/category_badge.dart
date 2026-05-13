import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Insignia que muestra la categoría de la carta (VERDAD, RETO, DESEO).
class CategoryBadge extends StatelessWidget {
  /// Nombre del tipo de carta: 'verdad', 'reto', o 'deseo'.
  final String tipo;

  const CategoryBadge({super.key, required this.tipo});

  String get _label {
    switch (tipo) {
      case 'verdad':
        return 'VERDAD';
      case 'reto':
        return 'RETO';
      case 'deseo':
        return 'DESEO';
      default:
        return tipo.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.fuchsiaAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.fuchsiaAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
