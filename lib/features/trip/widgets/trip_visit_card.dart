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

  bool get _hasDescription {
    return visit.description != null && visit.description!.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildVisitedTime(context),
            if (_hasDescription) ...[const SizedBox(height: 14), _buildDescription(context)],
            if (media.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildMediaHeader(context),
              const SizedBox(height: 10),
              TripVisitsMediaGrid(media: media),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(13)),
          alignment: Alignment.center,
          child: Text(
            '$visitNumber',
            style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visit.shopName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                'Visit #$visitNumber',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.storefront_outlined, size: 19, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildVisitedTime(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, size: 17, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(visit.visitedAt.toLocal()),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notes_outlined, size: 19, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              visit.description!.trim(),
              style: AppTextStyles.bodyMedium.copyWith(height: 1.45, color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(Icons.perm_media_outlined, size: 19, color: colorScheme.primary),
        const SizedBox(width: 7),
        Text('Visit Media', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${media.length} ${media.length == 1 ? 'item' : 'items'}',
            style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
