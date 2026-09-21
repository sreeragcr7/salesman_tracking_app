part of 'visit_bloc.dart';

@immutable
sealed class VisitState extends Equatable {
  const VisitState();
  @override
  List<Object?> get props => [];
}

class VisitInitial extends VisitState {
  const VisitInitial();
}

class VisitSubmitting extends VisitState {
  const VisitSubmitting();
}

class VisitSubmitted extends VisitState {
  final VisitModel visit;
  const VisitSubmitted(this.visit);
  @override
  List<Object?> get props => [visit];
}

class VisitFailure extends VisitState {
  final String message;
  const VisitFailure(this.message);
  @override
  List<Object?> get props => [message];
}
