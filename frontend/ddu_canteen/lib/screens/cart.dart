import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pay/pay.dart';
import '../constant.dart';
import '../providers/cartProvider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool showPayButton = false;

  void onGooglePayResult(Map<String, dynamic> paymentResult) {
    print("Payment Success: $paymentResult");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment Successful via Google Pay!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showPaymentDialog(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
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
            onPressed: () {
              setState(() => showPayButton = true);
              Navigator.pop(context);
            },
            child: const Text("Pay"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final totalPrice = cartProvider.getTotalPrice().toStringAsFixed(2);

    final googlePayButton = FutureBuilder<PaymentConfiguration>(
      future: PaymentConfiguration.fromAsset("gpay.json"),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent));
        }
        return GooglePayButton(
          paymentConfiguration: snapshot.data!,
          paymentItems: [
            PaymentItem(
                label: "Total",
                amount: totalPrice,
                status: PaymentItemStatus.final_price),
          ],
          theme: GooglePayButtonTheme.dark,
          type: GooglePayButtonType.pay,
          width: double.infinity,
          height: 50,
          onPaymentResult: onGooglePayResult,
        );
      },
    );

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
                                item["imageUrl"].isNotEmpty
                                    ? item["imageUrl"]
                                    : AppConstants.defaultImage,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.network(
                                  AppConstants.defaultImage,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
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
                                  Text("₹${item["price"].toStringAsFixed(2)}",
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
                    Text("Total: ₹$totalPrice",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    showPayButton
                        ? googlePayButton
                        : ElevatedButton(
                            onPressed: () => showPaymentDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text("Checkout",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                  ],
                ),
              ),
            ],
          );
  }
}
