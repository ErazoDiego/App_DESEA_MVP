import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../domain/entities/carta.dart';
import '../../../core/constants/app_colors.dart';
import 'level_badge.dart';
import 'category_badge.dart';

/// Tarjeta de carta con animación 3D flip, swipe y botón de guardar.
///
/// La carta arranca **boca abajo** mostrando el dorso (imagen + tinte fucsia).
/// El usuario toca para girarla con animación 3D y revelar el contenido
/// (texto, badges, botón de guardar). El swipe solo funciona después del flip.
class CartaCard extends StatefulWidget {
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
  State<CartaCard> createState() => _CartaCardState();
}

class _CartaCardState extends State<CartaCard>
    with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  late final AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) return;
    setState(() => _isFlipped = true);
    _flipController.forward();
  }

  Color get _levelColor {
    switch (widget.nivel) {
      case 'suave':
        return const Color(0xFF059669);
      case 'picante':
        return const Color(0xFFEA580C);
      case 'intenso':
        return const Color(0xFFA21CAF);
      default:
        return AppColors.fuchsiaAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isFlipped ? null : _flipCard,
      onHorizontalDragEnd: _isFlipped
          ? (details) {
              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! > 200) {
                widget.onSwipePrev?.call();
              } else if (details.primaryVelocity! < -200) {
                widget.onSwipeNext?.call();
              }
            }
          : null,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, _) {
          final value = _flipController.value;

          return Stack(
            children: [
              // ── Back face (dorso) — visible de 0° a ~90° ──────
              if (value < 0.5)
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(value * math.pi),
                  child: _buildCardBack(),
                ),
              // ── Front face (contenido) — visible de ~90° a 180° ─
              if (value >= 0.5)
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY((value + 1) * math.pi),
                  child: _buildCardFront(),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Card Back (dorso boca abajo) ─────────────────────────────────────
  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surface,
        border: Border.all(color: _levelColor, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Imagen de dorso con tinte fucsia
          Positioned.fill(
            child: Image.asset(
              'assets/cartas/dorso-carta1.jpg',
              fit: BoxFit.cover,
              color: const Color(0xFFFF40FF).withValues(alpha: 0.4),
              colorBlendMode: BlendMode.overlay,
            ),
          ),
          // Círculo de nivel (esquina superior derecha)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _levelColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _levelColor.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          // Hint centrado "Toca para revelar"
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, color: Colors.white60, size: 36),
                SizedBox(height: 10),
                Text(
                  'Toca para revelar',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Card Front (contenido de la carta) ──────────────────────────────
  Widget _buildCardFront() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(
        border: widget.isSaved
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
              CategoryBadge(tipo: widget.carta.tipo.name),
              LevelBadge(nivel: widget.nivel),
            ],
          ),
          const Spacer(),
          Text(
            widget.carta.texto,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  height: 1.5,
                ),
          ),
          const Spacer(),
          if (widget.onSave != null)
            OutlinedButton.icon(
              onPressed: widget.onSave,
              icon:
                  Icon(widget.isSaved ? Icons.bookmark : Icons.bookmark_border),
              label: Text(widget.isSaved ? 'Guardada' : 'Guardar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.fuchsiaAccent,
                side: const BorderSide(color: AppColors.fuchsiaAccent),
              ),
            ),
        ],
      ),
    );
  }
}
