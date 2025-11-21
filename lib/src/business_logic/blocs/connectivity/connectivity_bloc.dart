import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  late StreamSubscription _subscription;

  ConnectivityBloc() : super(const ConnectivityInitial()) {
    on<ConnectivityChanged>(_onConnectivityChanged);

    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      add(ConnectivityChanged(result as ConnectivityResult));
    });
  }

  void _onConnectivityChanged(
      ConnectivityChanged event, Emitter<ConnectivityState> emit) {
    if (event.result == ConnectivityResult.none) {
      emit(const ConnectivityDisconnected());
    } else {
      emit(const ConnectivityConnected());
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
