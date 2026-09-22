import '../../domain/entities/visit_media.dart';

class VisitMediaModel extends VisitMedia {
  const VisitMediaModel({
    required super.id,
    required super.visitId,
    required super.mediaUrl,
    required super.mediaType,
    required super.createdAt,
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
