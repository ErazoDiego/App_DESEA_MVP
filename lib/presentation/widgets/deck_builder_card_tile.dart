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
                // ── Background: card front (default) o imagen ─────
                Positioned.fill(
                  child: Image(
                    image: _hasImage
                        ? (imagenUrl!.startsWith('http')
                            ? NetworkImage(imagenUrl!)
                            : AssetImage(imagenUrl!))
                        : const AssetImage(
                            'assets/cartas/frente_fucsia.jpg'),
                    fit: BoxFit.fill,
                    color: Colors.black.withValues(alpha: 0.2),
                    colorBlendMode: BlendMode.darken,
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Column(
                      children: [
                        // ── Top: category badge ───────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
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
                              fontSize: 9,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // ── Texto grande centrado ──────────────────
                        Center(
                          child: Text(
                            '"$texto"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 17,
                              height: 1.25,
                              shadows: const [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 4,
                                  offset: Offset(1, 1),
                                ),
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const Spacer(),

                        // ── Bottom: time badge ────────────────────
                        if (tiempoSegundos != null && tiempoSegundos! > 0)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
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
                                  fontFamily: 'Rajdhani',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 10,
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
