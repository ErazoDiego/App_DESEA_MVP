import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Insignia que muestra el nivel de intensidad de la carta
/// con un color distintivo: verde (suave), naranja (picante), fucsia (intenso).
class LevelBadge extends StatelessWidget {
  /// Nivel de intensidad: 'suave', 'picante', o 'intenso'.
  final String nivel;

  const LevelBadge({super.key, required this.nivel});

  Color get _nivelColor {
    switch (nivel) {
      case 'suave':
        return Colors.green;
      case 'picante':
        return Colors.orange;
      case 'intenso':
        return AppColors.fuchsiaAccent;
      default:
        return AppColors.onSurfaceSecondary;
    }
  }

  String get _nivelLabel {
    switch (nivel) {
      case 'suave':
        return 'Suave';
      case 'picante':
        return 'Picante';
      case 'intenso':
        return 'Intenso';
      default:
        return nivel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _nivelColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _nivelLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _nivelColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
