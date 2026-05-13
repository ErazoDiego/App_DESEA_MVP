import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Pantalla de finalización de sesión.
///
/// Muestra un mensaje de sesión completada y un botón para
/// volver a la pantalla de inicio. Por ahora es una pantalla
/// simple que sirve como placeholder para futura expansión
/// (estadísticas, resumen, etc.).
class SessionEndScreen extends StatelessWidget {
  const SessionEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppColors.fuchsiaAccent,
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.sesionCompletada,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.fuchsiaAccent,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text(AppStrings.volverInicio),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
