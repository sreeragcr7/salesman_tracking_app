import 'package:equatable/equatable.dart';

class Visit extends Equatable {
  final String id;
  final String tripId;
  final String shopName;
  final String? description;
  final double latitude;
  final double longitude;
  final DateTime visitedAt;
  final String? mediaUrl;

  const Visit({
    required this.id,
    required this.tripId,
    required this.shopName,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.visitedAt,
    this.mediaUrl,
  });

  @override
  List<Object?> get props => [id, tripId, shopName, description, latitude, longitude, visitedAt, mediaUrl];
}
