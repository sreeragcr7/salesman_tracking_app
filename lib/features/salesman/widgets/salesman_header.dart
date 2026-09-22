import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesmanHeader extends StatelessWidget {
  final String name;
  final String email;

  const SalesmanHeader({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final today = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome, $name', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),

        const SizedBox(height: 8),

        Text(email, style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyMedium?.color?.withValues(alpha: 0.65))),

        const SizedBox(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Today', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            Text(
              today,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
