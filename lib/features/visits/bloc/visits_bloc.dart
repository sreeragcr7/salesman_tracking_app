

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'visits_event.dart';
part 'visits_state.dart';

class VisitsBloc extends Bloc<VisitsEvent, VisitsState> {
  VisitsBloc() : super(VisitsInitial()) {
    on<VisitsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
