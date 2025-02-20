import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class Category extends StatefulWidget {
  final String categoryName;
  const Category({super.key, required this.categoryName});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final ScrollController _scrollController = ScrollController(); // Declare controller

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 193, 224, 239),
              border:
              Border(left: BorderSide(color: Colors.blueAccent, width: 4))),
          child: Text(
            "Category",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 180,
          child: Scrollbar(
            controller: _scrollController, // Use the same controller
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView.separated(
              controller: _scrollController, // Assign controller here
              itemCount: 7,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return CustomItemTile();
              },
              separatorBuilder: (context, index) => const SizedBox(
                width: 10,
              ),
            ),
          ),
        )
      ],
    );
  }
}
