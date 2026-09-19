import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'visits_event.dart';
part 'visits_state.dart';

class VisitsBloc extends Bloc<VisitsEvent, VisitsState> {
  VisitsBloc() : super(VisitsInitial()) {
    on<VisitsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
