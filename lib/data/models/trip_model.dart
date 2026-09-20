class TripModel {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final double totalDistance;
  final String status;

  const TripModel({
    required this.id,
    required this.userId,
    required this.date,
    this.startTime,
    this.endTime,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    required this.totalDistance,
    required this.status,
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
