import 'dart:convert';

import 'package:codesensei/Common/CustomTextField.dart';
import 'package:codesensei/Common/ScaffoldMessage.dart';
import 'package:codesensei/Screen/HomeScreen.dart';
import 'package:codesensei/Screen/signUpScreen.dart';
import 'package:codesensei/Theme/colors.dart';
import 'package:codesensei/logic/Auth/AuthCubit.dart';
import 'package:codesensei/logic/Auth/AuthState.dart';
import 'package:codesensei/router/app_router.dart';
import 'package:codesensei/router/serviceLocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _formkey = GlobalKey<FormState>();
  var showPassword = true;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Email-Address";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid emailAddress(eg:example@gmail.com)";
    }
    return null;
  }

  String? validPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a Password";
    }
    if (value.length < 6) {
      return "Password Must be atLeast 6 Character";
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    emailTextController.dispose();
    passwordTextController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
  }

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: getit<AuthCubit>() ,
      listener: (context, state) {
        if (state is AuthLoading) {
        } else if (state is AuthFailure) {
          ScaffoldMessage.showSnackBar(context,
              message: state.error, isError: true);
        } else if (state is AuthSuccess) {
          getit<AppRouter>().pushAndRemoveUntil(HomeScreen());
        }
      },
      builder:(context,state) {
        return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: size.width * 0.05),
              child: Column(
                children: [
                  SizedBox(
                    width: size.height * 0.11,
                    child: Image.asset("assets/images/CodeSenseiLogo.png"),
                  ),
                  SizedBox(height: size.width * 0.02),
                  Text(
                    "CodeSensei",
                    style: TextStyle(
                        fontSize: size.width * 0.12,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: size.width * 0.001),
                  Text(
                    "Your AI Code Mentor's",
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: size.width * 0.01),
                  Padding(
                    padding: EdgeInsets.only(top: 25, left: 20, right: 20),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          CustomTextField(
                            textEditingController: emailTextController,
                            keyboardType: TextInputType.emailAddress,
                            focusNode: _emailFocus,
                            validator: validateEmail,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: "Email",
                              suffixIcon: Icon(
                                Icons.email_outlined,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: size.width * 0.03),
                          CustomTextField(
                            textEditingController: passwordTextController,
                            keyboardType: TextInputType.text,
                            validator: validPassword,
                            focusNode: _passwordFocus,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            obscureText: showPassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                icon: !showPassword
                                    ? Icon(Icons.visibility_outlined)
                                    : Icon(Icons.visibility_off_outlined),
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.width * 0.02,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.grey[800]),
                            ),
                          ),
                          SizedBox(
                            height: size.width * 0.04,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (_formkey.currentState?.validate() ?? false) {
                                getit<AuthCubit>().login(
                                      emailTextController.text.trim(),
                                      passwordTextController.text.trim(),
                                    );
                              }
                            },
                            child: state is AuthLoading
                                ?  CircularProgressIndicator(color: primaryColor,)
                                : Center(
                                    child: Text(
                                    'Login',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: isDarkMode
                                              ? DarkModeColor
                                              : LightModeColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  )),
                          ),
                          SizedBox(
                            height: size.height * 0.03,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                color: isDarkMode
                                    ? LightModeColor
                                    : Colors.grey[450],
                              )),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Text('Or Login with'),
                              ),
                              Expanded(
                                  child: Divider(
                                color: isDarkMode
                                    ? LightModeColor
                                    : Colors.grey[450],
                              ))
                            ],
                          ),
                          SizedBox(
                            height: size.height * 0.008,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<AuthCubit>().signInWithGoogle();
                                },
                                icon: Image.asset('assets/images/google.png',
                                    width: 20),
                                label: Text("Google"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/images/githubDark.png',
                                  width: 20,
                                ),
                                label: Text("GitHub"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Don't have an Account!"),
                                  InkWell(
                                    onTap: () {
                                      getit<AppRouter>().push(Signupscreen());
                                    },
                                    child: Text(
                                      "Create Account",
                                      style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          color: primaryColor),
                                    ),
                                  )
                                ]),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
    );
  }
}
