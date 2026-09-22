import '../../domain/entities/trip_location.dart';

class TripLocationModel extends TripLocation {
  const TripLocationModel({
    required super.id,
    required super.tripId,
    required super.latitude,
    required super.longitude,
    required super.timestamp,
    super.accuracy,
  });

  factory TripLocationModel.fromJson(Map<String, dynamic> json) {
    return TripLocationModel(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'].toString()),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );
  }
}
