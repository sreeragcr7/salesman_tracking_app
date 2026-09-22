import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.userId,
    required super.date,
    super.startTime,
    super.endTime,
    super.startLatitude,
    super.startLongitude,
    super.endLatitude,
    super.endLongitude,
    required super.totalDistance,
    required super.status,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'].toString()),
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time'].toString()) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time'].toString()) : null,
      startLatitude: (json['start_latitude'] as num?)?.toDouble(),
      startLongitude: (json['start_longitude'] as num?)?.toDouble(),
      endLatitude: (json['end_latitude'] as num?)?.toDouble(),
      endLongitude: (json['end_longitude'] as num?)?.toDouble(),
      totalDistance: (json['total_distance'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'active',
    );
  }
}
