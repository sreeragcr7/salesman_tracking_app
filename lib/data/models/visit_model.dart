import '../../domain/entities/visit.dart';

class VisitModel extends Visit {
  const VisitModel({
    required super.id,
    required super.tripId,
    required super.shopName,
    super.description,
    required super.latitude,
    required super.longitude,
    required super.visitedAt,
    super.mediaUrl,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      shopName: json['shop_name'] as String? ?? '',
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      visitedAt: DateTime.parse(json['visited_at'].toString()),
      mediaUrl: json['media_url'] as String?,
    );
  }
}
