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
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullScreenImagePage(imageUrl: media.mediaUrl)));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          media.mediaUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(Icons.broken_image_outlined, size: 30, color: theme.colorScheme.onSurfaceVariant),
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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullScreenVideoPage(videoUrl: media.mediaUrl)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 32, color: theme.colorScheme.onSurfaceVariant),
            Positioned(bottom: 8, child: Icon(Icons.play_circle_fill, size: 28, color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}
