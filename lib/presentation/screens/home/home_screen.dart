import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/gesture_item.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Acento violeta pastel del hub — consistente con GameHub
const Color _accentViolet = Color(0xFFBF5FFF);

/// Fondo oscuro profundo
const Color _homeBackground = Color(0xFF0D0010);

/// Violeta más profundo para el color shift sutil del fondo.
const Color _homeBgDeep = Color(0xFF1A0020);

/// Shader para el gradiente two-tone del logo DESEA (D hot pink → blanco).
Shader _deseaShader(Rect bounds) {
  return const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFff40ff), Colors.white],
    stops: [0.0, 0.35],
  ).createShader(bounds);
}

// ---------------------------------------------------------------------------
// HomeScreen
// ---------------------------------------------------------------------------

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _titleAnim;
  late final Animation<double> _statsAnim;
  late final Animation<double> _ctaAnim;
  late final Animation<double> _howToAnim;

  late final AnimationController _bgController;
  late final Animation<Color?> _bgColorAnim;

  @override
  void initState() {
    super.initState();

    // ── Entrance stagger ──
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _titleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    );
    _statsAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
    );
    _ctaAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic),
    );
    _howToAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic),
    );

    _controller.forward();

    // ── Background color shift (8s loop, muy sutil) ──
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _bgColorAnim = ColorTween(
      begin: _homeBackground,
      end: _homeBgDeep,
    ).animate(CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgColorAnim,
        builder: (context, child) {
          return Container(
            color: _bgColorAnim.value,
            child: child,
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // ── Title + Subtitle (stagger 0) ──
                _AnimatedItem(
                  animation: _titleAnim,
                  child: Column(
                    children: [
                      // DESEA two-tone logo
                      const ShaderMask(
                        shaderCallback: _deseaShader,
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          AppStrings.appName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6.0,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        AppStrings.tagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF9933ff),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // ── Stats (stagger 200ms) ──
                _AnimatedItem(
                  animation: _statsAnim,
                  child: Text(
                    AppStrings.statsLine,
                    style: TextStyle(
                      color: _accentViolet.withValues(alpha: 0.75),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                // ── CTA "Empezar noche" estilo premium (stagger 350ms) ──
                _AnimatedItem(
                  animation: _ctaAnim,
                  child: SizedBox(
                    width: double.infinity,
                    child: Material(
                      elevation: 8,
                      shadowColor: Colors.black38,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.go('/game-hub'),
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
                              Icon(Icons.play_arrow_rounded,
                                  color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.startNight,
                                style: const TextStyle(
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
                ),
                const SizedBox(height: 14),
                // ── "Cómo se juega" outline secundario (stagger 450ms) ──
                _AnimatedItem(
                  animation: _howToAnim,
                  child: GestureDetector(
                    onTap: () => _showHowToPlay(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.fuchsiaAccent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.help_outline,
                              size: 16,
                              color: AppColors.fuchsiaAccent),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.howToPlay,
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
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.howToPlay,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.fuchsiaAccent,
                  ),
            ),
            const SizedBox(height: 16),
            GestureItem(
              icon: Icons.swipe,
              description: AppStrings.swipeGesture,
            ),
            GestureItem(
              icon: Icons.bookmark,
              description: AppStrings.guardarGesture,
            ),
            GestureItem(
              icon: Icons.casino,
              description: AppStrings.comodinGesture,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.modoExplicacion,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AnimatedItem — fade + slide-up helper
// ---------------------------------------------------------------------------

class _AnimatedItem extends AnimatedWidget {
  final Widget child;

  const _AnimatedItem({
    required Animation<double> animation,
    required this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final anim = listenable as Animation<double>;
    return Opacity(
      opacity: anim.value,
      child: Transform.translate(
        offset: Offset(0, 24 * (1 - anim.value)),
        child: child,
      ),
    );
  }
}
