import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CanteenService {
  final String baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  CanteenService({this.baseUrl = AppConstants.baseUrl});

  Future<Map<String, dynamic>> addCanteen({
    required String name,
    required String collegeName,
    required String district,
    required String state,
    required String pinCode,
    File? imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/canteen/create');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..headers['Content-Type'] = 'multipart/form-data'
      ..fields['name'] = name
      ..fields['collegeName'] = collegeName
      ..fields['district'] = district
      ..fields['state'] = state
      ..fields['pincode'] = pinCode;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"isOk": true, "message": "Canteen added successfully.", "canteen": responseData['canteen']};
      } else {
        return {"isOk": false, "error": responseData['error'] ?? "Failed to add canteen."};
      }
    } catch (e) {
      print("Error adding canteen: $e");
      return {"isOk": false, "error": "An error occurred while adding the canteen."};
    }
  }

  Future<List<dynamic>> getCanteens() async {
    final url = Uri.parse('$baseUrl/canteen/get');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to fetch canteens: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching canteens: $e");
      return [];
    }
  }
}
