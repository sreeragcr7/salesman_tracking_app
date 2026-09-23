import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/visit_media_model.dart';
import '../../../data/models/visit_model.dart';
import 'visit_media_view.dart';

class VisitDetailsSheet extends StatelessWidget {
  final VisitModel visit;
  final List<VisitMediaModel> media;

  const VisitDetailsSheet({super.key, required this.visit, required this.media});

  static Future<void> show(BuildContext context, {required VisitModel visit, required List<VisitMediaModel> media}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return VisitDetailsSheet(visit: visit, media: media);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.30,
      maxChildSize: 0.75,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandle(context),
                const SizedBox(height: 18),
                _buildShopName(context, textTheme, colorScheme),
                const SizedBox(height: 8),
                _buildVisitedTime(context, textTheme),
                if (_hasDescription) ...[const SizedBox(height: 16), _buildDescription(context, textTheme)],
                if (media.isNotEmpty) ...[const SizedBox(height: 18), _buildMedia(context, textTheme)],
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get _hasDescription {
    return visit.description != null && visit.description!.trim().isNotEmpty;
  }

  Widget _buildHandle(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildShopName(BuildContext context, TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.storefront_outlined, size: 22, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(visit.shopName, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildVisitedTime(BuildContext context, TextTheme textTheme) {
    final secondaryColor = textTheme.bodyMedium?.color?.withValues(alpha: 0.65);

    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: secondaryColor),
        const SizedBox(width: 6),
        Text(
          DateFormat('dd MMM yyyy • hh:mm a').format(visit.visitedAt.toLocal()),
          style: textTheme.bodyMedium?.copyWith(color: secondaryColor),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: textTheme.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(visit.description!, style: textTheme.bodyMedium?.copyWith(fontSize: 14)),
      ],
    );
  }

  Widget _buildMedia(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Media', style: textTheme.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        VisitMediaGrid(media: media, thumbnailSize: 80),
      ],
    );
  }
}
