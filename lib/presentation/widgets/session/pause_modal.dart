import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Modal de pausa que se muestra cuando el usuario pausa la sesión.
///
/// Muestra información de la carta actual y botones para
/// continuar o reiniciar la sesión.
class PauseModal extends StatelessWidget {
  /// Número de la carta actual (1-based para display).
  final int currentCard;

  /// Fase narrativa actual.
  final String fase;

  /// Callback para continuar la sesión.
  final VoidCallback onContinue;

  /// Callback para reiniciar la sesión.
  final VoidCallback onRestart;

  const PauseModal({
    super.key,
    required this.currentCard,
    required this.fase,
    required this.onContinue,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sesión pausada',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: AppColors.fuchsiaAccent)),
              const SizedBox(height: 8),
              Text('Carta $currentCard · $fase'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('Continuar'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onRestart,
                  child: const Text('Reiniciar sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
