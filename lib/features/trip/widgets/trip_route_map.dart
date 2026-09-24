import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/models/trip_location_model.dart';
import '../../../data/models/visit_media_model.dart';
import '../../../data/models/visit_model.dart';
import 'visit_details_sheet.dart';

class TripRouteMap extends StatelessWidget {
  final MapController mapController;
  final List<TripLocationModel> locations;
  final List<LatLng> roadRoutePoints;
  final List<VisitModel> visits;
  final Map<String, List<VisitMediaModel>> visitMedia;

  const TripRouteMap({
    super.key,
    required this.mapController,
    required this.locations,
    required this.roadRoutePoints,
    required this.visits,
    required this.visitMedia,
  });

  List<LatLng> _buildGpsPoints() {
    return locations.map((location) => LatLng(location.latitude, location.longitude)).toList();
  }

  List<LatLng> _buildDisplayedRoute() {
    if (roadRoutePoints.isNotEmpty) {
      return roadRoutePoints;
    }

    return _buildGpsPoints();
  }

  List<Marker> _buildMarkers(BuildContext context) {
    final markers = <Marker>[];

    if (locations.isNotEmpty) {
      final start = locations.first;

      markers.add(
        Marker(
          point: LatLng(start.latitude, start.longitude),
          width: 50,
          height: 50,
          child: const Icon(Icons.location_on, size: 44, color: Colors.green),
        ),
      );

      if (locations.length > 1) {
        final end = locations.last;

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

    for (final visit in visits) {
      markers.add(
        Marker(
          point: LatLng(visit.latitude, visit.longitude),
          width: 52,
          height: 52,
          child: GestureDetector(
            onTap: () {
              VisitDetailsSheet.show(context, visit: visit, media: visitMedia[visit.id] ?? []);
            },
            child: const Icon(Icons.location_on, size: 44, color: Colors.blue),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = _buildDisplayedRoute();

    if (routePoints.isEmpty) {
      return const Center(child: Text('No route locations available.'));
    }

    final isRoadRouteAvailable = roadRoutePoints.isNotEmpty;

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(initialCenter: routePoints.first, initialZoom: 15),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.salesman_tracking_app',
        ),

        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints,
              strokeWidth: isRoadRouteAvailable ? 5 : 4,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),

        MarkerLayer(markers: _buildMarkers(context)),

        RichAttributionWidget(attributions: const [TextSourceAttribution('OpenStreetMap contributors')]),
      ],
    );
  }
}
