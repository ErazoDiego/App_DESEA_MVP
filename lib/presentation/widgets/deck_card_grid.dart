import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/mazo.dart';

// ---------------------------------------------------------------------------
// Color helpers por nivel
// ---------------------------------------------------------------------------

Color _accentFor(Nivel nivel) {
  switch (nivel) {
    case Nivel.suave:
      return const Color(0xFF059669); // emerald
    case Nivel.picante:
      return const Color(0xFFEA580C); // orange
    case Nivel.intenso:
      return const Color(0xFFA21CAF); // fuchsia
  }
}

Color _glowFor(Nivel nivel) {
  switch (nivel) {
    case Nivel.suave:
      return const Color(0xFF059669).withValues(alpha: 0.25);
    case Nivel.picante:
      return const Color(0xFFEA580C).withValues(alpha: 0.25);
    case Nivel.intenso:
      return const Color(0xFFA21CAF).withValues(alpha: 0.25);
  }
}

String _labelFor(Nivel nivel) {
  switch (nivel) {
    case Nivel.suave:
      return 'Suave';
    case Nivel.picante:
      return 'Picante';
    case Nivel.intenso:
      return 'Intenso';
  }
}

// ---------------------------------------------------------------------------
// DeckCardGrid
// ---------------------------------------------------------------------------

/// Grid responsivo de 2 columnas que muestra cada [Mazo] como una tarjeta
/// visual con efecto de mazo de cartas apiladas.
///
/// El tercio superior de cada tarjeta es un placeholder abstracto para el
/// futuro dorso de carta (diseño pendiente del equipo de diseño).
/// Para swappear: reemplazar [Expanded(flex: 3, child: ...)] en
/// [_DeckCardTile._buildMainCard] por un [Image.asset] o [Image.network].
class DeckCardGrid extends StatelessWidget {
  final List<Mazo> mazos;
  final void Function(Mazo) onTap;
  final void Function(Mazo) onDelete;

  const DeckCardGrid({
    super.key,
    required this.mazos,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: mazos.length,
      itemBuilder: (context, index) {
        final mazo = mazos[index];
        return _DeckCardTile(
          key: ValueKey('deck_card_${mazo.id}'),
          mazo: mazo,
          onTap: () => onTap(mazo),
          onDelete: () => onDelete(mazo),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _DeckCardTile
// ---------------------------------------------------------------------------

class _DeckCardTile extends StatefulWidget {
  final Mazo mazo;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DeckCardTile({
    super.key,
    required this.mazo,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_DeckCardTile> createState() => _DeckCardTileState();
}

class _DeckCardTileState extends State<_DeckCardTile> {
  bool _isPressed = false;

  Color get _accent => _accentFor(widget.mazo.nivel);
  Color get _glow => _glowFor(widget.mazo.nivel);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AspectRatio(
          aspectRatio: 0.68,
          child: _buildDeckStack(),
        ),
      ),
    );
  }

  Widget _buildDeckStack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final o = constraints.maxWidth * 0.035; // offset unit ~5–6dp

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Ghost card 2 (deepest) — shifted down-right, rotated
            Positioned.fill(
              top: o * 2.5,
              left: o * 2.5,
              bottom: -o * 2,
              right: -o * 1.5,
              child: Transform.rotate(
                angle: 0.045,
                child: _GhostCard(darkness: 0.55),
              ),
            ),
            // Ghost card 1 (middle)
            Positioned.fill(
              top: o * 1.2,
              left: o * 1.2,
              bottom: -o,
              right: -o * 0.7,
              child: Transform.rotate(
                angle: -0.025,
                child: _GhostCard(darkness: 0.3),
              ),
            ),
            // Main card (front)
            _buildMainCard(),
            // Delete button overlay
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: widget.onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _glow,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Full card back image covering the entire card ──────
          Positioned.fill(
            child: Image.asset(
              'assets/cartas/dorso-carta1.jpg',
              fit: BoxFit.cover,
              // Tinte fucsia para neutralizar el verde del dorso y
              // que combine con la identidad visual de la app
              color: const Color(0xFFFF40FF).withValues(alpha: 0.4),
              colorBlendMode: BlendMode.overlay,
            ),
          ),
          // ── Gradient overlay at bottom for text readability ────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
          ),
          // ── Info section overlaid at the bottom ────────────────
          Positioned(
            left: 12,
            right: 12,
            bottom: 46,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.mazo.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: _accent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${widget.mazo.cartaIds.length} cartas',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _GhostCard — card back image con oscurecimiento para efecto de profundidad
// ---------------------------------------------------------------------------

/// Muestra el dorso de carta con una capa negra semitransparente encima.
/// [darkness] controla qué tan oscuro se ve (0.0 = sin cambio, 1.0 = negro total).
class _GhostCard extends StatelessWidget {
  final double darkness;

  const _GhostCard({required this.darkness});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: const AssetImage('assets/cartas/dorso-carta1.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFFFF40FF).withValues(alpha: 0.4),
            BlendMode.overlay,
          ),
        ),
      ),
      foregroundDecoration: BoxDecoration(
        color: Colors.black.withValues(alpha: darkness),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ExpandableDeckFab
// ---------------------------------------------------------------------------

/// FAB expandible con overlay que despliega dos acciones HACIA ARRIBA:
/// "Crear mazo" y "Crear carta".
///
/// Arquitectura:
/// - El FAB principal es un simple botón toggle que muestra (+) / (✕).
/// - Al expandirse, inserta un [OverlayEntry] con:
///   1. Backdrop semi-transparente con blur.
///   2. Columna de botones premium posicionada sobre el FAB.
/// - Cada botón aparece con fade + scale escalonado.
/// - Toque en el backdrop o en (✕) cierra el menú con animación.
class ExpandableDeckFab extends StatefulWidget {
  final VoidCallback onCrearMazo;
  final VoidCallback onCrearCarta;

  const ExpandableDeckFab({
    super.key,
    required this.onCrearMazo,
    required this.onCrearCarta,
  });

  @override
  State<ExpandableDeckFab> createState() => _ExpandableDeckFabState();
}

class _ExpandableDeckFabState extends State<ExpandableDeckFab> {
  bool _expanded = false;
  OverlayEntry? _overlay;

  // ── Lifecycle ─────────────────────────────────────────────────

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  // ── Overlay ───────────────────────────────────────────────────

  void _ensureOverlay() {
    if (_overlay != null) return;
    _overlay = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context, rootOverlay: false).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  // ── Actions ───────────────────────────────────────────────────

  void _toggle() {
    if (!_expanded) {
      _expanded = true;
      _ensureOverlay();
      if (mounted) setState(() {});
    } else {
      _expanded = false;
      if (mounted) setState(() {});
      // Remove overlay después de la animación de salida
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted || !_expanded) _removeOverlay();
      });
    }
  }

  void _onCrearMazo() {
    _expanded = false;
    if (mounted) setState(() {});
    _removeOverlay();
    widget.onCrearMazo();
  }

  void _onCrearCarta() {
    _expanded = false;
    if (mounted) setState(() {});
    _removeOverlay();
    widget.onCrearCarta();
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: const Key('fab_expandable_main'),
      onPressed: _toggle,
      backgroundColor: AppColors.fuchsiaAccent,
      foregroundColor: Colors.white,
      elevation: 6,
      child: _expanded
          ? const Icon(Icons.close, key: Key('fab_icon_close'), size: 24)
          : const Icon(Icons.add, key: Key('fab_icon_add'), size: 24),
    );
  }

  // ── Overlay builder ───────────────────────────────────────────

  Widget _buildOverlay(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const fabSize = 56.0;
    const scaffoldMargin = 16.0;
    const gap = 20.0;
    final bottomPos = scaffoldMargin + bottomInset + fabSize + gap;

    return Stack(
      children: [
        // Backdrop — intercepta taps para cerrar el menú
        Positioned.fill(
          child: GestureDetector(
            onTap: _expanded ? _toggle : null,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
        ),
        // Botones del menú
        Positioned(
          right: scaffoldMargin,
          bottom: bottomPos,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Crear mazo (arriba) — aparece con leve retraso
              _AnimatedMenuItem(
                visible: _expanded,
                delayMs: 60,
                child: _MenuItem(
                  label: AppStrings.libreCrearMazo,
                  icon: Icons.playlist_add,
                  onTap: _onCrearMazo,
                ),
              ),
              const SizedBox(height: gap),
              // Crear carta (abajo, más cerca del FAB) — primero
              _AnimatedMenuItem(
                visible: _expanded,
                delayMs: 0,
                child: _MenuItem(
                  label: AppStrings.libreCrearCartaPers,
                  icon: Icons.edit_note,
                  onTap: _onCrearCarta,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── _AnimatedMenuItem — fade+scale con delay ────────────────────

class _AnimatedMenuItem extends StatefulWidget {
  final bool visible;
  final int delayMs;
  final Widget child;

  const _AnimatedMenuItem({
    required this.visible,
    required this.delayMs,
    required this.child,
  });

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    if (widget.visible) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_AnimatedMenuItem old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _ctrl.forward();
      });
    } else if (!widget.visible && old.visible) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final v = _ctrl.value;
        return Opacity(
          opacity: v,
          child: Transform.scale(
            scale: 0.5 + 0.5 * v,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ---------------------------------------------------------------------------
// _MenuItem — botón premium individual
// ---------------------------------------------------------------------------

/// Botón individual del menú expandible con diseño premium.
/// La animación fade/scale se maneja desde el padre via
/// [AnimatedOpacity] y [AnimatedScale].
class _MenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 232,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.fuchsiaAccent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.fuchsiaAccent.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

