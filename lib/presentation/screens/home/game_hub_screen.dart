import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/datasources/hive_datasource.dart';

class GameHubScreen extends ConsumerWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.gameHubTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _ModeCard(
              icon: Icons.auto_awesome,
              title: AppStrings.modoSesion,
              description: AppStrings.modoSesionDesc,
              onTap: () => context.go('/game/sesion/default'),
            ),
            const SizedBox(height: 16),
            _ModeCard(
              icon: Icons.construction,
              title: AppStrings.modoLibre,
              description: AppStrings.libreCardDescription,
              onTap: () => context.go('/game/libre'),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final count = ref
                        .watch(guardadasBoxProvider)
                        .asData
                        ?.value
                        .length ??
                    0;
                return _ModeCard(
                  icon: Icons.bookmark,
                  title: AppStrings.savedCardsHubTitle,
                  description: '$count guardadas',
                  onTap: () => context.go('/game/guardadas'),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final count = ref
                        .watch(personalizadasBoxProvider)
                        .asData
                        ?.value
                        .length ??
                    0;
                return _ModeCard(
                  icon: Icons.edit_note,
                  title: AppStrings.misCartasHubTitle,
                  description: '$count personalizadas',
                  onTap: () => context.go('/game/mis-cartas'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.fuchsiaAccent, size: 32),
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
