import 'package:ddu_canteen/constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cartProvider.dart';

class CustomItemTile extends StatelessWidget {
  final String itemName;
  final String itemImage;
  final int price;
  final String itemId;
  const CustomItemTile(
      {super.key,
      required this.itemName,
      required this.itemImage,
      required this.price,
      required this.itemId});

  void showItemModal(
      BuildContext context, String itemName, int itemPrice, String imageUrl) {
    int quantity = 1;
    int totalPrice = itemPrice;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(imageUrl,
                        width: 150, height: 150, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 10),
                  Text(itemName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red, size: 30),
                            onPressed: () {
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                  totalPrice = itemPrice * quantity;
                                });
                              }
                            },
                          ),
                          Text(quantity.toString(),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.green, size: 30),
                            onPressed: () {
                              setState(() {
                                quantity++;
                                totalPrice = itemPrice * quantity;
                              });
                            },
                          ),
                        ],
                      ),
                      Text("${totalPrice.toStringAsFixed(2)} ₹",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(
                          itemName, itemPrice, quantity, imageUrl, itemId);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Added $quantity $itemName(s) to Cart successfully!"),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      Navigator.pop(context); // Close modal
                    },
                    child: const Text("Add to Cart",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showItemModal(context, itemName, price, itemImage),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                itemImage.isNotEmpty ? itemImage : AppConstants.defaultImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.network(
                  AppConstants.defaultImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  itemName,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w400),
                ),
                Text(
                  "$price ₹",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
