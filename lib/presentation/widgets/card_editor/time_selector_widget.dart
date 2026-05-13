import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

// ---------------------------------------------------------------------------
// TimeSelector
// ---------------------------------------------------------------------------

/// Slider (5–120s) + 3 preset buttons (15s/30s/60s) for time limit.
/// Tapping a preset moves the slider. Dragging clears preset highlight.
/// Value `5` = null (no timer).
class TimeSelector extends StatelessWidget {
  final int? seconds;
  final ValueChanged<int?> onChanged;

  const TimeSelector({
    super.key,
    required this.seconds,
    required this.onChanged,
  });

  static const _presets = [15, 30, 60];

  @override
  Widget build(BuildContext context) {
    final currentValue = (seconds ?? 5).clamp(5, 120).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preset buttons
        Row(
          children: _presets.map((preset) {
            final isActive = seconds == preset;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: OutlinedButton(
                onPressed: () => onChanged(preset),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isActive
                      ? AppColors.fuchsiaAccent.withValues(alpha: 0.2)
                      : AppColors.surface.withValues(alpha: 0.6),
                  side: BorderSide(
                    color: isActive
                        ? AppColors.fuchsiaAccent.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                  foregroundColor: isActive
                      ? AppColors.fuchsiaAccent
                      : Colors.white.withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: Text('${preset}s'),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.fuchsiaAccent,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            thumbColor: AppColors.fuchsiaAccent,
            overlayColor: AppColors.fuchsiaAccent.withValues(alpha: 0.15),
            valueIndicatorColor: AppColors.fuchsiaAccent,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: Slider(
            value: currentValue,
            min: 5,
            max: 120,
            divisions: 115,
            label: '${currentValue.round()}s',
            onChanged: (v) {
              final intVal = v.round();
              onChanged(intVal == 5 ? null : intVal);
            },
          ),
        ),
      ],
    );
  }
}
