part of 'time_cubit.dart';

abstract class TimeState extends Equatable {
  const TimeState();

  @override
  List<Object> get props => [];
}

class TimeInitial extends TimeState {}

class TimeLoaded extends TimeState {
  final DateTime time;

  const TimeLoaded({required this.time});

  @override
  List<Object> get props => [time];
}
