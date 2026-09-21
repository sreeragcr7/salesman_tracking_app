import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salesman_tracking_app/data/models/visit_media_model.dart';
import 'package:video_player/video_player.dart';

import '../../../data/models/trip_model.dart';
import '../../../data/models/visit_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../tracking/pages/trip_route_page.dart';

class TripVisitsPage extends StatefulWidget {
  final TripModel trip;

  const TripVisitsPage({super.key, required this.trip});

  @override
  State<TripVisitsPage> createState() => _TripVisitsPageState();
}

class _TripVisitsPageState extends State<TripVisitsPage> {
  final UserRepository _userRepository = UserRepository();

  List<VisitModel> _visits = [];
  Map<String, List<VisitMediaModel>> _visitMedia = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    try {
      final visits = await _userRepository.getVisitsForTrip(widget.trip.id);

      final mediaMap = <String, List<VisitMediaModel>>{};

      for (final visit in visits) {
        final media = await _userRepository.getVisitMedia(visit.id);

        mediaMap[visit.id] = media;
      }

      if (!mounted) return;

      setState(() {
        _visits = visits;
        _visitMedia = mediaMap;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('dd MMMM yyyy').format(widget.trip.date)),
        actions: [
          IconButton(
            tooltip: 'View Route',
            icon: const Icon(Icons.location_on_rounded),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripRoutePage(tripId: widget.trip.id)));
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_visits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No places were recorded for this day.',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _visits.length,
      separatorBuilder: (_, _) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        final visit = _visits[index];

        return _VisitCard(visit: visit, visitNumber: index + 1, media: _visitMedia[visit.id] ?? []);
      },
    );
  }
}

class _VisitCard extends StatelessWidget {
  final VisitModel visit;
  final int visitNumber;
  final List<VisitMediaModel> media;

  const _VisitCard({required this.visit, required this.visitNumber, required this.media});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text('$visitNumber')),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(visit.shopName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(visit.visitedAt.toLocal()),
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),

            if (visit.description != null && visit.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(visit.description!, style: const TextStyle(height: 1.4)),
            ],

            if (media.isNotEmpty) ...[const SizedBox(height: 16), _VisitMediaGrid(media: media)],
          ],
        ),
      ),
    );
  }
}

class _VisitMediaGrid extends StatelessWidget {
  final List<VisitMediaModel> media;

  const _VisitMediaGrid({required this.media});

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
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => _FullScreenImagePage(imageUrl: media.mediaUrl)));
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
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => _VideoPlayerPage(videoUrl: media.mediaUrl)));
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

class _FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: InteractiveViewer(child: Image.network(imageUrl, fit: BoxFit.contain)),
      ),
    );
  }
}

class _VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerPage({required this.videoUrl});

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;

        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visit Video')),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                        });
                      },
                      iconSize: 64,
                      icon: Icon(_controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
