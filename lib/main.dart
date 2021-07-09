import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/cubits/index.dart';
import 'src/screens/index.dart';
import 'src/screens/login.dart';
import 'src/utils/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSharedPreferences();
  await Firebase.initializeApp();
  runApp(RootWidget());
}

class RootWidget extends StatefulWidget {
  const RootWidget({Key? key}) : super(key: key);

  @override
  _RootWidgetState createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  final AuthCubit authCubit = AuthCubit();
  final CalculatorCubit calculatorCubit = CalculatorCubit();
  final MapCubit mapCubit = MapCubit();

  bool _loggedIn = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() async {
      authCubit.stream.listen((event) {
        setState(() {
          _loggedIn = event.loggedIn;
        });
      });
      await authCubit.init();
      // await mapCubit.initMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => authCubit),
        BlocProvider(create: (_) => calculatorCubit),
        BlocProvider(create: (_) => mapCubit),
      ],
      child: MyApp(
        initialScreen: _loggedIn ? DashboardScreen() : LoginScreen(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({
    Key? key,
    required this.initialScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eigital hands-on exam app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: initialScreen,
    );
  }
}
