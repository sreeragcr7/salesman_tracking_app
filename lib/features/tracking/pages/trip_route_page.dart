import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/models/trip_location_model.dart';
import '../../../data/repositories/user_repository.dart';

class TripRoutePage extends StatefulWidget {
  final String tripId;

  const TripRoutePage({super.key, required this.tripId});

  @override
  State<TripRoutePage> createState() => _TripRoutePageState();
}

class _TripRoutePageState extends State<TripRoutePage> {
  final UserRepository _userRepository = UserRepository();

  List<TripLocationModel> _locations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTripLocations();
  }

  Future<void> _loadTripLocations() async {
    try {
      final locations = await _userRepository.getTripLocations(widget.tripId);

      if (!mounted) {
        return;
      }

      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<LatLng> _buildRoutePoints() {
    return _locations.map((location) => LatLng(location.latitude, location.longitude)).toList();
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

    if (_locations.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Route')),
        body: const Center(child: Text('No GPS locations found for this trip.')),
      );
    }

    final routePoints = _buildRoutePoints();

    final firstPoint = routePoints.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Route')),
      body: FlutterMap(
        options: MapOptions(initialCenter: firstPoint, initialZoom: 17),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.salesman_tracking_app',
          ),

          PolylineLayer(polylines: [Polyline(points: routePoints, strokeWidth: 5)]),

          MarkerLayer(
            markers: [
              Marker(
                point: routePoints.first,
                width: 50,
                height: 50,
                child: const Icon(Icons.location_on, size: 42, color: Colors.green),
              ),
              Marker(
                point: routePoints.last,
                width: 50,
                height: 50,
                child: const Icon(Icons.location_on, size: 42, color: Colors.red),
              ),
            ],
          ),

          RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
        ],
      ),
    );
  }
}
