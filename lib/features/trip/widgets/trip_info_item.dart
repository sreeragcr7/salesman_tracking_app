import 'package:flutter/material.dart';

class TripInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const TripInfoItem({super.key, required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 5),
        Text(label, style: textTheme.bodySmall?.copyWith(color: textTheme.bodySmall?.color?.withValues(alpha: 0.60))),
        const SizedBox(height: 3),
        Text(value, textAlign: TextAlign.center, style: textTheme.labelLarge),
      ],
    );
  }
}
