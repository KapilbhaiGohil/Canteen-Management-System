import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CanteenService {
  final String baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  CanteenService({this.baseUrl = AppConstants.baseUrl});

  Future<List<dynamic>> fetchCategories() async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');

      final response = await http.get(
        Uri.parse('$baseUrl/item/retriveItemsByCategory'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to fetch canteens: ${response.body}");
        return [];
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
  Future<bool> createCategory(String name, String canteenId, String desc) async {
  try {
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.post(
      Uri.parse('$baseUrl/item/createCategory'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'canteenId': canteenId,
        'desc': desc,
      }),
    );

    return response.statusCode == 201;
  } catch (e) {
    print('Error creating category: $e');
    return false;
  }
}

Future<bool> removeCategory(String categoryId) async {
  try {
    final accessToken = await _secureStorage.read(key: 'accessToken');

    final response = await http.post(
      Uri.parse('$baseUrl/item/removeCategory'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'categoryId': categoryId,
      }),
    );

    return response.statusCode == 200;
  } catch (e) {
    print('Error removing category: $e');
    return false;
  }
}
}
