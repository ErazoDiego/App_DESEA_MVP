import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/sesion_providers.dart';
import '../../widgets/session/progress_bar.dart';
import '../../widgets/session/carta_card.dart';
import '../../widgets/session/timer_bar.dart';
import '../../widgets/session/pause_modal.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Pantalla principal de juego durante una sesión activa.
///
/// Muestra la carta actual con su progreso, temporizador (si aplica),
/// controles de navegación, botón de guardado, overlay de pausa y
/// overlay de finalización.
class CartaActivaScreen extends ConsumerStatefulWidget {
  const CartaActivaScreen({super.key});

  @override
  ConsumerState<CartaActivaScreen> createState() => _CartaActivaScreenState();
}

class _CartaActivaScreenState extends ConsumerState<CartaActivaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  bool _isCardFlipped = false;
  String? _lastCardId;

  ButtonStyle get _fuchsiaButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.fuchsiaAccent,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: AppColors.fuchsiaAccent.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      );

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sesionActivaProvider);
    final notifier = ref.read(sesionActivaProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.iniciarSesion(),
                child: const Text(AppStrings.reintentar),
              ),
            ],
          ),
        ),
      );
    }

    if (state.cartas.isEmpty || state.sesion == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(AppStrings.noSesionActiva),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.iniciarSesion(),
                child: const Text(AppStrings.iniciarSesion),
              ),
            ],
          ),
        ),
      );
    }

    final carta = state.currentCarta;
    // Reset flip state cuando cambia la carta
    if (carta.id != _lastCardId) {
      _isCardFlipped = false;
      _lastCardId = carta.id;
    }
    final hasTimer =
        carta.tiempoSegundos != null && state.remainingSeconds != null;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top bar with progress + comodin
                  Row(
                    children: [
                      Expanded(
                        child: SessionProgressBar(
                          current: state.currentIndex + 1,
                          total: state.totalCartas,
                          fase: state.faseActual,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.casino),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text(AppStrings.comodinProximamente),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Timer bar (solo después de voltear la carta)
                  if (hasTimer && _isCardFlipped)
                    TimerBar(
                      seconds: state.remainingSeconds!,
                      onComplete: () => notifier.nextCard(),
                      isPaused: state.isPaused,
                    ),

                  const SizedBox(height: 16),

                  // Card
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.96, end: 1.0)
                                .animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: CartaCard(
                        key: ValueKey(carta.id),
                        carta: carta,
                        nivel: state.nivelActual,
                        isSaved: state.savedCardIds.contains(carta.id),
                        onFlip: () => setState(() => _isCardFlipped = true),
                        onSwipeNext: state.canSkipAhead
                            ? () => notifier.nextCard()
                            : null,
                        onSwipePrev: state.canGoBack
                            ? () => notifier.previousCard()
                            : null,
                        onSave: () {
                          notifier.guardarCartaActual();
                          _flashController.forward(from: 0);
                        },
                      ),
                    ),
                  ),

                  // Bottom navigation: Anterior | Pausa | Siguiente
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.canGoBack) ...[
                        ElevatedButton(
                          onPressed: () => notifier.previousCard(),
                          style: _fuchsiaButtonStyle,
                          child: const Text(AppStrings.anterior),
                        ),
                        const SizedBox(width: 16),
                      ],
                      TextButton.icon(
                        onPressed: () => notifier.pausar(),
                        icon: const Icon(Icons.pause,
                            color: AppColors.fuchsiaAccent),
                        label: const Text(
                          AppStrings.pausar,
                          style:
                              TextStyle(color: AppColors.fuchsiaAccent),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (state.isLastCard)
                        ElevatedButton(
                          onPressed: () => notifier.nextCard(),
                          style: _fuchsiaButtonStyle,
                          child: const Text(AppStrings.finalizar),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => notifier.nextCard(),
                          style: _fuchsiaButtonStyle,
                          child: const Text(AppStrings.siguiente),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Pause overlay
            if (state.isPaused)
              Container(
                color: Colors.black54,
                child: PauseModal(
                  currentCard: state.currentIndex + 1,
                  fase: state.faseActual,
                  onContinue: () => notifier.pausar(),
                  onRestart: () {
                    notifier.pausar();
                    notifier.reiniciar();
                  },
                ),
              ),

            // Session end overlay
            if (state.isCompleted)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.sesionCompletada,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(sesionActivaProvider.notifier).reset();
                          context.go('/home');
                        },
                        style: _fuchsiaButtonStyle,
                        child: const Text(AppStrings.volverInicio),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
