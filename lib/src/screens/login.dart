import '../cubits/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/cubits.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: BlocBuilder<AuthCubit, AuthCubitState>(
            bloc: authCubit(context),
            builder: (context, snapshot) {
              if (snapshot.loading) {
                return Center(
                  child: SizedBox(
                    height: 64,
                    width: 64,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text('Facebook'),
                    onPressed: () {
                      authCubit(context).loginFacebook();
                    },
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    child: Text('Google'),
                    onPressed: () {
                      authCubit(context).loginGoogle();
                    },
                  ),
                ],
              );
            }),
      ),
    );
  }
}
