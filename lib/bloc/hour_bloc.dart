import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

// part 'hour_event.dart';
// part 'hour_state.dart';

@immutable
abstract class HourEvent {}

class SetHour extends HourEvent {
  final int hour;

  SetHour(this.hour);

  List<Object> get props => [hour];
}

abstract class HourState {}

class HourInitial extends HourState {}

class LoadedHour extends HourState {
  final String hour;

  LoadedHour({required this.hour});
}

class HourBloc extends Bloc<HourEvent, HourState> {
  HourBloc() : super(HourInitial()) {
    on<SetHour>((event, emit) {
      var hour = event.hour.toString();
      if (hour.length < 2) {
        hour = '0' + hour;
      }
      emit(LoadedHour(hour: hour));
    });
  }
}