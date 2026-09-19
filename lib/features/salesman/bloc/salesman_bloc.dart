import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'salesman_event.dart';
part 'salesman_state.dart';

class SalesmanBloc extends Bloc<SalesmanEvent, SalesmanState> {
  SalesmanBloc() : super(SalesmanInitial()) {
    on<SalesmanEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
