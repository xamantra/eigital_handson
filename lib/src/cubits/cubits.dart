import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'index.dart';

AuthCubit authCubit(BuildContext context) {
  return BlocProvider.of<AuthCubit>(context);
}

MapCubit mapCubit(BuildContext context) {
  return BlocProvider.of<MapCubit>(context);
}

CalculatorCubit calculatorCubit(BuildContext context) {
  return BlocProvider.of<CalculatorCubit>(context);
}

FeedCubit feedCubit(BuildContext context) {
  return BlocProvider.of<FeedCubit>(context);
}
