import 'package:bloc/bloc.dart';

mixin SafeEmitMixin<State> on Cubit<State> {
  /// Safely emits a new state if the Cubit is not closed
  void safeEmit(State state) {
    if (!isClosed) {
      emit(state);
    }
  }
}