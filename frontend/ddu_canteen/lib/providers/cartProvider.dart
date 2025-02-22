import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addItem(
      String name, int price, int quantity, String imageUrl, String itemId) {
    int index = _cartItems.indexWhere((item) => item['name'] == name);

    if (index != -1) {
      _cartItems[index]['quantity'] += quantity;
      _cartItems[index]['totalPrice'] =
          _cartItems[index]['price'] * _cartItems[index]['quantity'];
    } else {
      _cartItems.add({
        'name': name,
        'price': price,
        'quantity': quantity,
        'totalPrice': price * quantity,
        'imageUrl': imageUrl,
        'itemId': itemId
      });
    }

    notifyListeners();
  }

  void removeItem(String name) {
    _cartItems.removeWhere((item) => item['name'] == name);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void updateQuantity(int index, int change) {
    _cartItems[index]["quantity"] += change;
    if (_cartItems[index]["quantity"] <= 0) {
      _cartItems.removeAt(index);
    }
    notifyListeners();
  }

  double getTotalPrice() {
    return _cartItems.fold(
        0, (sum, item) => sum + (item["price"] * item["quantity"]));
  }
}
