import 'package:flutter/material.dart';
import 'package:salesman_tracking_app/core/theme/app_colors.dart';
import 'package:salesman_tracking_app/core/widgets/salesman_status.dart';

import '../../../data/models/user_model.dart';
import '../../../domain/entities/trip.dart';

class SalesmanProfileHeader extends StatelessWidget {
  final UserModel salesman;
  final Trip? todayTrip;

  const SalesmanProfileHeader({super.key, required this.salesman, required this.todayTrip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasProfileImage = salesman.profileImage != null && salesman.profileImage!.isNotEmpty;

    final status = SalesmanStatus.fromTrip(todayTrip);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileImage(context, hasProfileImage),

              const SizedBox(width: 16),

              Expanded(child: _buildProfileInfo(context, status)),
            ],
          ),

          const SizedBox(height: 20),

          _buildStatusSection(context, status),
        ],
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, bool hasProfileImage) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.20), width: 2),
      ),
      child: CircleAvatar(
        radius: 34,
        backgroundColor: colorScheme.primaryContainer,
        backgroundImage: hasProfileImage ? NetworkImage(salesman.profileImage!) : null,
        child: !hasProfileImage ? Icon(Icons.person_rounded, size: 36, color: colorScheme.onPrimaryContainer) : null,
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, SalesmanStatus status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Salesman',
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 3),

        Text(
          salesman.name.isEmpty ? 'Unnamed Salesman' : salesman.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            Icon(Icons.email_outlined, size: 15, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                salesman.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context, SalesmanStatus status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: status.color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: status.color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(_statusIcon(status.label), size: 20, color: status.color),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Status',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  status.label,
                  style: theme.textTheme.titleSmall?.copyWith(color: status.color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: status.color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String label) {
    final value = label.toLowerCase();

    if (value.contains('active') || value.contains('working') || value.contains('started')) {
      return Icons.location_on_rounded;
    }

    if (value.contains('completed') || value.contains('complete')) {
      return Icons.check_circle_rounded;
    }

    return Icons.location_off_rounded;
  }
}
