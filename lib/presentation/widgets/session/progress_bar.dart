import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Barra de progreso de la sesión que muestra el avance
/// a través de las cartas con color según la fase narrativa.
class SessionProgressBar extends StatelessWidget {
  /// Índice de la carta actual (1-based para display).
  final int current;

  /// Total de cartas en la sesión.
  final int total;

  /// Fase narrativa actual: calentamiento, tension, climax, cierre.
  final String fase;

  const SessionProgressBar({
    super.key,
    required this.current,
    required this.total,
    required this.fase,
  });

  Color get _faseColor {
    switch (fase) {
      case 'calentamiento':
        return Colors.green;
      case 'tension':
        return Colors.orange;
      case 'climax':
        return AppColors.fuchsiaAccent;
      case 'cierre':
        return AppColors.fuchsiaAccent.withValues(alpha: 0.8);
      default:
        return AppColors.fuchsiaAccent;
    }
  }

  String get _faseLabel {
    switch (fase) {
      case 'calentamiento':
        return 'Calentamiento';
      case 'tension':
        return 'Tensión';
      case 'climax':
        return 'Clímax';
      case 'cierre':
        return 'Cierre';
      default:
        return fase;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$current/$total · $_faseLabel',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: _faseColor)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? current / total : 0,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation(_faseColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
