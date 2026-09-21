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
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.30,
      maxChildSize: 0.75,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHandle(),
                const SizedBox(height: 18),
                _buildShopName(),
                const SizedBox(height: 8),
                _buildVisitedTime(),
                if (_hasDescription) ...[const SizedBox(height: 16), _buildDescription()],
                if (media.isNotEmpty) ...[const SizedBox(height: 18), _buildMedia()],
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

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildShopName() {
    return Row(
      children: [
        const Icon(Icons.storefront_outlined, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(visit.shopName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildVisitedTime() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          DateFormat('dd MMM yyyy • hh:mm a').format(visit.visitedAt.toLocal()),
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 6),
        Text(visit.description!, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildMedia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Media', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        VisitMediaGrid(media: media, thumbnailSize: 80),
      ],
    );
  }
}
