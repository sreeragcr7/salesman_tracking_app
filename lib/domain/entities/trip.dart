import 'package:equatable/equatable.dart';

class Trip extends Equatable {
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

  const Trip({
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

  @override
  List<Object?> get props => [
    id,
    userId,
    date,
    startTime,
    endTime,
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
    totalDistance,
    status,
  ];
}
