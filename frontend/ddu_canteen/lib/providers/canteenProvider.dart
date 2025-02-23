import 'dart:io';

import 'package:flutter/material.dart';
import '../services/canteenService.dart';

class CanteenProvider with ChangeNotifier {
  List<dynamic> _categories = [];
  bool isLoading = false;
  bool hasError = false;
  List<dynamic> _orders = [];
  List<dynamic> get orders => _orders;
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

  Future<Map<String, dynamic>?> createOrder(
      List<Map<String, dynamic>> items, double totalAmount) {
    return _canteenService.createOrder(items, totalAmount);
  }

  Future<void> loadOrders() async {
    isLoading = true;
    notifyListeners();

    try {
      _orders = await _canteenService.fetchOrders();
    } catch (e) {
      print('Error loading orders: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
