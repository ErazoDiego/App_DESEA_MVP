import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// ---------------------------------------------------------------------------
// GamingTextField
// ---------------------------------------------------------------------------

/// Gaming-styled text input with translucent background and fuchsia glow on
/// focus via [FocusNode]. Supports [maxLines], [validator], [keyboardType]
/// passthrough, and optional [maxLength] with automatic character counter.
class GamingTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int? maxLength;

  const GamingTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.validator,
    this.keyboardType,
    this.maxLength,
  });

  @override
  State<GamingTextField> createState() => _GamingTextFieldState();
}

class _GamingTextFieldState extends State<GamingTextField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isFocused
                  ? AppColors.fuchsiaAccent.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
              width: _isFocused ? 3 : 1,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppColors.surface.withValues(alpha: 0.6),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
