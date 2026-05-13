import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar un gesto con ícono y descripción.
class GestureItem extends StatelessWidget {
  final IconData icon;
  final String description;

  const GestureItem({
    super.key,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
