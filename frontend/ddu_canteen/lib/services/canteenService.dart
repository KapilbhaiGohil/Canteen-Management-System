import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constant.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CanteenService {
  final String baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  CanteenService({this.baseUrl = AppConstants.baseUrl});

  Future<List<dynamic>> fetchCategories() async {
    try {
      final String canteenId = AppConstants.canteenId;

      final response = await http.get(
        Uri.parse('$baseUrl/item/retriveItemsByCategory?canteenId=$canteenId'),
        headers: {
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

  Future<Map<String, dynamic>?> createOrder(
      List<Map<String, dynamic>> items, double totalAmount) async {
    try {
      final deviceId = await _secureStorage.read(key: 'deviceId');
      if (deviceId == null) {
        print("deviceId not found in storage.");
        return null;
      }
      final response = await http.post(
        Uri.parse('$baseUrl/order/createOrder'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "deviceId": deviceId,
          "items": items
              .map((item) =>
                  {"itemId": item['itemId'], "quantity": item['quantity']})
              .toList(),
          "totalAmount": totalAmount,
          "canteenId": AppConstants.canteenId
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print("Order created successfully: ${response.body}");
        return data["order"];
      } else {
        print("Failed to create order: ${response.body}");
        return null;
      }
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  Future<List<dynamic>> fetchOrders() async {
    try {
      final deviceId = await _secureStorage.read(key: 'deviceId');
      if (deviceId == null) {
        print("deviceId not found in storage.");
        return [];
      }

      final response = await http.get(
        Uri.parse(
            '$baseUrl/order/getOrders?deviceId=$deviceId&canteenId=${AppConstants.canteenId}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Orders fetched successfully: ${response.body}");
        return data["orders"];
      } else {
        print("Failed to fetch orders: ${response.body}");
        return [];
      }
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }
}
