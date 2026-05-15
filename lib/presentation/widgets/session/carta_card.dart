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

  /// Callback cuando el usuario voltea la carta (pasa de dorso a contenido).
  final VoidCallback? onFlip;

  const CartaCard({
    super.key,
    required this.carta,
    required this.nivel,
    this.isSaved = false,
    this.onSwipeNext,
    this.onSwipePrev,
    this.onSave,
    this.onFlip,
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
    widget.onFlip?.call();
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
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Imagen de dorso con tinte fucsia
          Positioned.fill(
            child: Image.asset(
              'assets/cartas/dorso_nuevo.jpg',
              fit: BoxFit.fill,
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
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
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
    return Container(
      decoration: BoxDecoration(
        border: widget.isSaved
            ? Border.all(color: AppColors.fuchsiaAccent, width: 2)
            : null,
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/cartas/frente_fucsia.jpg',
              fit: BoxFit.fill,
              color: Colors.black.withValues(alpha: 0.2),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryBadge(tipo: widget.carta.tipo.name),
                    LevelBadge(nivel: widget.nivel),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '"${widget.carta.texto}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 6,
                            offset: Offset(1, 2),
                          ),
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.onSave != null)
                  OutlinedButton.icon(
                    onPressed: widget.onSave,
                    icon: Icon(
                        widget.isSaved ? Icons.bookmark : Icons.bookmark_border),
                    label: Text(
                      widget.isSaved ? 'Guardada' : 'Guardar',
                      style: const TextStyle(
                        fontFamily: 'Rajdhani',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
