import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Modal de pausa que se muestra cuando el usuario pausa la sesión.
///
/// Muestra información de la carta actual y botones para
/// continuar o reiniciar la sesión.
///
/// [currentCard] y [fase] son opcionales: si ambos son null
/// (o se omiten), se omite la línea de información de carta.
class PauseModal extends StatelessWidget {
  /// Número de la carta actual (1-based para display).
  /// Opcional: si es null junto con [fase], se omite la info de carta.
  final int? currentCard;

  /// Fase narrativa actual.
  /// Opcional: si es null junto con [currentCard], se omite la info de carta.
  final String? fase;

  /// Callback para continuar la sesión.
  final VoidCallback onContinue;

  /// Callback para reiniciar la sesión.
  final VoidCallback onRestart;

  const PauseModal({
    super.key,
    this.currentCard,
    this.fase,
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
              if (currentCard != null && fase != null)
                Text('Carta $currentCard · $fase'),
              SizedBox(height: currentCard != null && fase != null ? 24 : 8),
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
