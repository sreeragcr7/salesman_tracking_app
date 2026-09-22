import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/visit_media_model.dart';
import '../../../data/models/visit_model.dart';
import 'trip_visits_media_grid.dart';

class TripVisitCard extends StatelessWidget {
  final VisitModel visit;
  final int visitNumber;
  final List<VisitMediaModel> media;

  const TripVisitCard({super.key, required this.visit, required this.visitNumber, required this.media});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildVisitedTime(context),
            if (_hasDescription) ...[
              const SizedBox(height: 12),
              Text(visit.description!, style: AppTextStyles.bodyMedium.copyWith(height: 1.4)),
            ],
            if (media.isNotEmpty) ...[const SizedBox(height: 14), TripVisitsMediaGrid(media: media)],
          ],
        ),
      ),
    );
  }

  bool get _hasDescription {
    return visit.description != null && visit.description!.trim().isNotEmpty;
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            '$visitNumber',
            style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(visit.shopName, style: AppTextStyles.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildVisitedTime(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(Icons.access_time_outlined, size: 17, color: textTheme.bodySmall?.color?.withValues(alpha: 0.60)),
        const SizedBox(width: 6),
        Text(
          DateFormat('dd MMM yyyy, hh:mm a').format(visit.visitedAt.toLocal()),
          style: textTheme.bodySmall?.copyWith(color: textTheme.bodySmall?.color?.withValues(alpha: 0.65)),
        ),
      ],
    );
  }
}
