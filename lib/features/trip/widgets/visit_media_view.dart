import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../data/models/visit_media_model.dart';

class VisitMediaGrid extends StatelessWidget {
  final List<VisitMediaModel> media;
  final double thumbnailSize;

  const VisitMediaGrid({super.key, required this.media, this.thumbnailSize = 90});

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: thumbnailSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = media[index];

          return GestureDetector(
            onTap: () {
              if (item.isVideo) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FullScreenVideoPage(videoUrl: item.mediaUrl)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FullScreenImagePage(imageUrl: item.mediaUrl)),
                );
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: thumbnailSize,
                height: thumbnailSize,
                child: item.isVideo
                    ? _VideoThumbnail(videoUrl: item.mediaUrl)
                    : Image.network(
                        item.mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image_outlined));
                        },
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final String videoUrl;

  const _VideoThumbnail({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black87,
          child: const Icon(Icons.video_library_outlined, color: Colors.white70, size: 30),
        ),
        const Center(
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(Icons.play_arrow, color: Colors.black, size: 20),
          ),
        ),
      ],
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) {
              return const Icon(Icons.broken_image_outlined, color: Colors.white, size: 50);
            },
          ),
        ),
      ),
    );
  }
}

class FullScreenVideoPage extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPage({super.key, required this.videoUrl});

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: _controller.value.isInitialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.black54,
                      child: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
