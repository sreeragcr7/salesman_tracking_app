import 'package:flutter/material.dart';
import 'package:salesman_tracking_app/core/widgets/salesman_status.dart';

import '../../../data/models/user_model.dart';
import '../../../domain/entities/trip.dart';

class SalesmanCard extends StatelessWidget {
  final UserModel salesman;
  final Trip? todayTrip;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SalesmanCard({super.key, required this.salesman, required this.todayTrip, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final hasProfileImage = salesman.profileImage != null && salesman.profileImage!.isNotEmpty;

    final status = SalesmanStatus.fromTrip(todayTrip);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        onLongPress: onLongPress,

        leading: CircleAvatar(
          radius: 26,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          backgroundImage: hasProfileImage ? NetworkImage(salesman.profileImage!) : null,
          child: !hasProfileImage ? Icon(Icons.person_outline, color: textTheme.bodyMedium?.color) : null,
        ),

        title: Text(
          salesman.name.isEmpty ? 'Unnamed Salesman' : salesman.name,
          style: textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                salesman.email,
                style: textTheme.bodySmall?.copyWith(color: textTheme.bodySmall?.color?.withValues(alpha: 0.65)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              _StatusBadge(label: status.label, color: status.color),
            ],
          ),
        ),

        trailing: Icon(Icons.chevron_right, color: textTheme.bodyMedium?.color?.withValues(alpha: 0.55)),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
