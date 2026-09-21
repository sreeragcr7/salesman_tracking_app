import 'package:flutter/material.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            dayCompleted
                ? Icons.check_circle_outline
                : dayStarted
                ? Icons.location_on
                : Icons.location_off_outlined,
            size: 48,
          ),

          const SizedBox(height: 12),

          Text(
            dayCompleted
                ? 'Day completed'
                : dayStarted
                ? 'Day started'
                : 'Day not started',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          Text(
            dayCompleted
                ? 'Your work day has ended for today.'
                : dayStarted
                ? 'Your work day has started.'
                : 'Start your day to begin location tracking.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 20),

          if (!dayStarted && !dayCompleted) _buildStartSection(),

          if (dayStarted && activeTripId != null) _buildActiveDaySection(context),
        ],
      ),
    );
  }

  Widget _buildStartSection() {
    if (!canStartDay) {
      return const SizedBox(
        width: double.infinity,
        child: Text('Come back tomorrow to start your work day.', textAlign: TextAlign.center),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onStartDay,
        icon: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.play_arrow_rounded),
        label: Text(isLoading ? 'STARTING...' : 'START DAY'),
      ),
    );
  }

  Widget _buildActiveDaySection(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Text(
                isEnding ? 'ENDING DAY...' : 'PRESS AND HOLD TO END DAY',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
