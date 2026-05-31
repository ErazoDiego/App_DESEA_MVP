import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Barra de cuenta regresiva animada para cartas con tiempo límite.
///
/// Usa un [AnimationController] para animar la [LinearProgressIndicator]
/// y un [Timer] periódico para actualizar el display de tiempo restante.
/// Soporta pausa/reanudación mediante el flag [isPaused].
class TimerBar extends StatefulWidget {
  /// Duración total en segundos.
  final int seconds;

  /// Callback cuando el timer llega a cero.
  final VoidCallback onComplete;

  /// Indica si el timer debe estar en pausa.
  ///
  /// Cuando cambia a `true` se detiene la animación y el contador.
  /// Cuando cambia a `false` se reanuda desde el punto donde se detuvo.
  final bool isPaused;

  const TimerBar({
    super.key,
    required this.seconds,
    required this.onComplete,
    this.isPaused = false,
  });

  @override
  State<TimerBar> createState() => _TimerBarState();
}

class _TimerBarState extends State<TimerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    );
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    _controller.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
      }
    });
  }

  @override
  void didUpdateWidget(TimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _pause();
      } else {
        _resume();
      }
    }
  }

  /// Pausa la animación y el contador.
  void _pause() {
    _controller.stop();
    _timer.cancel();
  }

  /// Reanuda la animación y el contador desde donde se detuvieron.
  ///
  /// Ajusta la duración del [AnimationController] al tiempo restante para
  /// que la barra de progreso y el contador de tiempo estén sincronizados.
  void _resume() {
    if (_remainingSeconds <= 0) return;

    _controller
      ..duration = Duration(seconds: _remainingSeconds)
      ..forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _controller.value,
            backgroundColor: AppColors.surface,
            valueColor:
                const AlwaysStoppedAnimation(AppColors.fuchsiaAccent),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceSecondary,
              ),
        ),
      ],
    );
  }
}
