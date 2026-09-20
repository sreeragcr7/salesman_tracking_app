

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'salesman_event.dart';
part 'salesman_state.dart';

class SalesmanBloc extends Bloc<SalesmanEvent, SalesmanState> {
  SalesmanBloc() : super(SalesmanInitial()) {
    on<SalesmanEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
