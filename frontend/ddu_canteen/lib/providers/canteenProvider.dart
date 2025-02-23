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

  CanteenProvider() {
    connectToOrderUpdates();
  }

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

  void connectToOrderUpdates() {
    if (_channel != null) {
      debugPrint("WebSocket already connected.");
      return;
    }

    final String canteenId = AppConstants.canteenId;
    debugPrint("Connecting to WebSocket: ${AppConstants.socketUri}");

    try {
      _channel = IOWebSocketChannel.connect(AppConstants.socketUri);

      _channel!.sink.add(jsonEncode({
        "event": "watchOrders",
        "canteenId": canteenId,
      }));

      _channel!.stream.listen((data) {
        debugPrint("WebSocket data received: $data");

        try {
          final Map<String, dynamic> order = jsonDecode(data);
          _orders.add(order);
          notifyListeners();
        } catch (e) {
          debugPrint("Error parsing WebSocket data: $e");
        }
      }, onError: (error) {
        debugPrint("WebSocket Error: $error");
        reconnect();
      }, onDone: () {
        debugPrint("WebSocket connection closed, reconnecting...");
        reconnect();
      });
    } catch (e) {
      debugPrint("WebSocket connection failed: $e");
      reconnect();
    }
  }

  void reconnect() {
    Future.delayed(Duration(seconds: 3), () {
      debugPrint("Reconnecting WebSocket...");
      connectToOrderUpdates();
    });
  }

  @override
  void dispose() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
    super.dispose();
  }
}
