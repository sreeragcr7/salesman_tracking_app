class VisitModel {
  final String id;
  final String tripId;
  final String shopName;
  final String? description;
  final double latitude;
  final double longitude;
  final DateTime visitedAt;
  final String? mediaUrl;

  const VisitModel({
    required this.id,
    required this.tripId,
    required this.shopName,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.visitedAt,
    this.mediaUrl,
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
