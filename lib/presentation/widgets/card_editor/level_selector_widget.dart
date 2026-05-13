import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'gaming_color_tokens.dart';

// ---------------------------------------------------------------------------
// LevelSelector
// ---------------------------------------------------------------------------

/// Three colored pills for nivel: Suave (emerald), Picante (orange), Intenso
/// (fuchsia). Exactly one pill is always selected. Default: 'suave'.
/// Selected pill fills with accent color + scale 1.05 (150ms easeOut).
class LevelSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const LevelSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _levels = <_LevelItem>[
    _LevelItem('suave', 'Suave', GamingColorTokens.emerald),
    _LevelItem('picante', 'Picante', GamingColorTokens.orange),
    _LevelItem('intenso', 'Intenso', GamingColorTokens.fuchsia),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: _levels.map((level) {
            final isSelected = selected == level.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: level.value == 'suave' ? 0 : 8,
                  right: level.value == 'intenso' ? 0 : 8,
                ),
                child: _LevelPill(
                  item: level,
                  isSelected: isSelected,
                  onTap: () => onChanged(level.value),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Internal models
// ---------------------------------------------------------------------------

class _LevelItem {
  final String value;
  final String label;
  final Color color;

  const _LevelItem(this.value, this.label, this.color);
}

class _LevelPill extends StatelessWidget {
  final _LevelItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelPill({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected
                ? item.color.withValues(alpha: 0.3)
                : AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? item.color.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected
                        ? item.color
                        : Colors.white.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
