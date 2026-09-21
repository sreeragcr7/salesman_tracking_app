class VisitMediaModel {
  final String id;
  final String visitId;
  final String mediaUrl;
  final String mediaType;
  final DateTime createdAt;

  const VisitMediaModel({
    required this.id,
    required this.visitId,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
  });

  bool get isVideo => mediaType == 'video';

  bool get isImage => mediaType == 'image';

  factory VisitMediaModel.fromJson(Map<String, dynamic> json) {
    return VisitMediaModel(
      id: json['id'] as String,
      visitId: json['visit_id'] as String,
      mediaUrl: json['media_url'] as String,
      mediaType: json['media_type'] as String,
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }
}
