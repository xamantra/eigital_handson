import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/index.dart';

class CalculatorScreenView extends StatelessWidget {
  const CalculatorScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<CalculatorCubit, CalculatorCubitState>(
          bloc: calculatorCubit(context),
          builder: (context, snapshot) {
            return Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    snapshot.userInput,
                    style: TextStyle(
                      fontSize: 32,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    snapshot.output,
                    style: TextStyle(
                      fontSize: 28,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 75,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _CalculatorButton(value: '(')),
                          Expanded(child: _CalculatorButton(value: ')')),
                          Expanded(child: _BackspaceButton()),
                          Expanded(child: _ClearButton()),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _CalculatorButton(value: '7')),
                          Expanded(child: _CalculatorButton(value: '8')),
                          Expanded(child: _CalculatorButton(value: '9')),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _CalculatorButton(value: '4')),
                          Expanded(child: _CalculatorButton(value: '5')),
                          Expanded(child: _CalculatorButton(value: '6')),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _CalculatorButton(value: '1')),
                          Expanded(child: _CalculatorButton(value: '2')),
                          Expanded(child: _CalculatorButton(value: '3')),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _CalculatorButton(value: '.')),
                          Expanded(child: _CalculatorButton(value: '0')),
                          Expanded(child: _CalculatorButton(value: '=')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 25,
                child: Column(
                  children: [
                    Expanded(child: _CalculatorButton(value: '/')),
                    Expanded(child: _CalculatorButton(value: '*')),
                    Expanded(child: _CalculatorButton(value: '-')),
                    Expanded(child: _CalculatorButton(value: '+')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    Key? key,
    required this.value,
  }) : super(key: key);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          calculatorCubit(context).updateUserInput(value);
        },
        child: Text(
          value,
          style: TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}

class _BackspaceButton extends StatelessWidget {
  const _BackspaceButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: TextButton(
        child: Icon(
          Icons.backspace,
          color: Theme.of(context).primaryColor,
          size: 32,
        ),
        onPressed: () {
          calculatorCubit(context).backspaceInput();
        },
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: TextButton(
        child: Text(
          'C',
          style: TextStyle(fontSize: 32),
        ),
        onPressed: () {
          calculatorCubit(context).clearInput();
        },
      ),
    );
  }
}
