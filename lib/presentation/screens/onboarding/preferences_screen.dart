import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/perfil_providers.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  String? _selectedMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.seleccionaModo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.fuchsiaAccent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildModeCard(
                  context,
                  mode: 'sesion',
                  title: AppStrings.modoSesion,
                  description: AppStrings.modoSesionDesc,
                  icon: Icons.list_alt,
                ),
                const SizedBox(width: 16),
                _buildModeCard(
                  context,
                  mode: 'libre',
                  title: AppStrings.modoLibre,
                  description: AppStrings.modoLibreDesc,
                  icon: Icons.auto_awesome,
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _selectedMode != null
                  ? () async {
                      final repo = ref.read(perfilRepositoryProvider);
                      final perfil = await repo.getPerfil();
                      final updated = perfil.copyWith(
                        settings: {
                          ...perfil.settings,
                          'modo': _selectedMode,
                        },
                      );
                      await repo.guardarPerfil(updated);
                      if (context.mounted) context.go('/onboarding/tutorial');
                    }
                  : null,
              child: Text(AppStrings.siguiente),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String mode,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedMode == mode;

    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: Card(
        color: isSelected
            ? AppColors.fuchsiaAccent.withValues(alpha: 0.2)
            : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppColors.fuchsiaAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: SizedBox(
          width: 140,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: AppColors.fuchsiaAccent),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
