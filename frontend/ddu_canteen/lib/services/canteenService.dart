import 'dart:convert';
import 'dart:io';
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
      final String canteenId = AppConstants.canteenId;

      final response = await http.get(
        Uri.parse('$baseUrl/item/retriveItemsByCategory?canteenId=$canteenId'),
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
}
