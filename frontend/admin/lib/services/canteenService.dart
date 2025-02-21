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

  Future<Map<String, dynamic>> deleteCanteen(String canteenId) async {
    final url = Uri.parse('$baseUrl/canteen/delete');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"canteenId": canteenId}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"isOk": true, "message": "Canteen deleted successfully."};
      } else {
        return {"isOk": false, "error": responseData['error'] ?? "Failed to delete canteen."};
      }
    } catch (e) {
      print("Error deleting canteen: $e");
      return {"isOk": false, "error": "An error occurred while deleting the canteen."};
    }
  }
  Future<Map<String, dynamic>> updateCanteen({
    required String canteenId,
    String? name,
    String? collegeName,
    String? district,
    String? state,
    String? pinCode,
    File? imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/canteen/update');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    var request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..headers['Content-Type'] = 'multipart/form-data'
      ..fields['canteenId'] = canteenId;

    if (name != null) request.fields['name'] = name;
    if (collegeName != null) request.fields['collegeName'] = collegeName;
    if (district != null) request.fields['district'] = district;
    if (state != null) request.fields['state'] = state;
    if (pinCode != null) request.fields['pincode'] = pinCode;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"isOk": true, "message": "Canteen updated successfully.", "canteen": responseData['canteen']};
      } else {
        return {"isOk": false, "error": responseData['error'] ?? "Failed to update canteen."};
      }
    } catch (e) {
      print("Error updating canteen: $e");
      return {"isOk": false, "error": "An error occurred while updating the canteen."};
    }
  }
  Future<List<dynamic>> getManagers() async {
    final url = Uri.parse('$baseUrl/auth/managers');
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
        print("Failed to fetch managers: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching managers: $e");
      return [];
    }
  }
  Future<Map<String, dynamic>> registerManager({
    required String name,
    required String email,
    required String password,
    required String role,
    required String canteenId,
  }) async {
    final url = Uri.parse('$baseUrl/auth/registerUser');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role,
          "canteenId": canteenId,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"isOk": true, "message": "Manager registered successfully."};
      } else {
        return {"isOk": false, "error": responseData['error'] ?? "Failed to register manager."};
      }
    } catch (e) {
      print("Error registering manager: $e");
      return {"isOk": false, "error": "An error occurred while registering the manager."};
    }
  }
  Future<Map<String, dynamic>> updateManager({
    required String managerId,
    required String name,
    required String email,
    required String role,
    required String canteenId,
  }) async {
    final url = Uri.parse('$baseUrl/auth/updateUser');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "managerId": managerId,
          "name": name,
          "email": email,
          "role": role,
          "canteenId": canteenId,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"isOk": true, "message": "Manager updated successfully."};
      } else {
        return {"isOk": false, "error": responseData['error'] ?? "Failed to update manager."};
      }
    } catch (e) {
      print("Error updating manager: $e");
      return {"isOk": false, "error": "An error occurred while updating the manager."};
    }
  }
  Future<Map<String, dynamic>> deleteManager(String managerId) async {
    final url = Uri.parse('$baseUrl/auth/deleteUser');
    final accessToken = await _secureStorage.read(key: 'accessToken');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"managerId": managerId}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"isOk": true, "message": "Manager deleted successfully."};
      } else {
        return {"isOk": false, "error": responseData['error'] ?? "Failed to delete manager."};
      }
    } catch (e) {
      print("Error deleting manager: $e");
      return {"isOk": false, "error": "An error occurred while deleting the manager."};
    }
  }


}
