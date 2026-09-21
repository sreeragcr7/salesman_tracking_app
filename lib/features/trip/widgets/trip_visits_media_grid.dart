import 'package:flutter/material.dart';
import 'package:salesman_tracking_app/features/trip/widgets/visit_media_view.dart';

import '../../../data/models/visit_media_model.dart';

class TripVisitsMediaGrid extends StatelessWidget {
  final List<VisitMediaModel> media;

  const TripVisitsMediaGrid({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: media.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final item = media[index];

        if (item.isVideo) {
          return _VideoMediaTile(media: item);
        }

        return _ImageMediaTile(media: item);
      },
    );
  }
}

class _ImageMediaTile extends StatelessWidget {
  final VisitMediaModel media;

  const _ImageMediaTile({required this.media});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullScreenImagePage(imageUrl: media.mediaUrl)));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          media.mediaUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
            );
          },
        ),
      ),
    );
  }
}

class _VideoMediaTile extends StatelessWidget {
  final VisitMediaModel media;

  const _VideoMediaTile({required this.media});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullScreenVideoPage(videoUrl: media.mediaUrl)));
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 48),
            Positioned(bottom: 10, child: Icon(Icons.play_circle_fill, size: 32)),
          ],
        ),
      ),
    );
  }
}
