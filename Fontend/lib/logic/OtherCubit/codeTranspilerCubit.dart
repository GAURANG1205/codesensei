import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
abstract class ConvertCodeState {}

class ConvertCodeInitial extends ConvertCodeState {}

class ConvertCodeLoading extends ConvertCodeState {}

class ConvertCodeSuccess extends ConvertCodeState {
  final String convertedCode;
  ConvertCodeSuccess(this.convertedCode);
}

class ConvertCodeFailure extends ConvertCodeState {
  final String error;
  ConvertCodeFailure(this.error);
}

class codeTranspilerCubit extends Cubit<ConvertCodeState> {
  codeTranspilerCubit() : super(ConvertCodeInitial());

  final String geminiApiKey = 'AIzaSyCdZ9vph_8qmNP_WwmEVcWDbMtjx_akZps';
  final String groqApiKey = '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';
  final String deepseekApiKey = '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';

  Future<void> convertCode(String sourceCode, String sourceLang,
      String targetLang) async {
    emit(ConvertCodeLoading());
    final lines = sourceCode.trim().split('\n');
    final codeAfterFirstLine = lines.skip(1).join('\n').trim();
    if (codeAfterFirstLine.isEmpty) {
      emit(ConvertCodeFailure("Add some code "));
      return;
    }
    final prompt = """
  Convert the following code from $sourceLang to $targetLang:

  $sourceCode

  Make sure the functionality is preserved. Return only the converted code without any extra explanation and Don't add Extra Line
  """;

    final List<Future<String?>> apiCalls = [
      _callGroqApi(prompt),
      _callGeminiApi(prompt),
      _callDeepseekApi(prompt),
    ];

    try {
      final results = await Future.wait(apiCalls);
      final successfulResult = results.firstWhere(
            (result) => result != null && result.isNotEmpty,
        orElse: () => null,
      );
      if (successfulResult != null) {
        emit(ConvertCodeSuccess(successfulResult.trim()));
      } else {
        emit(ConvertCodeFailure("All AI APIs failed or quota exceeded."));
      }
    } catch (e) {
      emit(ConvertCodeFailure(
          "An error occurred while converting the code: $e"));
    }
  }

  String _extractCode(String rawResponse) {
    final RegExp codeBlock = RegExp(r'```(?:[a-zA-Z]+\n)?([\s\S]*?)```');
    final match = codeBlock.firstMatch(rawResponse);
    if (match != null) {
      return match.group(1)?.trim() ?? rawResponse.trim();
    } else {
      return rawResponse.trim();
    }
  }

  Future<String?> _callGeminiApi(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String code = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            '';
        code = _extractCode(code);
        return code;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> _callGroqApi(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama3-70b-8192",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.2,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> _callDeepseekApi(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.deepseek.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $deepseekApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "deepseek-coder",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.2,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}