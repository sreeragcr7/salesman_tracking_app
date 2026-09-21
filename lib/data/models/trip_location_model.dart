class TripLocationModel {
  final String id;
  final String tripId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracy;

  const TripLocationModel({
    required this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
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
