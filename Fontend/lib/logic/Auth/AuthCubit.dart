import 'dart:async';
import 'dart:convert';
import 'package:codesensei/logic/Auth/AuthState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  String baseUrl = "http://192.168.0.115:8080/api/auth";
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await http
          .post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      )
          .timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final token = data['token'];
        final username = data['username'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setString('username', username);
        await prefs.setString('userId', data['userId'].toString());
        emit(AuthSuccess());
      }else {
        emit(AuthFailure("Login failed: ${data['error'] ?? 'Unknown error'}"));
      }
    } on TimeoutException catch (_) {
      emit(AuthFailure("Request timed out. Please try again."));
    } catch (e) {
      emit(AuthFailure("Something went wrong: $e"));
    }
  }

  Future<void> signup(String email, String password, String username) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "username": username,
        }),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final token = data['token'];
        final username = data['username'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('authToken', token);
        await prefs.setString('userId', data['userId'].toString());
        emit(AuthSuccess());
      } else {
        final errorData = jsonDecode(response.body);
        emit(AuthFailure("Signup failed: ${errorData['message'] ?? 'Unknown error'}"));
      }
    }on TimeoutException catch(_){
      emit(AuthFailure("Request timed out. Please try again."));
    } catch (e) {
      emit(AuthFailure("Something went wrong: $e"));
    }
  }
  Future<void> checkAuthStatus() async {
    final _prefs =await SharedPreferences.getInstance();
    emit(AuthLoading());

    final token = _prefs.getString('authToken');
    if (token != null && token.isNotEmpty) {
      emit(AuthSuccess());
    } else {
      emit(AuthFailure("No Auth Token"));
    }
  }
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) {
        emit(AuthFailure("Google Sign-In was cancelled"));
        return;
      }
      final email = account.email;
      final name = account.displayName ?? "";
      final response = await http.post(
        Uri.parse("http://192.168.0.115:8080/api/auth/google"),
        body: {
          "email": email,
          "username": name,
        },
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("authToken", data["token"]);
        prefs.setString("userId", data["userId"].toString());
        emit(AuthSuccess());
      } else {
        emit(AuthFailure("Google SignIn Failed"));
      }
    } on TimeoutException catch(_){
      emit(AuthFailure("Request timed out. Please try again."));
    } catch (e) {
      emit(AuthFailure("Something went wrong: $e"));
    }
  }
  Future<void> Logout() async{
    final prefs = await SharedPreferences.getInstance();
     await prefs.remove('authToken');
  }
}