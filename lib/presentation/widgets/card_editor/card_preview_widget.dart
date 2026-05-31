import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'gaming_color_tokens.dart';

// ---------------------------------------------------------------------------
// CardPreviewWidget
// ---------------------------------------------------------------------------

/// Live preview of the card being created. Pure render — no state.
///
/// Renders as [AspectRatio] 0.68 with gradient background, category icon +
/// color at top, centered text, and bottom row with tipo label / level dot /
/// time badge.
class CardPreviewWidget extends StatelessWidget {
  final String texto;
  final String? categoria;
  final String nivel;
  final int? tiempoSegundos;
  final String? dirigida;

  const CardPreviewWidget({
    super.key,
    required this.texto,
    this.categoria,
    required this.nivel,
    this.tiempoSegundos,
    this.dirigida,
  });

  Color get _accentColor {
    switch (categoria) {
      case 'verdad':
        return GamingColorTokens.emerald;
      case 'reto':
        return GamingColorTokens.orange;
      case 'deseo':
        return GamingColorTokens.fuchsia;
      case 'sinLimites':
        return GamingColorTokens.violet;
      default:
        return AppColors.fuchsiaAccent;
    }
  }

  IconData get _categoryIcon {
    switch (categoria) {
      case 'verdad':
        return Icons.psychology;
      case 'reto':
        return Icons.whatshot;
      case 'deseo':
        return Icons.favorite;
      case 'sinLimites':
        return Icons.auto_awesome;
      default:
        return Icons.auto_awesome_mosaic;
    }
  }

  Color get _levelColor {
    switch (nivel) {
      case 'suave':
        return GamingColorTokens.emerald;
      case 'picante':
        return GamingColorTokens.orange;
      case 'intenso':
        return GamingColorTokens.fuchsia;
      default:
        return Colors.white;
    }
  }

  String get _tipoLabel {
    switch (categoria) {
      case 'verdad':
        return 'Verdad';
      case 'reto':
        return 'Reto';
      case 'deseo':
        return 'Deseo';
      case 'sinLimites':
        return 'Sin Límites';
      default:
        return 'Personalizada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 320,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: _accentColor.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // ── Imagen de fondo ────────────────────────────────────
              Positioned.fill(
                child: Image.asset(
                  'assets/cartas/frente_fucsia.jpg',
                  fit: BoxFit.fill,
                  color: Colors.black.withValues(alpha: 0.2),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
              // ── Contenido ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // ── Top: category badge ──────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _tipoLabel.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontWeight: FontWeight.w700,
                          color: _accentColor,
                          fontSize: 10,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ── Center: texto grande ─────────────────────────
                    if (texto.isNotEmpty)
                      Text(
                        texto,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          fontSize: 22,
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
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Escribí la\ninstrucción...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 14,
                        ),
                      ),

                    const Spacer(),

                    // ── Bottom: level + time limpio ──────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _levelColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          nivel[0].toUpperCase() + nivel.substring(1),
                          style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                        if (tiempoSegundos != null) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${tiempoSegundos}s',
                              style: TextStyle(
                                fontFamily: 'Rajdhani',
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
