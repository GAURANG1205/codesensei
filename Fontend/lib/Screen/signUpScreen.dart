import 'dart:convert';

import 'package:codesensei/Common/CustomTextField.dart';
import 'package:codesensei/Common/ScaffoldMessage.dart';
import 'package:codesensei/Screen/HomeScreen.dart';
import 'package:codesensei/Screen/LoginScreen.dart';
import 'package:codesensei/Theme/colors.dart';
import 'package:codesensei/logic/Auth/AuthCubit.dart';
import 'package:codesensei/logic/Auth/AuthState.dart';
import 'package:codesensei/router/app_router.dart';
import 'package:codesensei/router/serviceLocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Signupscreen extends StatefulWidget {
  State<Signupscreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<Signupscreen> {
  final UserNameController = TextEditingController();
  final ConfirmPasswordController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final _userNameFocus = FocusNode();
  final _cnfPasswordFocus = FocusNode();
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

  String? validConfPassword(String? value) {
    if (passwordTextController.text.trim() !=
        ConfirmPasswordController.text.trim()) {
      return "Password Doesn't match";
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    emailTextController.dispose();
    passwordTextController.dispose();
    UserNameController.dispose();
    ConfirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _userNameFocus.dispose();
    _cnfPasswordFocus.dispose();
  }

  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final isDarkMode =
        MediaQuery
            .of(context)
            .platformBrightness == Brightness.dark;
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: getit<AuthCubit>(),
      listener: (context, state) {
        if (state is AuthLoading) {
        } else if (state is AuthFailure) {
          ScaffoldMessage.showSnackBar(context,
              message: state.error, isError: true);
        } else if (state is AuthSuccess) {
          getit<AppRouter>().pushAndRemoveUntil(HomeScreen());
        }
      },
  builder: (context ,state) {
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
                      fontSize: size.width * 0.12, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: size.width * 0.001),
                Text(
                  "Let's get started",
                  style: TextStyle(
                    fontSize: size.width * 0.07,
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
                          textEditingController: UserNameController,
                          keyboardType: TextInputType.name,
                          focusNode: _userNameFocus,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            labelText: "Username",
                            suffixIcon: Icon(
                              Icons.person_3_outlined,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: size.width * 0.03),
                        CustomTextField(
                          textEditingController: emailTextController,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: _emailFocus,
                          validator: validateEmail,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          focusNode: _passwordFocus,
                          obscureText: showPassword,
                          validator: validPassword,
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
                        SizedBox(height: size.width * 0.03),
                        CustomTextField(
                          textEditingController: ConfirmPasswordController,
                          keyboardType: TextInputType.text,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          obscureText: showPassword,
                          focusNode: _cnfPasswordFocus,
                          validator: validConfPassword,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
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
                          height: size.width * 0.04,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (_formkey.currentState?.validate() ?? false) {
                              getit<AuthCubit>().signup(
                                emailTextController.text.trim(),
                                passwordTextController.text.trim(),
                                UserNameController.text.trim()
                              );
                            }
                          },
                          child: state is AuthLoading?
                          const CircularProgressIndicator(color: primaryColor,):
                          Center(
                              child: Text(
                                'Sign Up',
                                style:
                                Theme
                                    .of(context)
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
                          height: size.height * 0.05,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text("Already have A Account?"),
                                SizedBox(width: size.width * 0.015),
                                InkWell(
                                  onTap: () {
                                    getit<AppRouter>().push(LoginScreen());
                                  },
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: size.width * 0.045,
                                      color: primaryColor,
                                    ),
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
  },
);
  }
}
