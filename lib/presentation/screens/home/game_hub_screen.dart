import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/datasources/hive_datasource.dart';
import '../../widgets/circular_back_button.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Acento violeta pastel para el hub — #bf5fff
const Color _accentViolet = Color(0xFFBF5FFF);

/// Violeta más saturado para chips/badges — rgba(160,60,255,X)
const Color _chipPurple = Color(0xFFA03CFF);

/// Fondo oscuro específico del hub — #0d0010
const Color _hubBackground = Color(0xFF0D0010);

/// Color de superficie para cards en el hub.
Color get _cardSurface => Colors.white.withValues(alpha: 0.04);

/// Color de borde para cards en el hub.
Color get _cardBorder => Colors.white.withValues(alpha: 0.10);

// ---------------------------------------------------------------------------
// GameHubScreen
// ---------------------------------------------------------------------------

/// Pantalla principal del hub de juego con diseño renovado.
///
/// Muestra: header con volver, hero con glow + mood cards, modos destacados,
/// grid de tus cartas, y CTA fijo al pie.
class GameHubScreen extends ConsumerWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _hubBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _Header(),
            const _HeroSection(),
            const _MoodRow(),
            _SectionHeader(title: AppStrings.gameHubTitle),
            _SesionCard(onTap: () => context.go('/game/sesion-confirm/default')),
            const SizedBox(height: 10),
            _LibreCard(onTap: () => context.go('/game/libre')),
            _TusCartasHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer(
                builder: (context, ref, child) {
                  final guardCount = ref
                      .watch(guardadasBoxProvider)
                      .asData
                      ?.value
                      .length ?? 0;
                  final persCount = ref
                      .watch(personalizadasBoxProvider)
                      .asData
                      ?.value
                      .length ?? 0;
                  return _CardsGrid(
                    guardadasCount: guardCount,
                    personalizadasCount: persCount,
                    onGuardadasTap: () => context.go('/game/guardadas'),
                    onMisCartasTap: () => context.go('/game/mis-cartas'),
                  );
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _BottomCta(
        onTap: () => context.go('/game/sesion-confirm/default'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 20, 8),
        child: Row(
          children: [
            CircularBackButton(
              onPressed: () => context.go('/home'),
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.appName,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _HeroSection
// ---------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Two-tone "DESEA" — D hot pink, ESEA gradient to white ──
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFff40ff), Colors.white],
              stops: [0.0, 0.35],
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Text(
              AppStrings.appName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // ── Subtitle: uppercase, letter-spacing, purple ──
          Text(
            AppStrings.gameHubImmersionSubtitle.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9933ff),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 4.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _MoodRow
// ---------------------------------------------------------------------------

class _MoodRow extends StatelessWidget {
  const _MoodRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _MoodCard(
              icon: Icons.whatshot,
              label: AppStrings.moodPicante,
              color: _accentViolet,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MoodCard(
              icon: Icons.celebration,
              label: AppStrings.moodDivertido,
              color: _chipPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MoodCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SectionHeader
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SesionCard — destacada
// ---------------------------------------------------------------------------

class _SesionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SesionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _accentViolet.withValues(alpha: 0.7),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Badge "Recomendado" ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _chipPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _chipPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  AppStrings.gameHubRecomendado,
                  style: TextStyle(
                    color: _accentViolet,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Título + descripción ──
              Text(
                AppStrings.modoSesion,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.modoSesionDesc,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // ── Chips ──
              Row(
                children: [
                  _Chip(label: AppStrings.gameHubSesionDuracion),
                  const SizedBox(width: 8),
                  _Chip(label: AppStrings.gameHubSesionTipo),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _LibreCard — secundaria
// ---------------------------------------------------------------------------

class _LibreCard extends StatelessWidget {
  final VoidCallback onTap;

  const _LibreCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.modoLibre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.libreCardDescription,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _Chip
// ---------------------------------------------------------------------------

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _chipPurple.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _chipPurple.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _chipPurple.withValues(alpha: 0.8),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TusCartasHeader
// ---------------------------------------------------------------------------

class _TusCartasHeader extends StatelessWidget {
  const _TusCartasHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AppStrings.gameHubTusCartasSection,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CardsGrid — 2 columnas
// ---------------------------------------------------------------------------

class _CardsGrid extends StatelessWidget {
  final int guardadasCount;
  final int personalizadasCount;
  final VoidCallback onGuardadasTap;
  final VoidCallback onMisCartasTap;

  const _CardsGrid({
    required this.guardadasCount,
    required this.personalizadasCount,
    required this.onGuardadasTap,
    required this.onMisCartasTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LibraryCard(
            icon: Icons.bookmark,
            label: AppStrings.savedCardsHubTitle,
            count: guardadasCount,
            color: _chipPurple,
            onTap: onGuardadasTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _LibraryCard(
            icon: Icons.edit_note,
            label: AppStrings.misCartasHubTitle,
            count: personalizadasCount,
            color: _accentViolet,
            onTap: onMisCartasTap,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _LibraryCard
// ---------------------------------------------------------------------------

class _LibraryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _LibraryCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _BottomCta
// ---------------------------------------------------------------------------

class _BottomCta extends StatelessWidget {
  final VoidCallback onTap;

  const _BottomCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: _hubBackground,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _accentViolet.withValues(alpha: 0.5),
                width: 1.5,
              ),
              color: _accentViolet.withValues(alpha: 0.10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded,
                    color: _accentViolet, size: 22),
                const SizedBox(width: 8),
                Text(
                  AppStrings.gameHubCtaSesion,
                  style: TextStyle(
                    color: _accentViolet,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
