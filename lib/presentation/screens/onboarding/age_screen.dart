import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/perfil.dart';
import '../../providers/perfil_providers.dart';

class AgeScreen extends ConsumerStatefulWidget {
  const AgeScreen({super.key});

  @override
  ConsumerState<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends ConsumerState<AgeScreen> {
  double _edad = 18.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.onboardingAgeTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.fuchsiaAccent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.onboardingAgeBody,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Slider(
              value: _edad,
              min: 12,
              max: 100,
              divisions: 88,
              label: '${_edad.toInt()} ${AppStrings.anyos}',
              onChanged: (value) => setState(() => _edad = value),
            ),
            Text(
              '${_edad.toInt()} ${AppStrings.anyos}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _edad >= 18
                  ? () async {
                      final repo = ref.read(perfilRepositoryProvider);
                      try {
                        final perfil = await repo.getPerfil();
                        final updated = perfil.copyWith(edad: _edad.toInt());
                        await repo.guardarPerfil(updated);
                      } catch (_) {
                        final nuevo = Perfil(
                          id: 'default',
                          edad: _edad.toInt(),
                          creadoEn: DateTime.now(),
                        );
                        await repo.guardarPerfil(nuevo);
                      }
                      if (context.mounted) context.go('/onboarding/preferences');
                    }
                  : null,
              child: Text(AppStrings.confirmarEdad),
            ),
          ],
        ),
      ),
    );
  }
}
