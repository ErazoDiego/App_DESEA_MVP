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
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _accentColor.withValues(alpha: 0.55),
                AppColors.surface,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                // ── Top: category centered ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_categoryIcon, size: 16, color: _accentColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _tipoLabel.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // ── Center: texto centrado, crece desde el centro ──
                if (texto.isNotEmpty)
                  Text(
                    texto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    'Escribí la\ninstrucción...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                const Spacer(),

                // ── Bottom: level + time centrado ──────────────────
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
                    const SizedBox(width: 4),
                    Text(
                      nivel[0].toUpperCase() + nivel.substring(1),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                    if (tiempoSegundos != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${tiempoSegundos}s',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
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
        ),
      ),
    );
  }
}
