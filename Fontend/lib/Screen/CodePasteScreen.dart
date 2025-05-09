import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:code_text_field/code_text_field.dart';
import 'package:codesensei/Common/ScaffoldMessage.dart';
import 'package:codesensei/Screen/CodeReviewScreen.dart';
import 'package:codesensei/Theme/colors.dart';
import 'package:codesensei/router/app_router.dart';
import 'package:codesensei/router/serviceLocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:http/http.dart' as http;

class CodePasteScreen extends StatefulWidget {
  const CodePasteScreen({super.key});

  @override
  State<CodePasteScreen> createState() => _CodePasteScreenState();
}

class _CodePasteScreenState extends State<CodePasteScreen> {
  late final CodeController _codeController;
  final CodeFocusNode = FocusNode();
  final _editorKey = GlobalKey();
  bool isLoading = false;
  String? aiSummary;

  Future<void> fetchCodeReviewSummary() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessage.showSnackBar(context,
          message: "Code is empty!", isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.115:8080/api/review/summary'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          aiSummary = response.body;
        });
      } else {
        ScaffoldMessage.showSnackBar(context,
            message: "Error: ${response.statusCode}", isError: true);
      }
    }on TimeoutException catch (_) {
      ScaffoldMessage.showSnackBar(context,
          message: "Request Timeout", isError: true);
    }
    catch (e) {
      ScaffoldMessage.showSnackBar(context,
          message: "Network Error: $e", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: '//Paste Your Code Here\n  print:"Holla Amigo"',
      language: java,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
    CodeFocusNode.dispose();
  }

  Future<void> pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        _codeController.text = data.text!;
      });
      ScaffoldMessage.showSnackBar(context,
          message: "Code Pasted Successfully", isError: false);
    }
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
        backgroundColor: isDarkMode ? DarkModeColor : LightModeColor,
        title: const Text('Code Paste'),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_paste_go),
            onPressed: pasteFromClipboard,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                    key: _editorKey,
                    data: CodeThemeData(
                      styles: Theme.of(context).brightness == Brightness.dark
                          ? atomOneDarkTheme
                          : atomOneLightTheme,
                    ),
                    child: SingleChildScrollView(
                      child: CodeField(
                        focusNode: CodeFocusNode,
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
              SizedBox(height: size.width * 0.01),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    fetchCodeReviewSummary();
                  },
                  label: Text(
                    "Run",
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  icon: const Icon(
                    Icons.restart_alt_rounded,
                    color: primaryColor,
                  ),
                ),
              ),
              SizedBox(height: size.width * 0.03),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: pickAndLoadFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  label: const Text(
                    'Upload File',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Review Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const Center(child: CircularProgressIndicator(color: primaryColor,))
                    else if (aiSummary != null)
                      Text(
                        aiSummary!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      )
                    else
                      Text(
                            'No summary yet. Click "Run" to generate it.',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          getit<AppRouter>().push(CodeReviewScreen(
                              initialCode: _codeController.text.toString()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Review The Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
