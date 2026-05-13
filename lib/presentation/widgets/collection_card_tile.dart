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
          aspectRatio: 0.72,
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
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _accent.withValues(alpha: 0.55),
                AppColors.surface,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _glow,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Top section: image or icon fallback ────────────
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: widget.imageUrl != null
                      ? Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildIconFallback();
                          },
                        )
                      : _buildIconFallback(),
                ),
              ),
              // ── Bottom section: text + LevelBadge + date ──────
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            _tipoLabel(widget.tipo).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          LevelBadge(nivel: widget.nivel),
                          const Spacer(),
                          Text(
                            widget.dateLabel,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

  Widget _buildIconFallback() {
    return Container(
      color: _accent.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          _tipoIcon(widget.tipo),
          size: 32,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
