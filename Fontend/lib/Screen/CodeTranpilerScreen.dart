import 'dart:io';

import 'package:code_text_field/code_text_field.dart';
import 'package:codesensei/Common/ScaffoldMessage.dart';
import 'package:codesensei/Theme/colors.dart';
import 'package:codesensei/logic/OtherCubit/codeTranspilerCubit.dart';
import 'package:codesensei/router/serviceLocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/python.dart';

class CodeTranspilerScreen extends StatefulWidget {
  State<CodeTranspilerScreen> createState() => _CodeTranspilerScreenState();
}

class _CodeTranspilerScreenState extends State<CodeTranspilerScreen> {
  late final CodeController _codeController;
  final _ConverCodeController = CodeController(language: python);
  final _editorKey = GlobalKey();
  final _codeFocusNode = FocusNode();
  bool _copy = false;
  String _sourceLang = "Python";
  String? _targetLang = "JavaScript";

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: "//Paste Your Code Here",
      language: python,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _codeFocusNode.dispose();
    _codeController.dispose();
    _ConverCodeController.dispose();
  }
  Future<void> pickAndLoadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['py', 'txt', 'java', 'js', 'cpp', 'dart'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      setState(() {
        _codeController.text = content;
      });

      ScaffoldMessage.showSnackBar(
        context,
        message: "File Loaded Successfully",
        isError: false,
      );
    } else {
      ScaffoldMessage.showSnackBar(
        context,
        message: "File selection cancelled or failed",
        isError: true,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Convert Code"),
        backgroundColor: isDarkMode ? DarkModeColor : LightModeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Code Input",
                  style: TextStyle(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: size.width * 0.02),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CodeTheme(
                    key: _editorKey,
                    data: CodeThemeData(
                        styles:
                            isDarkMode ? atomOneDarkTheme : atomOneLightTheme),
                    child: SingleChildScrollView(
                      child: CodeField(
                        focusNode: _codeFocusNode,
                        cursorColor: primaryColor,
                        controller: _codeController,
                        textStyle: const TextStyle(
                            fontFamily: 'monospace', fontSize: 14),
                        lineNumberStyle: LineNumberStyle(
                          width: 60,
                          textStyle: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 1,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        minLines: 8,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.width * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Source Language",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: size.width * 0.04)),
                  Text("Target Language",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: size.width * 0.04)),
                ],
              ),
              SizedBox(height: size.width * 0.02),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      elevation: 0,
                      borderRadius: BorderRadius.circular(20),
                      dropdownColor: primaryColor.withOpacity(0.9),
                      value: _sourceLang,
                      items: ['Python', 'JavaScript', 'C++', 'Java']
                          .map((lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _sourceLang = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      elevation: 0,
                      dropdownColor: primaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      value: _targetLang,
                      items: ['JavaScript', 'Python', 'C++', 'Java']
                          .map((lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _targetLang = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.width * 0.06),
              Text("Converted Code",
                  style: TextStyle(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: size.width * 0.02),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      CodeTheme(
                        data: CodeThemeData(
                            styles: isDarkMode
                                ? atomOneDarkTheme
                                : atomOneLightTheme),
                        child: SingleChildScrollView(
                          child: CodeField(
                            readOnly: true,
                            cursorColor: primaryColor,
                            controller: _ConverCodeController,
                            textStyle: const TextStyle(
                                fontFamily: 'monospace', fontSize: 14),
                            lineNumberStyle: LineNumberStyle(
                              width: 50,
                              textAlign: TextAlign.right,
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            minLines: 7,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(
                                text: _ConverCodeController.text));
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
              SizedBox(height: size.width * 0.02),
              Text(
                  "Translate $_sourceLang to $_targetLang. Functionality preserved."),
              const SizedBox(height: 20),
              BlocConsumer<codeTranspilerCubit, ConvertCodeState>(
                listener: (context, state) {
                  if (state is ConvertCodeSuccess) {
                    _ConverCodeController.text = state.convertedCode;
                    _codeController.clear();
                    if (_targetLang == "Python") {
                      _ConverCodeController.language = python;
                    }
                    if (_targetLang == "Java") {
                      _ConverCodeController.language = java;
                    }
                    if (_targetLang == "JavaScript") {
                      _ConverCodeController.language = javascript;
                    }
                    if (_targetLang == "C++") {
                      _ConverCodeController.language = dart;
                    }
                  } else if (state is ConvertCodeFailure) {
                    ScaffoldMessage.showSnackBar(context, message: state.error);
                  }
                },
                builder: (context, state) {
                  if (state is ConvertCodeLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: () {
                      final sourceCode = _codeController.text;
                      if (sourceCode.isEmpty) {
                        ScaffoldMessage.showSnackBar(context,
                            message: "Please enter some code.");
                        return;
                      }
                      getit<codeTranspilerCubit>()
                          .convertCode(sourceCode, _sourceLang, _targetLang!);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 48)),
                    child: const Text("Convert",
                        style: TextStyle(color: Colors.white)),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: pickAndLoadFile,
                      child: const Text("Upload File",
                          style: TextStyle(color: primaryColor))),
                  TextButton(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _codeController.text));
                      },
                      child: const Text("Paste The Code",
                          style: TextStyle(color: primaryColor))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
