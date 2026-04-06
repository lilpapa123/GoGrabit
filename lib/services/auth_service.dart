import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AuthService {
  final ApiService api;
  AuthService({ApiService? api}) : api = api ?? ApiService();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '281911183863-enfn4quokl3s2p0cjc5ql3cktddm27k4.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await api.register(name, email, password);
    final body = res['body'];
    if ((res['statusCode'] == 200 || res['statusCode'] == 201) &&
        body is Map &&
        body['token'] != null) {
      await _saveToken(body['token']);
      await _saveUser(body['user']);
    }
    return res;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await api.login(email, password);
    final body = res['body'];
    if (res['statusCode'] == 200 && body is Map && body['token'] != null) {
      await _saveToken(body['token']);
      await _saveUser(body['user']);
    }
    return res;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await _googleSignIn.signOut();
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Try signing in silently first (handles existing sessions)
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();

      // If not silently signed in, trigger the popup
      googleUser ??= await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint(
          '⚠️ Google Sign-In: User closed the popup OR initialization failed.',
        );
        return {
          'statusCode': 401,
          'body': {'error': 'Google Sign-In popup closed or cancelled'},
        };
      }

      // Note: In a real app, you'd send the idToken to your backend
      // and get a JWT back. For this demo/fix, we mimic the login success
      // based on the dummy Google Auth implementation in the backend if available.

      // Mocking back-end response for presentation purposes
      final mockUser = {
        'id': 'google_${googleUser.id}',
        'name': googleUser.displayName,
        'email': googleUser.email,
        'role': 'Customer',
      };

      await _saveToken('mock_google_token_${googleUser.id}');
      await _saveUser(mockUser);

      return {
        'statusCode': 200,
        'body': {
          'user': mockUser,
          'token': 'mock_google_token_${googleUser.id}',
        },
      };
    } catch (e) {
      debugPrint('❌ Google Sign-In Error: $e');
      return {
        'statusCode': 500,
        'body': {'error': 'Google Sign-In failed: ${e.toString()}'},
      };
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(dynamic user) async {
    final prefs = await SharedPreferences.getInstance();
    // Ensure we are saving the JSON representation
    if (user is Map<String, dynamic>) {
      await prefs.setString(_userKey, jsonEncode(user));
    } else {
      // Ideally should be a Map, but if it's already a string?
      // For safety, let's assume it's the raw map from the API response 'user' field
      await prefs.setString(_userKey, jsonEncode(user));
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_userKey);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  Future<void> updateLocalUser(Map<String, dynamic> user) async {
    await _saveUser(user);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await api.forgotPassword(email);
  }

  Future<Map<String, dynamic>> resetPassword(
      String email, String code, String newPassword) async {
    return await api.resetPassword(email, code, newPassword);
  }

  Future<Map<String, dynamic>> sendVerificationEmail(String email) async {
    return await api.sendVerificationEmail(email);
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    return await api.verifyEmail(email, code);
  }

  Future<Map<String, dynamic>> uploadProfileImage(
      dynamic file, String userId) async {
    // file is XFile
    return await api.uploadImage(file, userId: userId, target: 'profile');
  }
}
