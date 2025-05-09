import 'package:codesensei/Screen/HomeScreen.dart';
import 'package:codesensei/Screen/LoginScreen.dart';
import 'package:codesensei/logic/Auth/AuthCubit.dart';
import 'package:codesensei/logic/Auth/AuthState.dart';
import 'package:codesensei/router/app_router.dart';
import 'package:codesensei/router/serviceLocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class AuthInitialization extends StatefulWidget {
  @override
  _AuthInitializationState createState() => _AuthInitializationState();
}
class _AuthInitializationState extends State<AuthInitialization> {
  @override
  void initState() {
    super.initState();
   context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          FlutterNativeSplash.remove();
          getit<AppRouter>().pushAndRemoveUntil(HomeScreen());
        } else if (state is AuthFailure) {
          FlutterNativeSplash.remove();
          getit<AppRouter>().pushAndRemoveUntil(LoginScreen());
        }
      },
      child:const Scaffold(
              body: Center(),
            )
    );
          }
  }

