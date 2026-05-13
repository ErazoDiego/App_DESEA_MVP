import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/datasources/hive_datasource.dart';
import '../../widgets/card_editor/gaming_color_tokens.dart';

/// Pantalla principal del hub de juego con diseño inmersivo.
///
/// Muestra una sección hero con gradiente y CTA, tarjetas de modos de
/// juego (Sesión/Libre) y tarjetas de acceso rápido a colecciones
/// (Guardadas/Mis Cartas) con microinteracciones de escala.
class GameHubScreen extends ConsumerWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _HeroSection(),
            _SectionHeader(title: AppStrings.gameHubTitle),
            _GameModeCard(
              color: GamingColorTokens.violet,
              icon: Icons.auto_awesome,
              title: AppStrings.modoSesion,
              description: AppStrings.modoSesionDesc,
              onTap: () => context.go('/game/sesion/default'),
            ),
            const SizedBox(height: 12),
            _GameModeCard(
              color: GamingColorTokens.orange,
              icon: Icons.construction,
              title: AppStrings.modoLibre,
              description: AppStrings.libreCardDescription,
              onTap: () => context.go('/game/libre'),
            ),
            _SectionHeader(title: AppStrings.gameHubColeccionSection),
            Consumer(
              builder: (context, ref, child) {
                final count =
                    ref.watch(guardadasBoxProvider).asData?.value.length ?? 0;
                return _LibraryCard(
                  color: GamingColorTokens.azul,
                  icon: Icons.bookmark,
                  title: AppStrings.savedCardsHubTitle,
                  countText: '$count guardadas',
                  onTap: () => context.go('/game/guardadas'),
                );
              },
            ),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, child) {
                final count =
                    ref.watch(personalizadasBoxProvider).asData?.value.length ?? 0;
                return _LibraryCard(
                  color: GamingColorTokens.fuchsia,
                  icon: Icons.edit_note,
                  title: AppStrings.misCartasHubTitle,
                  countText: '$count',
                  onTap: () => context.go('/game/mis-cartas'),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Hero section con gradiente, glow y CTA de sesión.
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.fuchsiaAccent.withValues(alpha: 0.30),
            AppColors.background,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.fuchsiaAccent.withValues(alpha: 0.20),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.fuchsiaAccent,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.gameHubImmersionSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurface,
                        ),
                  ),
                  const Spacer(),
                  _buildCtaButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.go('/game/sesion/default'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [GamingColorTokens.violet, AppColors.fuchsiaAccent],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.fuchsiaAccent.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            AppStrings.gameHubCtaSesion,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

/// Encabezado de sección con estilo uppercase y letter-spacing.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.onSurfaceSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de modo de juego con microinteracción de escala y glow.
class _GameModeCard extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _GameModeCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_GameModeCard> createState() => _GameModeCardState();
}

class _GameModeCardState extends State<_GameModeCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.96),
        onTapUp: (_) {
          setState(() => _scale = 1.0);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _scale = 1.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withValues(alpha: 0.25),
                  AppColors.surface,
                ],
              ),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.30),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.color, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de acceso a colección (Guardadas / Mis Cartas) con badge de conteo.
class _LibraryCard extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String countText;
  final VoidCallback onTap;

  const _LibraryCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.countText,
    required this.onTap,
  });

  @override
  State<_LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends State<_LibraryCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.96),
        onTapUp: (_) {
          setState(() => _scale = 1.0);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _scale = 1.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withValues(alpha: 0.25),
                  AppColors.surface,
                ],
              ),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.30),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.color, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.countText,
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
