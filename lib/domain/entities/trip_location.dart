import 'package:equatable/equatable.dart';

class TripLocation extends Equatable {
  final String id;
  final String tripId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  const TripLocation({
    required this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, tripId, latitude, longitude, accuracy, timestamp];
}
