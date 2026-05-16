import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/sesion_providers.dart';
import '../../widgets/circular_back_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Timeline data
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineItem {
  final String title;
  final String description;
  final Color dotColor;
  final Color textColor;

  const _TimelineItem({
    required this.title,
    required this.description,
    required this.dotColor,
    required this.textColor,
  });
}

const _timelineItems = <_TimelineItem>[
  _TimelineItem(
    title: 'Calentamiento',
    description: 'Preguntas suaves para entrar en clima',
    dotColor: Color(0xFF5030A0),
    textColor: Color(0xFF9060C0),
  ),
  _TimelineItem(
    title: 'Íntimo',
    description: 'Deseos, fantasías y conexión profunda',
    dotColor: Color(0xFF8B1A4A),
    textColor: Color(0xFFC060A0),
  ),
  _TimelineItem(
    title: 'Sin límites',
    description: 'Para cuando la noche ya arrancó',
    dotColor: Color(0xFF7A2000),
    textColor: Color(0xFFC06030),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// SesionConfirmScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Pantalla de confirmación antes de iniciar una sesión de juego.
///
/// Muestra header con badge de duración, stats del modo, timeline
/// informativo con los 3 niveles, y CTAs para empezar o cambiar modo.
class SesionConfirmScreen extends ConsumerStatefulWidget {
  final String mazoId;

  const SesionConfirmScreen({super.key, required this.mazoId});

  @override
  ConsumerState<SesionConfirmScreen> createState() =>
      _SesionConfirmScreenState();
}

class _SesionConfirmScreenState extends ConsumerState<SesionConfirmScreen> {
  // Colores
  static const _bg = Color(0xFF0a0010);
  static const _accentPurple = Color(0xFFbf5fff);
  static const _cardSurface = Color.fromRGBO(255, 255, 255, 0.04);
  static const _cardBorder = Color.fromRGBO(255, 255, 255, 0.08);

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
            // ── Timeline ──
            Expanded(child: _buildTimeline()),
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
          CircularBackButton(onPressed: () => context.go('/game-hub')),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

  // ── Timeline ──

  Widget _buildTimeline() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text(
            'ASÍ VA LA SESIÓN',
            style: TextStyle(
              color: Color(0xFF7040A0),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 12),
          // Timeline items — each Expanded fills space evenly
          Expanded(
            child: Column(
              children: [
                _buildTimelineItem(_timelineItems[0], withLine: true),
                _buildTimelineItem(_timelineItems[1], withLine: true),
                _buildTimelineItem(_timelineItems[2], withLine: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(_TimelineItem item, {required bool withLine}) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dot + connecting line
          SizedBox(
            width: 28,
            child: Column(
              children: [
                // Dot at top
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: item.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                // Line fills to bottom, reaching next dot
                if (withLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFF4A2070),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content aligned top with dot
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: item.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── CTAs ──

  Widget _buildCtas() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
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
