import 'package:flutter_bloc/flutter_bloc.dart';

class CalculatorCubitState {
  final String userInput;
  final String output;

  CalculatorCubitState(this.userInput, this.output);

  CalculatorCubitState copyWith({
    String? userInput,
    String? output,
  }) {
    return CalculatorCubitState(
      userInput ?? this.userInput,
      output ?? this.output,
    );
  }
}

class CalculatorCubit extends Cubit<CalculatorCubitState> {
  CalculatorCubit() : super(CalculatorCubitState("", ""));

  void updateUserInput(String value) {
    emit(state.copyWith(userInput: value));
  }

  void updateOutput() {
    // TODO: calculate output.
  }
}
