import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';

part 'time_state.dart';

class TimeCubit extends Cubit<TimeState> {
  Timer? _timer;

  TimeCubit() : super(TimeInitial()) {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      emit(TimeLoaded(time: now));
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
