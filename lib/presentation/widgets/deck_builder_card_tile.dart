import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'card_editor/gaming_color_tokens.dart';

// ---------------------------------------------------------------------------
// DeckBuilderCardTile
// ---------------------------------------------------------------------------

/// Mini carta visual para el constructor de mazos.
///
/// Renderiza una carta tipo coleccionable con:
/// - Imagen de fondo opcional ([imagenUrl])
/// - Gradiente de fondo según [categoria]
/// - Icono + label de categoría
/// - Texto centrado verticalmente
/// - Badge de tiempo opcional
/// - Borde glow + sombra cuando [isSelected]
class DeckBuilderCardTile extends StatelessWidget {
  final String texto;
  final String? categoria;
  final int? tiempoSegundos;
  final String? imagenUrl;
  final bool isSelected;
  final VoidCallback? onTap;

  const DeckBuilderCardTile({
    super.key,
    required this.texto,
    this.categoria,
    this.tiempoSegundos,
    this.imagenUrl,
    this.isSelected = false,
    this.onTap,
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

  bool get _hasImage =>
      imagenUrl != null && imagenUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        splashColor: _accentColor.withValues(alpha: 0.15),
        highlightColor: _accentColor.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? _accentColor.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.06),
              width: isSelected ? 2 : 1,
            ),
            color: AppColors.surface,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              children: [
                // ── Background: image (if available) ─────────────
                if (_hasImage)
                  Positioned.fill(
                    child: Image(
                      image: imagenUrl!.startsWith('http')
                          ? NetworkImage(imagenUrl!)
                          : AssetImage(imagenUrl!) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),

                // ── Gradient overlay ──────────────────────────────
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _accentColor.withValues(alpha: 0.40),
                          _accentColor.withValues(alpha: 0.15),
                          AppColors.surface.withValues(alpha: 0.88),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Content ────────────────────────────────────────
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        // Top: category
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _categoryIcon,
                              size: 12,
                              color: _accentColor,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                _tipoLabel,
                                style: TextStyle(
                                  color: _accentColor.withValues(alpha: 0.9),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Texto centrado H + V
                        Center(
                          child: Text(
                            texto,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                              height: 1.3,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const Spacer(),

                        // Bottom: time badge
                        if (tiempoSegundos != null && tiempoSegundos! > 0)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${tiempoSegundos}s',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Selected check badge ─────────────────────────
                if (isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
