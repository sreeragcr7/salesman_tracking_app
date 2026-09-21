import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:salesman_tracking_app/data/models/visit_media_model.dart';
import 'package:salesman_tracking_app/features/tracking/widgets/visit_media_view.dart';

import '../../../data/models/trip_location_model.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/models/visit_model.dart';
import '../../../data/repositories/user_repository.dart';

class TripRoutePage extends StatefulWidget {
  final String tripId;

  const TripRoutePage({super.key, required this.tripId});

  @override
  State<TripRoutePage> createState() => _TripRoutePageState();
}

class _TripRoutePageState extends State<TripRoutePage> {
  final UserRepository _userRepository = UserRepository();
  final MapController _mapController = MapController();

  List<TripLocationModel> _locations = [];
  List<VisitModel> _visits = [];
  Map<String, List<VisitMediaModel>> _visitMedia = {};

  TripModel? _trip;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTripData();
  }

  Future<void> _loadTripData() async {
    try {
      final results = await Future.wait([
        _userRepository.getTripById(widget.tripId),
        _userRepository.getTripLocations(widget.tripId),
        _userRepository.getVisitsForTrip(widget.tripId),
      ]);

      final trip = results[0] as TripModel;
      final locations = results[1] as List<TripLocationModel>;
      final visits = results[2] as List<VisitModel>;

      final mediaMap = <String, List<VisitMediaModel>>{};

      for (final visit in visits) {
        mediaMap[visit.id] = await _userRepository.getVisitMedia(visit.id);
      }

      if (!mounted) return;

      setState(() {
        _trip = trip;
        _locations = locations;
        _visits = visits;
        _visitMedia = mediaMap;
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fitRouteToMap();
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<LatLng> _buildRoutePoints() {
    return _locations.map((location) => LatLng(location.latitude, location.longitude)).toList();
  }

  List<LatLng> _buildAllMapPoints() {
    final points = <LatLng>[
      ..._locations.map((location) => LatLng(location.latitude, location.longitude)),
      ..._visits.map((visit) => LatLng(visit.latitude, visit.longitude)),
    ];

    return points;
  }

  void _fitRouteToMap() {
    final points = _buildAllMapPoints();

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 17);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);

    _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.fromLTRB(50, 50, 50, 250)));
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '--';
    }

    return DateFormat('hh:mm a').format(dateTime.toLocal());
  }

  String _formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }

    return '${distance.toStringAsFixed(2)} km';
  }

  void _showVisitDetails(VisitModel visit) {
    final media = _visitMedia[visit.id] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            visit.shopName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd MMM yyyy • hh:mm a').format(visit.visitedAt.toLocal()),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),

                    if (visit.description != null && visit.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),

                      const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),

                      const SizedBox(height: 6),

                      Text(visit.description!, style: const TextStyle(fontSize: 14)),
                    ],

                    if (media.isNotEmpty) ...[
                      const SizedBox(height: 18),

                      const Text('Media', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),

                      const SizedBox(height: 8),

                      VisitMediaGrid(media: media, thumbnailSize: 80),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (_locations.isNotEmpty) {
      final start = _locations.first;

      markers.add(
        Marker(
          point: LatLng(start.latitude, start.longitude),
          width: 50,
          height: 50,
          child: const Icon(Icons.location_on, size: 44, color: Colors.green),
        ),
      );

      if (_locations.length > 1) {
        final end = _locations.last;

        markers.add(
          Marker(
            point: LatLng(end.latitude, end.longitude),
            width: 50,
            height: 50,
            child: const Icon(Icons.location_on, size: 44, color: Colors.red),
          ),
        );
      }
    }

    for (final visit in _visits) {
      markers.add(
        Marker(
          point: LatLng(visit.latitude, visit.longitude),
          width: 52,
          height: 52,
          child: GestureDetector(
            onTap: () {
              _showVisitDetails(visit);
            },
            child: const Icon(Icons.location_on, size: 44, color: Colors.blue),
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildTripInfo() {
    if (_trip == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 16,
      right: 16,
      bottom: 20,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.route_outlined),
                  const SizedBox(width: 8),
                  const Text('Daily Route', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${_visits.length} visits', style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.straighten,
                      label: 'Distance',
                      value: _formatDistance(_trip!.totalDistance),
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.play_circle_outline,
                      label: 'Started',
                      value: _formatTime(_trip!.startTime),
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.stop_circle_outlined,
                      label: 'Ended',
                      value: _formatTime(_trip!.endTime),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Route')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Route')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_errorMessage!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final routePoints = _buildRoutePoints();

    if (routePoints.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Route')),
        body: const Center(child: Text('No GPS locations found for this trip.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Route'),
        actions: [IconButton(onPressed: _fitRouteToMap, tooltip: 'Fit route', icon: const Icon(Icons.fit_screen))],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: routePoints.first, initialZoom: 15),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.salesman_tracking_app',
              ),
              PolylineLayer(polylines: [Polyline(points: routePoints, strokeWidth: 5)]),
              MarkerLayer(markers: _buildMarkers()),
              RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
            ],
          ),
          _buildTripInfo(),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
