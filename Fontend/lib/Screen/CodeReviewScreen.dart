import 'dart:convert';

import 'package:code_text_field/code_text_field.dart';
import 'package:codesensei/Common/CustomTextField.dart';
import 'package:codesensei/Common/ScaffoldMessage.dart';
import 'package:codesensei/Theme/colors.dart';
import 'package:codesensei/router/app_router.dart';
import 'package:codesensei/router/serviceLocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:highlight/languages/dart.dart';
import 'package:http/http.dart' as http;

class CodeReviewScreen extends StatefulWidget {
  final String initialCode;

  CodeReviewScreen({required this.initialCode});

  State<CodeReviewScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeReviewScreen> {
  late final CodeController _codeController;
  final FocusNode _codeFocusNode = FocusNode();
  final _editorKey = GlobalKey();
  bool _copy = false;
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = true;
  String _error = '';
  int rating = 1;
  Future<void> fetchAiReview(String code) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.115:8080/api/review/code_review'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _suggestions = List<Map<String, dynamic>>.from(data['suggestions']);
        rating = data['rating'] ?? 1;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to fetch review');
    }
  }

  void _loadSuggestions(String code) async {
    try {
      await fetchAiReview(code);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: "${widget.initialCode}",
      language: dart,
    );
    _loadSuggestions(_codeController.text);
  }
  @override
  void dispose() {
    super.dispose();
    _codeController.dispose();
    _codeFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Code Review"),
        backgroundColor: isDarkMode ? DarkModeColor : LightModeColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      CodeTheme(
                        key: _editorKey,
                        data: CodeThemeData(
                          styles:
                              isDarkMode ? atomOneDarkTheme : atomOneLightTheme,
                        ),
                        child: SingleChildScrollView(
                          child: CodeField(
                            readOnly: true,
                            focusNode: _codeFocusNode,
                            cursorColor: primaryColor,
                            controller: _codeController,
                            textStyle: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
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
                            Clipboard.setData(
                                ClipboardData(text: _codeController.text));
                            setState(() {
                              _copy = true;
                            });
                            ScaffoldMessage.showSnackBar(context,
                                message: "Code Copy");
                            Future.delayed(Duration(seconds: 5),(){
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
                            child:
                                Icon(_copy?Icons.check:Icons.copy, size: 20, color: primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "AI Suggestions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: primaryColor,))
                    : _error.isNotEmpty
                    ? Center(child: Text("Error loading suggestions: $_error", style: TextStyle(color: Colors.red)))
                    : _suggestions.isEmpty
                    ? Center(child: Text("No suggestions available."))
                    : ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return _buildSingleSuggestion(_suggestions[index], isDarkMode);
                  },
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "AI Code Rating: ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...List.generate(5, (index) {
                    return Icon(
                      index <  rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    );
                  }),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    onPressed: () {
                      showModalBottomSheet(
                        useSafeArea: true,
                        context: context,
                        builder: (ctx) => const SaveReviewBottomSheet(),
                      );
                    },
                    icon: Icon(
                      Icons.save_alt,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    onPressed: ()  {
                      String updatedCode = _codeController.text;
                      for (var s in _suggestions) {
                        final original = s["original"];
                        final fix = s["fix"];
                        if (original != null && fix != null && original != fix) {
                          updatedCode = updatedCode.replaceAll(original, fix);
                        }
                      }
                      setState(() {
                        _codeController.text = updatedCode;
                      });
                       _loadSuggestions(_codeController.text);
                      ScaffoldMessage.showSnackBar(context, message: "All fixes applied");
                    },
                    icon: Icon(
                      Icons.build_circle_outlined,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Apply All Fixes",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleSuggestion(Map<String, dynamic> s, bool isDarkMode) {
    final type = s["type"] ?? "Suggestion";
    final message = s["message"] ?? "";
    final fix = s["fix"] ?? "";
    rating = s['rating'] ?? 0;

    return Card(
      color: isDarkMode
          ? DarkModeColor.withOpacity(0.3)
          : LightModeColor.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type,
              style: TextStyle(
                color: type.toLowerCase() == "error" ? Colors.red : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(message, style: TextStyle(fontSize: 14)),
            if (fix.isNotEmpty) ...[
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async{
                    final original = s["original"];
                    if (original != null && fix != null && original != fix) {
                      final updatedCode = _codeController.text.replaceFirst(original, fix);
                      setState(() {
                        _codeController.text = updatedCode;
                      });
                      _loadSuggestions(_codeController.text);
                      ScaffoldMessage.showSnackBar(context, message: "Fix applied");
                    }
                  },
                  icon: Icon(Icons.build_circle_outlined, color: primaryColor),
                  label: Text("Apply Fix", style: TextStyle(color: primaryColor)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
class SaveReviewBottomSheet extends StatefulWidget {
  const SaveReviewBottomSheet({super.key});

  @override
  State<SaveReviewBottomSheet> createState() => _SaveReviewBottomSheetState();
}

class _SaveReviewBottomSheetState extends State<SaveReviewBottomSheet> {
  final TextEditingController _reviewNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
       Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text("Save Code Review", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 18),
            CustomTextField(
              textEditingController: _reviewNameController,
              decoration: InputDecoration(
                labelText: "Review Name",
                contentPadding:  EdgeInsets.all(10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_alt,color: Colors.white,),
                label:  Text("Save Review",style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                   backgroundColor: primaryColor
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Trigger Rerun
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh,color: Colors.white,),
              label:  Text("Rerun review",style: TextStyle(color:Colors.white),),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor
                ),
              onPressed: () {
                final name = _reviewNameController.text.trim();
                if (name.isEmpty) return;

                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf,color: Colors.white,),
              label:  Text("Share as PDF",style: TextStyle(color:Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor
                ),
              onPressed: () {
                final name = _reviewNameController.text.trim();
                if (name.isEmpty) return;

                Navigator.pop(context);
              },
            ),
    ]
            ),
          ],
        ),
      ),
    );
  }
}

