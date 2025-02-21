import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ddu_canteen/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String baseUrl = AppConstants.baseUrl;
  bool _isServerDown = false;
  bool _isLoading = true;

  bool get isServerDown => _isServerDown;
  bool get isLoading => _isLoading;

  Future<void> tryAutoLogin() async {
    print("Attempting auto-login...");
    _isLoading = true;
    _isServerDown = false;
    notifyListeners();

    String? deviceId = await _secureStorage.read(key: 'deviceId');

    if (deviceId == null) {
      deviceId = await _getDeviceId();
      await _secureStorage.write(key: 'deviceId', value: deviceId);
      print("Device ID stored: $deviceId");
    } else {
      print("Device ID found in storage: $deviceId");
    }

    final url = Uri.parse('$baseUrl/auth/userLogin');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'deviceId': deviceId}),
      );

      if (response.statusCode == 200) {
        print("Server response: OK");
      } else {
        print("Unexpected response: ${response.statusCode}");
        _isServerDown = true;
      }
    } catch (error) {
      print("Server connection error: $error");
      _isServerDown = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id ?? 'UnknownAndroidDevice';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'UnknowniOSDevice';
      }
    } catch (e) {
      print("Error getting device ID: $e");
    }
    return 'UnknownDevice';
  }
}
