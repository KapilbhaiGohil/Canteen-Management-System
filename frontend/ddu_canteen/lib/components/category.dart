import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class Category extends StatefulWidget {
  final String categoryName;
  const Category({super.key, required this.categoryName});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> items = [
      {"name": "Burger", "price": 5.99},
      {"name": "Pizza", "price": 8.99},
      {"name": "Pasta", "price": 7.49},
      {"name": "Sandwich", "price": 4.99},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 193, 224, 239),
            border:
                Border(left: BorderSide(color: Colors.blueAccent, width: 4)),
          ),
          child: Text(
            widget.categoryName,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: items.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return CustomItemTile(
                itemName: items[index]["name"],
                itemPrice: items[index]["price"],
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 10),
          ),
        ),
      ],
    );
  }
}
