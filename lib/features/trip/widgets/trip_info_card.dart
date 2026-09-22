import 'package:flutter/material.dart';
import 'trip_info_item.dart';

class TripInfoCard extends StatelessWidget {
  final int visitCount;
  final String distance;
  final String startTime;
  final String endTime;
  const TripInfoCard({
    super.key,
    required this.visitCount,
    required this.distance,
    required this.startTime,
    required this.endTime,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 20,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.route_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Daily Route', style: textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    '$visitCount visits',
                    style: textTheme.bodySmall?.copyWith(color: textTheme.bodySmall?.color?.withValues(alpha: 0.65)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TripInfoItem(icon: Icons.straighten_outlined, label: 'Distance', value: distance),
                  ),
                  Expanded(
                    child: TripInfoItem(icon: Icons.play_circle_outline, label: 'Started', value: startTime),
                  ),
                  Expanded(
                    child: TripInfoItem(icon: Icons.stop_circle_outlined, label: 'Ended', value: endTime),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
