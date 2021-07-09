import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_expressions/math_expressions.dart';

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
    emit(state.copyWith(userInput: state.userInput + value));
    _updateOutput();
  }

  void backspaceInput() {
    final input = state.userInput;
    if (input.length > 0) {
      emit(state.copyWith(userInput: input.substring(0, input.length - 1)));
    }
    _updateOutput();
  }

  void clearInput() {
    emit(state.copyWith(userInput: ''));
    _updateOutput();
  }

  void _updateOutput() {
    try {
      if (state.userInput.isEmpty) {
        emit(state.copyWith(output: ''));
        return;
      }
      Parser p = Parser();
      Expression exp = p.parse(state.userInput).simplify();
      ContextModel cm = ContextModel();
      final result = exp.evaluate(EvaluationType.REAL, cm);
      emit(state.copyWith(output: result.toString()));

      // emit(state.copyWith(output: state.userInput.interpret().toString()));

      // Expression expression = Expression.parse(state.userInput);
      // var context = <String, dynamic>{};
      // final evaluator = const ExpressionEvaluator();
      // var r = evaluator.eval(expression, context);
      // emit(state.copyWith(output: r.toString()));
    } catch (e) {
      emit(state.copyWith(output: 'Syntax Error'));
    }
  }
}
