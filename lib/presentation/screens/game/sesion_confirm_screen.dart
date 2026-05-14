import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/carta_providers.dart';
import '../../providers/sesion_providers.dart';
import '../../widgets/card_editor/gaming_color_tokens.dart';
import '../../widgets/circular_back_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model for carousel levels
// ─────────────────────────────────────────────────────────────────────────────

class _NivelInfo {
  final String title;
  final String description;
  final IconData icon;

  const _NivelInfo({
    required this.title,
    required this.description,
    required this.icon,
  });
}

const _niveles = <_NivelInfo>[
  _NivelInfo(
    title: AppStrings.sesionNivel1,
    description: AppStrings.sesionNivel1Desc,
    icon: Icons.local_fire_department_rounded,
  ),
  _NivelInfo(
    title: AppStrings.sesionNivel2,
    description: AppStrings.sesionNivel2Desc,
    icon: Icons.favorite_rounded,
  ),
  _NivelInfo(
    title: AppStrings.sesionNivel3,
    description: AppStrings.sesionNivel3Desc,
    icon: Icons.lock_open_rounded,
  ),
];

/// Colores y prefijos para cada nivel del carrusel.
const _levelColors = [
  GamingColorTokens.emerald,   // Nivel 1 · Suave
  GamingColorTokens.orange,    // Nivel 2 · Íntimo
  GamingColorTokens.fuchsia,   // Nivel 3 · Sin filtro
];

const _levelPrefixes = ['suave_', 'picante_', 'intenso_'];

// ─────────────────────────────────────────────────────────────────────────────
// SesionConfirmScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Pantalla de confirmación antes de iniciar una sesión de juego.
///
/// Muestra header con badge de duración, stats del modo, carrusel
/// swipeable con los 3 niveles, y CTAs para empezar o cambiar modo.
class SesionConfirmScreen extends ConsumerStatefulWidget {
  final String mazoId;

  const SesionConfirmScreen({super.key, required this.mazoId});

  @override
  ConsumerState<SesionConfirmScreen> createState() =>
      _SesionConfirmScreenState();
}

class _SesionConfirmScreenState extends ConsumerState<SesionConfirmScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animController;
  late final List<Animation<Offset>> _slideAnims;
  late final List<Animation<double>> _fadeAnims;
  int _currentPage = 1;

  /// Textos aleatorios de cartas reales para cada nivel del carrusel.
  final List<String?> _randomCardTexts = [null, null, null];

  /// Indica si ya se intentó cargar las cartas.
  bool _cardsLoaded = false;

  // Colores
  static const _bg = Color(0xFF0a0010);
  static const _accentPurple = Color(0xFFbf5fff);
  static const _cardSurface = Color.fromRGBO(255, 255, 255, 0.04);
  static const _cardBorder = Color.fromRGBO(255, 255, 255, 0.08);
  static const _activeCardBg = Color.fromRGBO(160, 60, 255, 0.15);
  static const _activeCardBorder = Color.fromRGBO(160, 60, 255, 0.6);
  static const _iconBg = Color.fromRGBO(160, 60, 255, 0.2);
  static const _mutedText = Color.fromRGBO(255, 255, 255, 0.5);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78, initialPage: 1);
    _pageController.addListener(_onPageChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnims = List.generate(3, (i) {
      final start = i * 0.18;
      return Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Interval(start, start + 0.35, curve: Curves.easeOutCubic),
      ));
    });

    _fadeAnims = List.generate(3, (i) {
      final start = i * 0.18;
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animController,
        curve: Interval(start, start + 0.35, curve: Curves.easeOut),
      ));
    });

    _animController.forward();
    _loadRandomCards();
  }

  Future<void> _loadRandomCards() async {
    try {
      final repo = ref.read(cartaRepositoryProvider);
      final allCartas = await repo.getCartas();
      final random = Random();

      for (int i = 0; i < _levelPrefixes.length; i++) {
        final filtered = allCartas
            .where((c) => c.id.startsWith(_levelPrefixes[i]))
            .toList();
        if (filtered.isNotEmpty) {
          _randomCardTexts[i] =
              filtered[random.nextInt(filtered.length)].texto;
        }
      }
    } catch (_) {
      // Silently fall back to static descriptions
    }
    if (mounted) setState(() => _cardsLoaded = true);
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 1;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(),
            // ── Stats bar ──
            _buildStatsBar(),
            // ── Carousel ──
            _buildCarouselSection(),
            // ── CTAs ──
            _buildCtas(),
          ],
        ),
      ),
    );
  }

  // ── Header ──

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
      child: Row(
        children: [
          // Back button — circle, semi-transparent
          CircularBackButton(onPressed: () => context.go('/game-hub')),
          const SizedBox(width: 12),
          // Title + label (centered vertically)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.sesionModoElegido,
                  style: const TextStyle(
                    color: _mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.modoSesion,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Duration badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _accentPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _accentPurple.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              AppStrings.sesionDuracion,
              style: TextStyle(
                color: _accentPurple,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats bar ──

  Widget _buildStatsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            _StatItem(value: '20', label: 'cartas'),
            _StatDivider(),
            _StatItem(value: '3', label: 'niveles'),
            _StatDivider(),
            _StatItem(value: '2', label: 'mazos'),
          ],
        ),
      ),
    );
  }

  // ── Carousel section ──

  Widget _buildCarouselSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
            child: Text(
              AppStrings.sesionAsiVaLaSesion,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _niveles.length,
              onPageChanged: (page) =>
                  setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                final isActive = index == _currentPage;
                return _buildNivelCard(index, isActive);
              },
            ),
          ),
          // Dot indicators
          _buildDots(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNivelCard(int index, bool isActive) {
    final nivel = _niveles[index];
    final levelColor = _levelColors[index];
    final displayText = _cardsLoaded && _randomCardTexts[index] != null
        ? _randomCardTexts[index]!
        : nivel.description;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnims[index],
          child: FadeTransition(
            opacity: _fadeAnims[index],
            child: child!,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? _activeCardBg : _cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? _activeCardBorder : _cardBorder,
              width: isActive ? 1.5 : 0.5,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Card back with level color ──
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: levelColor.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Decorative corner accents
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _CornerAccent(color: levelColor),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: _CornerAccent(color: levelColor),
                    ),
                    // Center icon
                    Icon(
                      nivel.icon,
                      color: levelColor.withValues(alpha: 0.8),
                      size: 36,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // ── Title ──
              Text(
                nivel.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              // ── Random card text or static description ──
              Text(
                displayText,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.75)
                      : _mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontStyle: _cardsLoaded && _randomCardTexts[index] != null
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_niveles.length, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? _accentPurple : _accentPurple.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ── CTAs ──

  Widget _buildCtas() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          // Primary: "Empezar sesión" — estilo premium fucsia
          SizedBox(
            width: double.infinity,
            child: Material(
              elevation: 8,
              shadowColor: Colors.black38,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _onEmpezarSesion,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.fuchsiaAccent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.fuchsiaAccent
                            .withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        AppStrings.empezarSesion,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Secondary: "Cambiar modo" — outline fucsia
          GestureDetector(
            onTap: () => context.go('/game-hub'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.fuchsiaAccent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_rounded,
                      size: 16, color: AppColors.fuchsiaAccent),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.cambiarModo,
                    style: TextStyle(
                      color: AppColors.fuchsiaAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ──

  Future<void> _onEmpezarSesion() async {
    await ref.read(sesionActivaProvider.notifier).iniciarSesion();
    if (mounted) {
      context.go('/game/sesion/${widget.mazoId}');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CornerAccent — decorative corner for card backs
// ─────────────────────────────────────────────────────────────────────────────

class _CornerAccent extends StatelessWidget {
  final Color color;
  const _CornerAccent({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: color.withValues(alpha: 0.6), width: 1.5),
          left: BorderSide(color: color.withValues(alpha: 0.6), width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat item widget
// ─────────────────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFbf5fff),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat divider
// ─────────────────────────────────────────────────────────────────────────────

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}
