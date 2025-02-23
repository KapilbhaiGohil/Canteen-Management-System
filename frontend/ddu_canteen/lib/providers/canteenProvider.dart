import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import '../services/canteenService.dart';
import '../constant.dart';

class CanteenProvider with ChangeNotifier {
  List<dynamic> _categories = [];
  List<dynamic> _orders = [];
  IOWebSocketChannel? _channel;
  bool isLoadingCategories = false;
  bool isLoadingOrders = false;
  bool hasError = false;
  final CanteenService _canteenService = CanteenService();

  List<dynamic> get categories => _categories;
  List<dynamic> get orders => _orders;


  Future<void> loadCategories() async {
    isLoadingCategories = true;
    hasError = false;
    notifyListeners();

    try {
      _categories = await _canteenService.fetchCategories();
      hasError = _categories.isEmpty;
    } catch (e) {
      hasError = true;
      debugPrint('Error loading categories: $e');
    }

    isLoadingCategories = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> createOrder(
      List<Map<String, dynamic>> items, double totalAmount) {
    return _canteenService.createOrder(items, totalAmount);
  }

  Future<void> loadOrders() async {
    isLoadingOrders = true;
    notifyListeners();

    try {
      _orders = await _canteenService.fetchOrders();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }

    isLoadingOrders = false;
    notifyListeners();
  }
}
