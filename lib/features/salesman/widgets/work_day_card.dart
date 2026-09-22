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
      statusIcon = Icons.check_circle_outline;
    } else if (dayStarted) {
      statusColor = colorScheme.primary;
      statusIcon = Icons.location_on_outlined;
    } else {
      statusColor = colorScheme.onSurfaceVariant;
      statusIcon = Icons.location_off_outlined;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.10), shape: BoxShape.circle),
              child: Icon(statusIcon, size: 32, color: statusColor),
            ),

            const SizedBox(height: 14),

            Text(
              dayCompleted
                  ? 'Day completed'
                  : dayStarted
                  ? 'Day started'
                  : 'Day not started',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            Text(
              dayCompleted
                  ? 'Your work day has ended for today.'
                  : dayStarted
                  ? 'Your work day has started.'
                  : 'Start your day to begin location tracking.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyMedium?.color?.withValues(alpha: 0.65)),
            ),

            const SizedBox(height: 20),

            if (!dayStarted && !dayCompleted) _buildStartSection(context),

            if (dayStarted && activeTripId != null) _buildActiveDaySection(context),
          ],
        ),
      ),
    );
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
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddVisitPage(tripId: activeTripId!)));
            },
            icon: const Icon(Icons.add_business_outlined),
            label: const Text('ADD VISIT'),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: GestureDetector(
            onLongPress: isEnding ? null : onEndDay,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.error.withValues(alpha: 0.40)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stop_circle_outlined, size: 20, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    isEnding ? 'ENDING DAY...' : 'PRESS AND HOLD TO END DAY',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: colorScheme.error),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
