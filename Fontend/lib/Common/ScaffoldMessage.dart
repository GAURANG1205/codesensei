import 'package:codesensei/Theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScaffoldMessage{
  static void showSnackBar(
      BuildContext context, {
        required String message,
        bool isError = false,
        Duration duration = const Duration(seconds: 2),
      }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:  TextStyle(
            color:  isError?Colors.white:DarkModeColor
          ),
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }
}