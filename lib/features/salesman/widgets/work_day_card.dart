import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../visits/pages/add_visit_page.dart';

class WorkDayCard extends StatelessWidget {
  final bool dayStarted;
  final bool dayCompleted;
  final bool isLoading;
  final bool canStartDay;
  final bool isEnding;
  final String? activeTripId;

  final VoidCallback onStartDay;
  final VoidCallback onEndDay;

  const WorkDayCard({
    super.key,
    required this.dayStarted,
    required this.dayCompleted,
    required this.isLoading,
    required this.canStartDay,
    required this.isEnding,
    required this.activeTripId,
    required this.onStartDay,
    required this.onEndDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final Color statusColor;
    final IconData statusIcon;

    if (dayCompleted) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
    } else if (dayStarted) {
      statusColor = colorScheme.primary;
      statusIcon = Icons.location_on_rounded;
    } else {
      statusColor = colorScheme.onSurfaceVariant;
      statusIcon = Icons.location_off_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(statusIcon, size: 25, color: statusColor),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Work Day', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(
                        _statusText(),
                        style: textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                _StatusBadge(
                  label: dayCompleted
                      ? 'COMPLETED'
                      : dayStarted
                      ? 'ACTIVE'
                      : 'NOT STARTED',
                  color: statusColor,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    dayStarted ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                    size: 20,
                    color: statusColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dayCompleted
                          ? 'Location tracking completed for today.'
                          : dayStarted
                          ? 'Your location is being tracked.'
                          : 'Start your day to begin location tracking.',
                      style: textTheme.bodySmall?.copyWith(color: textTheme.bodySmall?.color?.withValues(alpha: 0.70)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (!dayStarted && !dayCompleted) _buildStartSection(context),

            if (dayStarted && activeTripId != null) _buildActiveDaySection(context),
          ],
        ),
      ),
    );
  }

  String _statusText() {
    if (dayCompleted) {
      return 'Your work day has ended';
    }

    if (dayStarted) {
      return 'You are currently on duty';
    }

    return 'Ready to start your work day';
  }

  Widget _buildStartSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (!canStartDay) {
      return SizedBox(
        width: double.infinity,
        child: Text(
          'Come back tomorrow to start your work day.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: textTheme.bodySmall?.color?.withValues(alpha: 0.65)),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onStartDay,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.play_arrow_rounded),
        label: Text(isLoading ? 'STARTING...' : 'START DAY'),
      ),
    );
  }

  Widget _buildActiveDaySection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddVisitPage(tripId: activeTripId!)));
            },
            icon: const Icon(Icons.add_business_outlined),
            label: const Text('ADD VISIT'),
          ),
        ),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.error.withValues(alpha: 0.30)),
          ),
          child: GestureDetector(
            onLongPress: isEnding ? null : onEndDay,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stop_circle_outlined, size: 20, color: colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  isEnding ? 'ENDING DAY...' : 'PRESS AND HOLD TO END DAY',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: colorScheme.error, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Press and hold to prevent accidental ending',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.50)),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    );
  }
}
