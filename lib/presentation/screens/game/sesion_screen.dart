import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/sesion_providers.dart';
import '../../widgets/circular_back_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import 'carta_activa_screen.dart';

/// Pantalla orquestadora de la sesión de juego.
///
/// Se muestra al iniciar una sesión desde GameHub. Recibe un [mazoId]
/// y ofrece un botón para comenzar la sesión. Cuando la sesión está activa
/// renderiza [CartaActivaScreen] inline (sin navegación nativa) para evitar
/// conflictos con el stack de GoRouter.
class SesionScreen extends ConsumerWidget {
  final String mazoId;

  const SesionScreen({super.key, required this.mazoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sesionActivaProvider);

    // Si hay una sesión activa (en curso, no completada), mostramos
    // CartaActivaScreen inline en vez de navegar con native Navigator.
    if (state.cartas.isNotEmpty &&
        state.sesion != null &&
        !state.isCompleted) {
      return const CartaActivaScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.modoSesion),
        leading: CircularBackButton(
          onPressed: () => context.go('/game-hub'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(AppStrings.preparandoSesion),
            ] else if (state.error != null) ...[
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[300]),
              ),
              const SizedBox(height: 24),
            ] else ...[
              Icon(Icons.auto_awesome, size: 64,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                AppStrings.modoSesionDesc,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            // "Comenzar" — estilo premium fucsia
            SizedBox(
              width: 200,
              child: Material(
                elevation: 8,
                shadowColor: Colors.black38,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: state.isLoading
                      ? null
                      : () => ref
                          .read(sesionActivaProvider.notifier)
                          .iniciarSesion(),
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          AppStrings.comenzar,
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
          ],
        ),
      ),
    );
  }
}
