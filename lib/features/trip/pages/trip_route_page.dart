import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/models/trip_location_model.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/models/visit_media_model.dart';
import '../../../data/models/visit_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../widgets/trip_info_card.dart';
import '../widgets/trip_route_map.dart';

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

      if (!mounted) {
        return;
      }

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
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<LatLng> _buildAllMapPoints() {
    return [
      ..._locations.map((location) => LatLng(location.latitude, location.longitude)),
      ..._visits.map((visit) => LatLng(visit.latitude, visit.longitude)),
    ];
  }

  List<LatLng> _buildRoutePoints() {
    return _locations.map((location) => LatLng(location.latitude, location.longitude)).toList();
  }

  void _fitRouteToMap() {
    final points = _buildAllMapPoints();

    if (points.isEmpty) {
      return;
    }

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
          TripRouteMap(mapController: _mapController, locations: _locations, visits: _visits, visitMedia: _visitMedia),
          if (_trip != null)
            TripInfoCard(
              visitCount: _visits.length,
              distance: _formatDistance(_trip!.totalDistance),
              startTime: _formatTime(_trip!.startTime),
              endTime: _formatTime(_trip!.endTime),
            ),
        ],
      ),
    );
  }
}
