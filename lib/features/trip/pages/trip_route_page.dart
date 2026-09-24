import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:salesman_tracking_app/core/services/road_route_service.dart';
import 'package:salesman_tracking_app/core/widgets/app_app_bar.dart';
import 'package:salesman_tracking_app/domain/usecases/media/get_visit_media.dart';
import 'package:salesman_tracking_app/init_dependencies.dart';

import '../../../data/models/trip_location_model.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/models/visit_media_model.dart';
import '../../../data/models/visit_model.dart';
import '../../../domain/usecases/trips/get_trip_by_id.dart';
import '../../../domain/usecases/trips/get_trip_locations.dart';
import '../../../domain/usecases/visits/get_visits_for_trip.dart';
import '../widgets/trip_info_card.dart';
import '../widgets/trip_route_map.dart';

class TripRoutePage extends StatefulWidget {
  final String tripId;

  const TripRoutePage({super.key, required this.tripId});

  @override
  State<TripRoutePage> createState() => _TripRoutePageState();
}

class _TripRoutePageState extends State<TripRoutePage> {
  final GetTripById _getTripById = sl<GetTripById>();
  final GetTripLocations _getTripLocations = sl<GetTripLocations>();
  final GetVisitsForTrip _getVisitsForTrip = sl<GetVisitsForTrip>();
  final GetVisitMedia _getVisitMedia = sl<GetVisitMedia>();

  final RoadRouteService _roadRouteService = RoadRouteService();

  final MapController _mapController = MapController();

  List<TripLocationModel> _locations = [];
  List<LatLng> _roadRoutePoints = [];

  List<VisitModel> _visits = [];

  Map<String, List<VisitMediaModel>> _visitMedia = {};

  TripModel? _trip;

  bool _isLoading = true;
  bool _isBuildingRoadRoute = false;

  String? _errorMessage;
  String? _roadRouteError;

  @override
  void initState() {
    super.initState();
    _loadTripData();
  }

  Future<void> _loadTripData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final tripResult = await _getTripById(widget.tripId);

      final locationsResult = await _getTripLocations(widget.tripId);

      final visitsResult = await _getVisitsForTrip(widget.tripId);

      TripModel? trip;

      List<TripLocationModel> locations = [];

      List<VisitModel> visits = [];

      String? failureMessage;

      tripResult.fold(
        (failure) {
          failureMessage = failure.message;
        },
        (result) {
          trip = result as TripModel;
        },
      );

      if (failureMessage != null) {
        throw Exception(failureMessage);
      }

      locationsResult.fold(
        (failure) {
          failureMessage = failure.message;
        },
        (result) {
          locations = result.cast<TripLocationModel>();
        },
      );

      if (failureMessage != null) {
        throw Exception(failureMessage);
      }

      visitsResult.fold(
        (failure) {
          failureMessage = failure.message;
        },
        (result) {
          visits = result.cast<VisitModel>();
        },
      );

      if (failureMessage != null) {
        throw Exception(failureMessage);
      }

      final mediaMap = <String, List<VisitMediaModel>>{};

      for (final visit in visits) {
        final mediaResult = await _getVisitMedia(visit.id);

        mediaResult.fold(
          (failure) {
            failureMessage = failure.message;
          },
          (media) {
            mediaMap[visit.id] = media.cast<VisitMediaModel>();
          },
        );

        if (failureMessage != null) {
          throw Exception(failureMessage);
        }
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

      await _buildRoadRoute();

      if (!mounted) {
        return;
      }

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

  Future<void> _buildRoadRoute() async {
    if (_locations.length < 2) {
      return;
    }

    setState(() {
      _isBuildingRoadRoute = true;
      _roadRouteError = null;
    });

    try {
      final roadRoute = await _roadRouteService.buildRoadRoute(_locations);

      if (!mounted) {
        return;
      }

      setState(() {
        _roadRoutePoints = roadRoute;
        _isBuildingRoadRoute = false;
      });
    } on RoadRouteException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _roadRoutePoints = [];
        _roadRouteError = e.message;
        _isBuildingRoadRoute = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _roadRoutePoints = [];
        _roadRouteError = 'Unable to create the road route.';
        _isBuildingRoadRoute = false;
      });
    }
  }

  List<LatLng> _buildAllMapPoints() {
    return [
      ..._locations.map((location) => LatLng(location.latitude, location.longitude)),
      ..._visits.map((visit) => LatLng(visit.latitude, visit.longitude)),
    ];
  }

  List<LatLng> _buildDisplayedRoutePoints() {
    if (_roadRoutePoints.isNotEmpty) {
      return _roadRoutePoints;
    }

    return _locations.map((location) => LatLng(location.latitude, location.longitude)).toList();
  }

  void _fitRouteToMap() {
    final points = [..._buildAllMapPoints(), ..._roadRoutePoints];

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
  void dispose() {
    _roadRouteService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: const AppAppBar(title: 'Daily Route'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: const AppAppBar(title: 'Daily Route'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadTripData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final routePoints = _buildDisplayedRoutePoints();

    if (routePoints.isEmpty) {
      return Scaffold(
        appBar: const AppAppBar(title: 'Daily Route'),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No GPS locations were recorded for this trip.', textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Route'),
        actions: [IconButton(onPressed: _fitRouteToMap, tooltip: 'Fit route', icon: const Icon(Icons.fit_screen))],
      ),
      body: Stack(
        children: [
          TripRouteMap(
            mapController: _mapController,
            locations: _locations,
            roadRoutePoints: _roadRoutePoints,
            visits: _visits,
            visitMedia: _visitMedia,
          ),

          if (_trip != null)
            TripInfoCard(
              visitCount: _visits.length,
              distance: _formatDistance(_trip!.totalDistance),
              startTime: _formatTime(_trip!.startTime),
              endTime: _formatTime(_trip!.endTime),
            ),

          if (_isBuildingRoadRoute)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Building road route...', style: Theme.of(context).textTheme.bodyMedium)),
                    ],
                  ),
                ),
              ),
            ),

          // if (!_isBuildingRoadRoute && _roadRouteError != null)
          //   Positioned(
          //     top: 16,
          //     left: 16,
          //     right: 16,
          //     child: Card(
          //       elevation: 3,
          //       child: Padding(
          //         padding: const EdgeInsets.all(12),
          //         child: Row(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             const Icon(Icons.info_outline, size: 20),
          //             const SizedBox(width: 10),
          //             Expanded(
          //               child: Text(
          //                 'Road matching was unavailable. '
          //                 'The GPS trace is being displayed instead.',
          //                 style: Theme.of(context).textTheme.bodySmall,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
