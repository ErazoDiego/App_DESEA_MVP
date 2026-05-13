import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/perfil.dart';
import '../../providers/perfil_providers.dart';

class ReadyScreen extends ConsumerWidget {
  const ReadyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(perfilRepositoryProvider);

    return FutureBuilder<Perfil>(
      future: repo.getPerfil(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final perfil = snapshot.data!;
        final modo = perfil.settings['modo'] as String?;
        final modoLabel =
            modo == 'sesion' ? AppStrings.modoSesion : AppStrings.modoLibre;

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.todoListo,
                    style:
                        Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppColors.fuchsiaAccent,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.resumenConfig,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurfaceSecondary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _SummaryRow(
                    label: AppStrings.edad,
                    value: '${perfil.edad} ${AppStrings.anyos}',
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: AppStrings.modo,
                    value: modoLabel,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      final repo = ref.read(perfilRepositoryProvider);
                      final p = await repo.getPerfil();
                      final updated =
                          p.copyWith(onboardingCompletado: true);
                      await repo.guardarPerfil(updated);
                      if (context.mounted) context.go('/home');
                    },
                    child: Text(AppStrings.empezar),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
