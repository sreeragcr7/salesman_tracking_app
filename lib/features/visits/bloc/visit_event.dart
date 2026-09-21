part of 'visit_bloc.dart';

@immutable
sealed class VisitEvent extends Equatable {
  const VisitEvent();
  @override
  List<Object?> get props => [];
}

class VisitSubmissionRequested extends VisitEvent {
  final String tripId;
  final String shopName;
  final String description;
  final List<File> mediaFiles;
  const VisitSubmissionRequested({
    required this.tripId,
    required this.shopName,
    required this.description,
    this.mediaFiles = const [],
  });
  @override
  List<Object?> get props => [tripId, shopName, description, mediaFiles.map((file) => file.path).toList()];
}
