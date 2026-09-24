import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationTrackingService {
  StreamSubscription<Position>? _positionSubscription;

  Position? _lastAcceptedPosition;

  /// Maximum GPS accuracy we accept.
  static const double _minimumAccuracyMeters = 40;

  /// Ignore movements smaller than this distance.
  static const double _minimumMovementMeters = 8;

  /// Ignore unrealistic GPS jumps.
  static const double _maximumJumpMeters = 300;

  Stream<Position> get positionStream {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    );
  }

  void start({required void Function(Position position) onPosition}) {
    stop();

    _lastAcceptedPosition = null;

    _positionSubscription = positionStream.listen(
      (position) {
        if (!_isValidPosition(position)) {
          return;
        }

        _lastAcceptedPosition = position;

        onPosition(position);
      },
      onError: (_) {
        // GPS stream errors should not crash the application.
        // The next valid GPS update can continue tracking.
      },
    );
  }

  bool _isValidPosition(Position position) {
    if (position.accuracy <= 0) {
      return false;
    }

    if (position.accuracy > _minimumAccuracyMeters) {
      return false;
    }

    final previous = _lastAcceptedPosition;

    if (previous == null) {
      return true;
    }

    final distance = Geolocator.distanceBetween(
      previous.latitude,
      previous.longitude,
      position.latitude,
      position.longitude,
    );

    // Ignore GPS noise and very small movements.
    if (distance < _minimumMovementMeters) {
      return false;
    }

    // Ignore unrealistic GPS jumps.
    if (distance > _maximumJumpMeters) {
      return false;
    }

    return true;
  }

  void stop() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _lastAcceptedPosition = null;
  }

  void dispose() {
    stop();
  }
}
