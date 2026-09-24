import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../data/models/trip_location_model.dart';

class RoadRouteService {
  static const String _baseUrl = 'https://router.project-osrm.org';

  /// Number of GPS points sent in one map-matching request.
  static const int _chunkSize = 40;

  /// Prevent extremely large requests for long working days.
  static const int _maxRoutePoints = 250;

  final http.Client _client;

  RoadRouteService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<LatLng>> buildRoadRoute(List<TripLocationModel> locations) async {
    if (locations.isEmpty) {
      return [];
    }

    if (locations.length == 1) {
      return [LatLng(locations.first.latitude, locations.first.longitude)];
    }

    final cleanedLocations = _prepareLocations(locations);

    final routePoints = <LatLng>[];

    for (var start = 0; start < cleanedLocations.length - 1; start += _chunkSize - 1) {
      final end = (start + _chunkSize).clamp(0, cleanedLocations.length);

      final chunk = cleanedLocations.sublist(start, end);

      if (chunk.length < 2) {
        break;
      }

      final matchedPoints = await _matchChunk(chunk);

      if (matchedPoints.isEmpty) {
        continue;
      }

      if (routePoints.isNotEmpty && _areClose(routePoints.last, matchedPoints.first)) {
        routePoints.addAll(matchedPoints.skip(1));
      } else {
        routePoints.addAll(matchedPoints);
      }

      if (end >= cleanedLocations.length) {
        break;
      }
    }

    if (routePoints.length < 2) {
      throw const RoadRouteException('The recorded GPS trace could not be matched to the road network.');
    }

    return routePoints;
  }

  Future<List<LatLng>> _matchChunk(List<TripLocationModel> locations) async {
    final coordinates = locations
        .map(
          (location) =>
              '${location.longitude.toStringAsFixed(6)},'
              '${location.latitude.toStringAsFixed(6)}',
        )
        .join(';');

    final timestamps = locations
        .map((location) => (location.timestamp.millisecondsSinceEpoch ~/ 1000).toString())
        .join(';');

    final radiuses = locations.map(_buildRadius).join(';');

    final uri = Uri.parse(
      '$_baseUrl/match/v1/driving/$coordinates'
      '?overview=full'
      '&geometries=geojson'
      '&steps=false'
      '&gaps=split'
      '&tidy=true'
      '&timestamps=$timestamps'
      '&radiuses=$radiuses',
    );

    late http.Response response;

    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json', 'User-Agent': 'SalesmanTrackingApp/1.0'})
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const RoadRouteException('Road matching timed out. Please try again.');
    } catch (e) {
      throw RoadRouteException('Unable to connect to the road matching service: $e');
    }

    if (response.statusCode != 200) {
      throw RoadRouteException(
        'Road matching service returned HTTP '
        '${response.statusCode}.',
      );
    }

    final Map<String, dynamic> data;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException();
      }

      data = decoded;
    } catch (_) {
      throw const RoadRouteException('Invalid response received from the road matching service.');
    }

    final code = data['code']?.toString();

    if (code != 'Ok') {
      throw RoadRouteException(_readOsrmError(data));
    }

    final matchings = data['matchings'];

    if (matchings is! List || matchings.isEmpty) {
      return [];
    }

    final points = <LatLng>[];

    for (final matching in matchings) {
      if (matching is! Map) {
        continue;
      }

      final geometry = matching['geometry'];

      if (geometry is! Map) {
        continue;
      }

      final coordinates = geometry['coordinates'];

      if (coordinates is! List) {
        continue;
      }

      for (final coordinate in coordinates) {
        if (coordinate is! List || coordinate.length < 2) {
          continue;
        }

        final longitude = (coordinate[0] as num).toDouble();

        final latitude = (coordinate[1] as num).toDouble();

        points.add(LatLng(latitude, longitude));
      }
    }

    return points;
  }

  String _buildRadius(TripLocationModel location) {
    final accuracy = location.accuracy ?? 25;

    /*
     * Do not give OSRM an unrealistically
     * small GPS radius.
     *
     * Phone GPS can easily fluctuate by
     * several meters even when stationary.
     */
    final radius = accuracy.clamp(15.0, 75.0);

    return radius.toStringAsFixed(1);
  }

  String _readOsrmError(Map<String, dynamic> data) {
    final code = data['code']?.toString();

    final message = data['message']?.toString();

    if (code == 'NoMatch') {
      return 'OSRM could not match this GPS trace to a drivable road.';
    }

    if (message != null && message.isNotEmpty) {
      return message;
    }

    return 'Road matching failed ($code).';
  }

  List<TripLocationModel> _prepareLocations(List<TripLocationModel> locations) {
    if (locations.length <= _maxRoutePoints) {
      return locations;
    }

    final result = <TripLocationModel>[locations.first];

    final interiorCount = _maxRoutePoints - 2;

    for (var i = 1; i <= interiorCount; i++) {
      final index = ((i * (locations.length - 1)) / (interiorCount + 1)).round();

      result.add(locations[index]);
    }

    result.add(locations.last);

    return result;
  }

  bool _areClose(LatLng first, LatLng second) {
    const tolerance = 0.00001;

    return (first.latitude - second.latitude).abs() < tolerance &&
        (first.longitude - second.longitude).abs() < tolerance;
  }

  void dispose() {
    _client.close();
  }
}

class RoadRouteException implements Exception {
  final String message;

  const RoadRouteException(this.message);

  @override
  String toString() => message;
}
