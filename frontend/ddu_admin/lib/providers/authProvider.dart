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
  Map<String, dynamic>? _canteen;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get accessToken => _accessToken;
  Map<String, dynamic>? get canteen => _canteen;

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    try {
      await _secureStorage.write(key: 'accessToken', value: accessToken);
      await _secureStorage.write(key: 'refreshToken', value: refreshToken);
      print("Tokens saved successfully.");
    } catch (error) {
      print("Error saving tokens: $error");
    }
  }

  Future<void> _saveCanteen(Map<String, dynamic>? canteenData) async {
    try {
      if (canteenData != null) {
        await _secureStorage.write(
            key: 'canteen', value: jsonEncode(canteenData));
        print("Canteen details saved successfully.");
      }
    } catch (error) {
      print("Error saving canteen details: $error");
    }
  }

  Future<void> _loadCanteen() async {
    try {
      String? canteenData = await _secureStorage.read(key: 'canteen');
      if (canteenData != null) {
        _canteen = jsonDecode(canteenData);
        print("Canteen loaded successfully.");
      }
    } catch (error) {
      print("Error loading canteen details: $error");
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

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          if (!responseData.containsKey('canteen') ||
              responseData['canteen'] == null) {
            print("No canteen associated with this user. Logging out...");
            await logout();
            return;
          }

          print("Access token is valid.");
          _isAuthenticated = true;
          _canteen = responseData['canteen'];
          await _saveCanteen(_canteen);
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

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (!responseData.containsKey('canteen') ||
            responseData['canteen'] == null) {
          print("No canteen associated with this user. Logging out...");
          await logout();
          return;
        }

        _accessToken = responseData['accessToken'];
        await _saveTokens(_accessToken!, responseData['refreshToken']);
        _canteen = responseData['canteen'];
        await _saveCanteen(_canteen);
        _isAuthenticated = true;

        print("Token refresh successful.");
        notifyListeners();
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
        if (!responseData.containsKey('canteen') ||
            responseData['canteen'] == null) {
          print("No canteen associated with this user. Logging out...");
          await logout();
          return {"isOk": false, "error": "No canteen found for this user."};
        }

        _accessToken = responseData['accessToken'];
        String refreshToken = responseData['refreshToken'];
        _isAuthenticated = true;

        await _saveTokens(_accessToken!, refreshToken);
        _canteen = responseData['canteen'];
        await _saveCanteen(_canteen);

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

    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
    await _secureStorage.delete(key: 'canteen');

    _accessToken = null;
    _canteen = null;
    _isAuthenticated = false;
    _isLoading = false;
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
