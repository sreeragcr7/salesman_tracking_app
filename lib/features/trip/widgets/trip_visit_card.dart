import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
            _buildHeader(),
            const SizedBox(height: 12),
            _buildVisitedTime(),
            if (_hasDescription) ...[
              const SizedBox(height: 12),
              Text(visit.description!, style: const TextStyle(height: 1.4)),
            ],
            if (media.isNotEmpty) ...[const SizedBox(height: 16), TripVisitsMediaGrid(media: media)],
          ],
        ),
      ),
    );
  }

  bool get _hasDescription {
    return visit.description != null && visit.description!.trim().isNotEmpty;
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(child: Text('$visitNumber')),
        const SizedBox(width: 12),
        Expanded(
          child: Text(visit.shopName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildVisitedTime() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          DateFormat('dd MMM yyyy, hh:mm a').format(visit.visitedAt.toLocal()),
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
