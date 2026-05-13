import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'gaming_color_tokens.dart';

// ---------------------------------------------------------------------------
// CategorySelector
// ---------------------------------------------------------------------------

/// Horizontal chip selector for categoría (Verdad / Reto / Deseo / Sin
/// Límites). Selected chip shows filled accent color + glow shadow.
/// Unselected shows surface @ 60% with border.
class CategorySelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _categories = <_CategoryItem>[
    _CategoryItem('verdad', 'Verdad', Icons.psychology, GamingColorTokens.emerald),
    _CategoryItem('reto', 'Reto', Icons.whatshot, GamingColorTokens.orange),
    _CategoryItem('deseo', 'Deseo', Icons.favorite, GamingColorTokens.fuchsia),
    _CategoryItem('sinLimites', 'Sin Límites', Icons.auto_awesome, GamingColorTokens.violet),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected = selected == cat.value;
            return _CategoryChip(
              item: cat,
              isSelected: isSelected,
              onTap: () => onChanged(isSelected ? null : cat.value),
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

class _CategoryItem {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryItem(this.value, this.label, this.icon, this.color);
}

class _CategoryChip extends StatelessWidget {
  final _CategoryItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? item.color.withValues(alpha: 0.25)
              : AppColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? item.color.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 18,
                color: isSelected ? item.color : Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? item.color : Colors.white.withValues(alpha: 0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
