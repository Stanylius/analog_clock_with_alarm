import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

// part 'minute_event.dart';
// part 'minute_state.dart';

@immutable
abstract class MinuteEvent {}

class SetMinute extends MinuteEvent {
  final int minute;

  SetMinute(this.minute);

  List<Object> get props => [minute];
}


abstract class MinuteState {}

class MinuteInitial extends MinuteState {}

class LoadedMinute extends MinuteState {
  final String minute;

  LoadedMinute({required this.minute});
}

class MinuteBloc extends Bloc<MinuteEvent, MinuteState> {
  MinuteBloc() : super(MinuteInitial()) {
    on<SetMinute>((event, emit) {
      var minute = event.minute.toString();
      if (minute.length < 2) {
        minute = '0' + minute;
      }
      emit(LoadedMinute(minute: minute));
    });
  }
}