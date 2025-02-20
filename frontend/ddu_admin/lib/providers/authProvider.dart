import 'dart:convert';
import 'package:ddu_admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String baseUrl = AppConstants.baseUrl;
  String? _accessToken;
  bool _isAuthenticated = false;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get accessToken => _accessToken;

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    try {
      await _secureStorage.write(key: 'accessToken', value: accessToken);
      await _secureStorage.write(key: 'refreshToken', value: refreshToken);
      print("Tokens saved successfully.");
    } catch (error) {
      print("Error saving tokens: $error");
    }
  }

  Future<void> tryAutoLogin() async {
    print("Attempting auto-login...");
    _isLoading = true;
    notifyListeners();

    _accessToken = await _secureStorage.read(key: 'accessToken');

    if (_accessToken == null) {
      print("No access token found. User is not authenticated.");
      _isAuthenticated = false;
    } else {
      final url = Uri.parse('$baseUrl/auth/validateToken');
      try {
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          print("Access token is valid.");
          _isAuthenticated = true;
        } else if (response.statusCode == 403 || response.statusCode == 401) {
          print("Access token expired or invalid. Attempting refresh...");
          await refreshToken();
        } else {
          print("Invalid token. Logging out.");
          await logout();
        }
      } catch (error) {
        print("Auto-login error: $error");
        _isAuthenticated = false;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshToken() async {
    print("Attempting to refresh token...");
    final refreshToken = await _secureStorage.read(key: 'refreshToken');

    if (refreshToken == null) {
      print("No refresh token found. Logging out...");
      await logout();
      return;
    }

    final url = Uri.parse('$baseUrl/auth/refreshTokens');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _accessToken = responseData['accessToken'];
        await _saveTokens(_accessToken!, responseData['refreshToken']);
        _isAuthenticated = true;
        print("Token refresh successful.");
      } else {
        print("Failed to refresh token. Logging out...");
        await logout();
      }
    } catch (error) {
      print("Refresh token error: $error");
      await logout();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    print("Attempting login for email: $email");
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _accessToken = responseData['accessToken'];
        String refreshToken = responseData['refreshToken'];
        _isAuthenticated = true;
        await _saveTokens(_accessToken!, refreshToken);
        notifyListeners();
        print("Login successful.");
        return {"isOk": true, "message": "Successful login."};
      } else {
        print("Login failed: ${responseData['error'] ?? 'Unknown error'}");
        return {
          "isOk": false,
          "error": responseData['error'] ?? 'Login failed'
        };
      }
    } catch (error) {
      print("Login error: $error");
      return {"isOk": false, "error": "Login failed. Please try again."};
    }
  }

  Future<void> logout() async {
    print("Logging out...");
    final refreshToken = await _secureStorage.read(key: 'refreshToken');

    // Clear tokens from local storage before calling logout API
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');

    _accessToken = null;
    _isAuthenticated = false;
    notifyListeners();

    if (refreshToken != null) {
      final url = Uri.parse('$baseUrl/auth/logout');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        );

        if (response.statusCode == 200) {
          print("Successfully logged out from server.");
        } else {
          print("Logout failed: ${response.body}");
        }
      } catch (error) {
        print("Logout error: $error");
      }
    } else {
      print("No refresh token found.");
    }

    print("User logged out successfully.");
  }
}
