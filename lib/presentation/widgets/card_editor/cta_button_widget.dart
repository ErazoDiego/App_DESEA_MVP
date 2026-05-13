import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'gaming_color_tokens.dart';

// ---------------------------------------------------------------------------
// CtaButtonWidget
// ---------------------------------------------------------------------------

/// Gaming-style CTA button with gradient (fuchsia → violet), glow shadow,
/// and scale 0.95 animation on press.
///
/// Three states:
///   - **enabled**: gradient + glow
///   - **loading**: [CircularProgressIndicator] overlay, disabled
///   - **disabled**: grey, no glow
class CtaButtonWidget extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const CtaButtonWidget({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  State<CtaButtonWidget> createState() => _CtaButtonWidgetState();
}

class _CtaButtonWidgetState extends State<CtaButtonWidget> {
  bool _isPressed = false;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: _isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: _isDisabled
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.fuchsiaAccent, GamingColorTokens.violet],
                  ),
            color: _isDisabled ? Colors.grey.shade700 : null,
            boxShadow: _isDisabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.fuchsiaAccent.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.label,
                    style: TextStyle(
                      color: _isDisabled
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
