import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationTrackingService {
  StreamSubscription<Position>? _positionSubscription;

  Stream<Position> get positionStream {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 2),
    );
  }

  void start({required void Function(Position position) onPosition}) {
    stop();

    _positionSubscription = positionStream.listen(onPosition);
  }

  void stop() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void dispose() {
    stop();
  }
}
