import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'session/level_badge.dart';

// ---------------------------------------------------------------------------
// Color / icon helpers by tipo
// ---------------------------------------------------------------------------

Color _tipoAccent(String tipo) {
  switch (tipo) {
    case 'verdad':
      return const Color(0xFF059669); // emerald
    case 'reto':
      return const Color(0xFFEA580C); // orange
    case 'deseo':
      return const Color(0xFFA21CAF); // fuchsia
    case 'sinLimites':
      return const Color(0xFF7C3AED); // violet
    default:
      return const Color(0xFF9E9E9E); // grey fallback
  }
}

Color _tipoGlow(String tipo) {
  return _tipoAccent(tipo).withValues(alpha: 0.25);
}

IconData _tipoIcon(String tipo) {
  switch (tipo) {
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

String _tipoLabel(String tipo) {
  switch (tipo) {
    case 'verdad':
      return 'Verdad';
    case 'reto':
      return 'Reto';
    case 'deseo':
      return 'Deseo';
    case 'sinLimites':
      return 'Sin Límites';
    default:
      return tipo;
  }
}

// ---------------------------------------------------------------------------
// CollectionCardTile
// ---------------------------------------------------------------------------

/// Tarjeta coleccionable con estilo de carta de trading para grid de 2
/// columnas. Usa gradiente de color según [tipo], con ícono/imagen en la
/// parte superior y texto + LevelBadge + fecha en la inferior.
class CollectionCardTile extends StatefulWidget {
  final String text;
  final String tipo;
  final String nivel;
  final String dateLabel;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const CollectionCardTile({
    super.key,
    required this.text,
    required this.tipo,
    required this.nivel,
    required this.dateLabel,
    this.imageUrl,
    this.onTap,
    required this.onDelete,
  });

  @override
  State<CollectionCardTile> createState() => _CollectionCardTileState();
}

class _CollectionCardTileState extends State<CollectionCardTile> {
  bool _isPressed = false;

  Color get _accent => _tipoAccent(widget.tipo);
  Color get _glow => _tipoGlow(widget.tipo);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AspectRatio(
          aspectRatio: 683 / 1024, // coincide con frente_fucsia.jpg
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: _glow,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // ── Image de fondo ────────────────────────────────
              Positioned.fill(
                child: Image.asset(
                  'assets/cartas/frente_fucsia.jpg',
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.2),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
              // ── Tinte por categoría ────────────────────────────
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _accent.withValues(alpha: 0.35),
                        _accent.withValues(alpha: 0.12),
                        AppColors.surface.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),
              // ── Contenido centrado ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // ── Top: category badge ──────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _accent.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _tipoLabel(widget.tipo).toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontWeight: FontWeight.w700,
                          color: _accent,
                          fontSize: 10,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // ── Main text: grande, bold, con glow ────────
                    Text(
                      '"${widget.text}"',
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
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // ── Bottom: level + fecha limpio ─────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LevelBadge(nivel: widget.nivel),
                        const SizedBox(width: 8),
                        Text(
                          widget.dateLabel,
                          style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── Delete overlay top-right ─────────────────────────────
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: widget.onDelete,
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Colors.white60,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
