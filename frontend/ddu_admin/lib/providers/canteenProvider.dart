import 'dart:io';

import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/canteenService.dart';

class CanteenProvider with ChangeNotifier {
  List<dynamic> _categories = [];
  bool isLoading = false;
  bool hasError = false;
  final CanteenService _canteenService = CanteenService();

  List<dynamic> get categories => _categories;

  Future<void> loadCategories() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      _categories = await _canteenService.fetchCategories();
      hasError = _categories.isEmpty;
    } catch (e) {
      hasError = true;
      print('Error loading categories: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> createCategory(String name, String desc) async {
    bool success = await _canteenService.createCategory(name, desc);
    if (success) {
      await loadCategories();
    }
    return success;
  }

  Future<bool> removeCategory(String categoryId) async {
    bool success = await _canteenService.removeCategory(categoryId);
    if (success) {
      await loadCategories();
    }
    return success;
  }

  Future<bool> addItem(
      String name, String categoryId, double price, String imagePath) async {
    bool success =
        await _canteenService.addItem(name, categoryId, price, imagePath);
    if (success) {
      await loadCategories();
    }
    return success;
  }

  Future<bool> removeItem(String itemId) async {
    bool success = await _canteenService.removeItem(itemId);
    if (success) {
      await loadCategories();
    }
    return success;
  }

  Future<bool> updateItem(String itemId, String name, String categoryId,
      double price, bool isAvailable, File? image) async {
    bool success = await _canteenService.updateItem(
        itemId, name, categoryId, price, isAvailable, image);
    if (success) {
      await loadCategories();
    }
    return success;
  }

  Future<bool> updateCategory(
      String categoryId, String? name, String? desc) async {
    bool success = await _canteenService.updateCategory(categoryId, name, desc);
    if (success) {
      await loadCategories();
    }
    return success;
  }

  List<dynamic> _employees = [];
  List<dynamic> get employees => _employees;

  Future<void> loadEmployees() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await _canteenService.fetchEmployees(); // API call
      _employees = (response as List).map((e) => Employee.fromJson(e)).toList();
      hasError = false;
    } catch (e) {
      hasError = true;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> registerUser(
      String name, String email, String password, String role,
      {String? canteenId}) async {
    isLoading = true;
    notifyListeners();

    try {
      bool success =
          await _canteenService.registerUser(name, email, password, role);
      if (success) await loadEmployees();
      return success;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(
      String managerId, String name, String email, String role) async {
    isLoading = true;
    notifyListeners();

    try {
      bool success =
          await _canteenService.updateUser(managerId, name, email, role);
      if (success) await loadEmployees();
      return success;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeUser(String managerId) async {
    isLoading = true;
    notifyListeners();

    try {
      bool success = await _canteenService.deleteUser(managerId);
      if (success) await loadEmployees();
      return success;
    } catch (e) {
      print('Error removing user: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> _pendingOrders = [];
  List<dynamic> get pendingOrders => _pendingOrders;

  Future<void> loadPendingOrders() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final response = await _canteenService.getPendingItems();
      _pendingOrders = response ?? []; // Store orders instead of flat item list
      if (response == null) hasError = _pendingOrders.isEmpty;
    } catch (e) {
      hasError = true;
      print('Error loading pending orders: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  List<dynamic> _cookedOrders = [];
  List<dynamic> get cookedOrders => _cookedOrders;

  Future<void> loadCookedOrders() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final response = await _canteenService.getCookedItems();
      _cookedOrders = response ?? [];
      if (response == null) hasError = _cookedOrders.isEmpty;
    } catch (e) {
      hasError = true;
      print('Error loading pending orders: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateItemStatus(
      String orderId, String itemId, String status) async {
    isLoading = true;
    notifyListeners();

    try {
      final response =
          await _canteenService.updateItemStatus(orderId, itemId, status);
      if (response) {
        print("Item status updated: ");
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      print(e);
      notifyListeners();
      return false;
    }
  }

  String? _selectedOrder;
  String? get selectedOrder => _selectedOrder;

  void setSelectedOrder(String orderId) {
    _selectedOrder = orderId;
    notifyListeners();
  }
}
