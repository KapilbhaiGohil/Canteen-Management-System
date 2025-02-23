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
      final canteenData = await _secureStorage.read(key: "canteen");

      if (canteenData == null) {
        print("No canteen data found. Logging out user.");
        return [];
      }

      final canteen = jsonDecode(canteenData);
      final String? canteenId = canteen['_id'];

      if (canteenId == null) {
        print("Canteen ID is missing. Logging out user.");
        return [];
      }

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

  Future<bool> createCategory(String name, String desc) async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');
      final canteenData = await _secureStorage.read(key: "canteen");

      if (canteenData == null) {
        print("No canteen data found. Logging out user.");
        return false;
      }

      final canteen = jsonDecode(canteenData);
      final String? canteenId = canteen['_id'];

      if (canteenId == null) {
        print("Canteen ID is missing. Logging out user.");
        return false;
      }

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

      if (response.statusCode == 201) {
        print("Category created successfully.");
        return true;
      } else {
        print("Failed to create category: ${response.body}");
        return false;
      }
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

  Future<bool> addItem(
      String name, String categoryId, double price, String imagePath) async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');
      final canteenData = await _secureStorage.read(key: "canteen");

      if (canteenData == null) {
        print("No canteen data found. Logging out user.");
        return false;
      }

      final canteen = jsonDecode(canteenData);
      final String? canteenId = canteen['_id'];

      if (canteenId == null) {
        print("Canteen ID is missing. Logging out user.");
        return false;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/item/createItem'),
      );

      request.headers['Authorization'] = 'Bearer $accessToken';
      request.fields['name'] = name;
      request.fields['categoryId'] = categoryId;
      request.fields['price'] = price.toString();
      request.fields['canteenId'] = canteenId;

      if (imagePath.isNotEmpty) {
        request.files
            .add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        print("Item added successfully.");
        return true;
      } else {
        print("Failed to add item: ${await response.stream.bytesToString()}");
        return false;
      }
    } catch (e) {
      print('Error adding item: $e');
      return false;
    }
  }

  Future<bool> removeItem(String itemId) async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');

      final response = await http.post(
        Uri.parse('$baseUrl/item/removeItem'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'itemId': itemId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error removing item: $e');
      return false;
    }
  }

  Future<bool> updateItem(String itemId, String name, String categoryId,
      double price, bool isAvailable, File? image) async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/item/updateItem'),
      );

      request.headers['Authorization'] = 'Bearer $accessToken';
      request.fields['itemId'] = itemId;
      request.fields['name'] = name;
      request.fields['categoryId'] = categoryId;
      request.fields['price'] = price.toString();
      request.fields['isAvailable'] = isAvailable.toString();

      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        print("Item updated successfully.");
        return true;
      } else {
        print(
            "Failed to update item: ${await response.stream.bytesToString()}");
        return false;
      }
    } catch (e) {
      print('Error updating item: $e');
      return false;
    }
  }

  Future<bool> updateCategory(
      String categoryId, String? name, String? desc) async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');

      final response = await http.post(
        Uri.parse('$baseUrl/item/updateCategory'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body:
            json.encode({'categoryId': categoryId, 'name': name, 'desc': desc}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchEmployees() async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');
      final canteenData = await _secureStorage.read(key: "canteen");

      if (canteenData == null) {
        print("No canteen data found. Logging out user.");
        return [];
      }

      final canteen = jsonDecode(canteenData);
      final String? canteenId = canteen['_id'];
      final response = await http.get(
        Uri.parse('$baseUrl/auth/employees?canteenId=$canteenId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Failed to fetch employees: ${response.body}");
        return [];
      }
    } catch (e) {
      print('Error fetching employees: $e');
      return [];
    }
  }

  Future<bool> registerUser(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');
      final canteenData = await _secureStorage.read(key: "canteen");

      if (canteenData == null) {
        print("No canteen data found. Logging out user.");
        return false;
      }

      final canteen = jsonDecode(canteenData);
      final String? canteenId = canteen['_id'];
      final response = await http.post(
        Uri.parse('$baseUrl/auth/registerUser'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'canteenId': canteenId,
        }),
      );

      if (response.statusCode == 201) {
        print("User registered successfully.");
        return true;
      } else {
        print("Failed to register user: ${response.body}");
        return false;
      }
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  Future<bool> updateUser(
      String managerId, String name, String email, String role) async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');
      final canteenData = await _secureStorage.read(key: "canteen");

      if (canteenData == null) {
        print("No canteen data found. Logging out user.");
        return false;
      }

      final canteen = jsonDecode(canteenData);
      final String? canteenId = canteen['_id'];
      final response = await http.put(
        Uri.parse('$baseUrl/auth/updateUser'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'managerId': managerId,
          'name': name,
          'email': email,
          'role': role,
          'canteenId': canteenId,
        }),
      );

      if (response.statusCode == 200) {
        print("User updated successfully.");
        return true;
      } else {
        print("Failed to update user: ${response.body}");
        return false;
      }
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String managerId) async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');

      final response = await http.delete(
        Uri.parse('$baseUrl/auth/deleteUser'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'managerId': managerId}),
      );

      if (response.statusCode == 200) {
        print("User deleted successfully.");
        return true;
      } else {
        print("Failed to delete user: ${response.body}");
        return false;
      }
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getPendingItems() async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');

      final response = await http.get(
        Uri.parse('$baseUrl/order/getPendingItems'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Pending Orders: $data");
        return List<Map<String, dynamic>>.from(data['orders']); // Adjusted key
      } else {
        print('Failed to fetch pending orders: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching pending orders: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getCookedItems() async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');

      final response = await http.get(
        Uri.parse('$baseUrl/order/getCookedItems'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Pending Orders: $data");
        return List<Map<String, dynamic>>.from(data['orders']);
      } else {
        print('Failed to fetch pending orders: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching pending orders: $e');
      return null;
    }
  }

  Future<bool> updateItemStatus(
      String orderId, String itemId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/order/updateItemStatus'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"orderId": orderId, "itemId": itemId, "status": status}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(jsonDecode(response.body));
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
