import 'package:flutter/material.dart';
import '../../../domain/entities/carta.dart';
import '../../../core/constants/app_colors.dart';
import 'level_badge.dart';
import 'category_badge.dart';

/// Tarjeta de carta con animación, swipe y botón de guardar.
///
/// Muestra el [CategoryBadge] y [LevelBadge] en la parte superior,
/// el texto de la carta centrado, y un botón de guardar opcional.
class CartaCard extends StatelessWidget {
  /// Carta a mostrar.
  final Carta carta;

  /// Nivel de intensidad actual.
  final String nivel;

  /// Indica si la carta ya fue guardada.
  final bool isSaved;

  /// Callback al deslizar a la izquierda (siguiente carta).
  final VoidCallback? onSwipeNext;

  /// Callback al deslizar a la derecha (carta anterior).
  final VoidCallback? onSwipePrev;

  /// Callback al presionar el botón de guardar.
  final VoidCallback? onSave;

  const CartaCard({
    super.key,
    required this.carta,
    required this.nivel,
    this.isSaved = false,
    this.onSwipeNext,
    this.onSwipePrev,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! > 200) {
          onSwipePrev?.call();
        } else if (details.primaryVelocity! < -200) {
          onSwipeNext?.call();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          border: isSaved
              ? Border.all(color: AppColors.fuchsiaAccent, width: 2)
              : null,
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surface,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryBadge(tipo: carta.tipo.name),
                LevelBadge(nivel: nivel),
              ],
            ),
            const Spacer(),
            Text(
              carta.texto,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                    height: 1.5,
                  ),
            ),
            const Spacer(),
            if (onSave != null)
              OutlinedButton.icon(
                onPressed: onSave,
                icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                label: Text(isSaved ? 'Guardada' : 'Guardar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.fuchsiaAccent,
                  side: const BorderSide(color: AppColors.fuchsiaAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
