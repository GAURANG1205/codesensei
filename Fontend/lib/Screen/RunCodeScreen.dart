import 'package:code_text_field/code_text_field.dart';
import 'package:codesensei/Common/CustomTextField.dart';
import 'package:codesensei/Theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import '../Common/ScaffoldMessage.dart';
class RunCodeScreen extends StatefulWidget {
  @override
  State<RunCodeScreen> createState() => _RunCodeScreenState();
}

class _RunCodeScreenState extends State<RunCodeScreen> {
  late final CodeController _codeController;
  final _textEditingController = TextEditingController();
  final _textFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();
  var _copy = false;
  String _selectedLanguage = "Python";

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: '//Paste Your Code Here\n  ',
      language: python,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _codeController.dispose();
    _textEditingController.dispose();
    _textFocusNode.dispose();
    _codeFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String _sourceLang = "Python";
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Run Code"),
        backgroundColor: isDarkMode ? DarkModeColor : LightModeColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Code editor
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]!
                        : Colors.grey,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CodeTheme(
                    data: CodeThemeData(
                      styles: Theme.of(context).brightness == Brightness.dark
                          ? atomOneDarkTheme
                          : atomOneLightTheme,
                    ),
                    child: SingleChildScrollView(
                      child: CodeField(
                        focusNode: _codeFocusNode,
                        cursorColor: primaryColor,
                        controller: _codeController,
                        textStyle: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                        lineNumberStyle: LineNumberStyle(
                          width: 60,
                          textAlign: TextAlign.right,
                          textStyle: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        minLines: 10,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.width * 0.1),
              // Language Dropdown
              DropdownButtonFormField<String>(
                menuMaxHeight: 170,
                icon: Icon(Icons.arrow_drop_down_circle_outlined),
                alignment: Alignment.topCenter,
                itemHeight: 50,
                elevation: 0,
                borderRadius: BorderRadius.circular(8),
                dropdownColor: primaryColor.withOpacity(0.6),
                value: _sourceLang,
                items: ['Python', 'JavaScript', 'C++', 'Java', 'Dart', 'Other']
                    .map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
              SizedBox(height: size.width * 0.07),
              // Input field
              Align(
                child: Text(
                  "Input",
                  style: TextStyle(fontSize: 20),
                ),
                alignment: Alignment.topLeft,
              ),
              CustomTextField(
                textEditingController: _textEditingController,
                focusNode: _textFocusNode,
                decoration: InputDecoration(
                    hintText: "Enter the Input", focusedBorder: null),
              ),
              SizedBox(height: size.width * 0.05),
              // Output display
              Align(
                child: Text(
                  "Output",
                  style: TextStyle(fontSize: 20),
                ),
                alignment: Alignment.topLeft,
              ),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDarkMode ? Colors.grey[800]! : Colors.grey,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                                "Output will appear here...",
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                ),
                              )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: _codeController.text));
                            setState(() {
                              _copy = true;
                            });
                            ScaffoldMessage.showSnackBar(context,
                                message: "Code Copied");
                            Future.delayed(Duration(seconds: 5), () {
                              setState(() {
                                _copy = false;
                              });
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(_copy ? Icons.check : Icons.copy,
                                size: 20, color: primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: size.width * 0.09,
              ),
              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  "Run Code",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
