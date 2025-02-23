import 'package:ddu_canteen/screens/orders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cartProvider.dart';
import '../providers/canteenProvider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.updateScreen});
  final Function(String, Widget, [bool]) updateScreen;
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void confirmCheckout(
      CartProvider cartProvider, CanteenProvider canteenProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Payment"),
        content: Text(
            "Are you sure you want to pay ₹${cartProvider.getTotalPrice().toStringAsFixed(2)}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              var success = await canteenProvider.createOrder(
                cartProvider.cartItems,
                cartProvider.getTotalPrice(),
              );

              cartProvider.clearCart();
              widget.updateScreen(
                "My orders",
                OrdersScreen(updateScreen: widget.updateScreen),
                false,
              );

              Future.microtask(() {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success != null
                        ? "Order placed successfully."
                        : "Failed to place order. Try again."),
                    backgroundColor:
                        success != null ? Colors.green : Colors.red,
                  ),
                );
              });
            },
            child: const Text("Yes, Pay"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final canteenProvider =
        Provider.of<CanteenProvider>(context, listen: false);

    return cartProvider.cartItems.isEmpty
        ? const Center(
            child: Text("Your cart is empty!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: cartProvider.cartItems.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    var item = cartProvider.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item["imageUrl"],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item["name"],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      "₹${(item["price"] * item["quantity"]).toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade700)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      cartProvider.updateQuantity(index, -1),
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                ),
                                Text("${item["quantity"]}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  onPressed: () =>
                                      cartProvider.updateQuantity(index, 1),
                                  icon: const Icon(Icons.add_circle,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        return Text(
                          "Total: ₹${cart.getTotalPrice().toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () =>
                          confirmCheckout(cartProvider, canteenProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Checkout",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
