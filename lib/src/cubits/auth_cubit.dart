import 'dart:convert';

import 'package:eigital_handson/src/utils/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCubitState {
  final String name;
  final bool loading;

  bool get loggedIn => name.isNotEmpty;

  AuthCubitState([this.name = '', this.loading = false]);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'loading': loading,
    };
  }

  factory AuthCubitState.fromMap(Map<String, dynamic> map) {
    return AuthCubitState(
      map['name'],
      map['loading'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthCubitState.fromJson(String source) => AuthCubitState.fromMap(json.decode(source));

  AuthCubitState copyWith({
    String? name,
    bool? loading,
  }) {
    return AuthCubitState(
      name ?? this.name,
      loading ?? this.loading,
    );
  }
}

class AuthCubit extends Cubit<AuthCubitState> {
  AuthCubit() : super(AuthCubitState());

  Future<void> init() async {
    final json = sharedPreferences.getString(AUTH_STATE_KEY);
    if (json != null) {
      updateState(AuthCubitState.fromJson(json));
    }
  }

  void loginFacebook() async {
    updateState(state.copyWith(loading: true));
    // TODO: login with facebook
  }

  void loginGoogle() async {
    updateState(state.copyWith(loading: true));
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await FirebaseAuth.instance.signInWithCredential(credential);
      updateState(state.copyWith(name: cred.user?.displayName));
    }
    updateState(state.copyWith(loading: false));
  }

  void updateState(AuthCubitState state) async {
    emit(state);
    await sharedPreferences.setString(AUTH_STATE_KEY, state.toJson());
  }
}
