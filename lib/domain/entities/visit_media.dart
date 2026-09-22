import 'package:equatable/equatable.dart';

class VisitMedia extends Equatable {
  final String id;
  final String visitId;
  final String mediaUrl;
  final String mediaType;
  final DateTime createdAt;

  const VisitMedia({
    required this.id,
    required this.visitId,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, visitId, mediaUrl, mediaType, createdAt];
}
