import 'package:flutter/material.dart';

/// Botón de regresar circular con fondo semi-transparente.
///
/// Consistente con el estilo visual de DESEA: sin elevación, sin bordes
/// definidos, solo un círculo con opacidad sobre el fondo oscuro.
class CircularBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;

  const CircularBackButton({
    super.key,
    this.onPressed,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ),
    );
  }
}
