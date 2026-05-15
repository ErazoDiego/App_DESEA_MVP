import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Insignia que muestra la categoría de la carta (VERDAD, RETO, DESEO).
class CategoryBadge extends StatelessWidget {
  /// Nombre del tipo de carta: 'verdad', 'reto', o 'deseo'.
  final String tipo;

  const CategoryBadge({super.key, required this.tipo});

  Color get _color {
    switch (tipo) {
      case 'verdad':
        return const Color(0xFF059669); // emerald
      case 'reto':
        return const Color(0xFFEA580C); // orange
      case 'deseo':
        return const Color(0xFFA21CAF); // fuchsia
      default:
        return AppColors.fuchsiaAccent;
    }
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.w700,
          color: _color,
          fontSize: 11,
          letterSpacing: 1.8,
        ),
      ),
    );
  }
}
