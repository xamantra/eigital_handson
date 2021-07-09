import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'index.dart';

// These are just shorthands for accessing individual cubits.
// Like, instead of calling "BlocProvider.of<AuthCubit>(context)" everytime.
// It can be called like this "authCubit(context)" which is a lot shorter.

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
