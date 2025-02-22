import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class Category extends StatefulWidget {
  final String categoryName;
  final List<dynamic> items;
  final Function(String, Widget, [bool]) updateScreen;
  final String desc;
  final String categoryId;
  const Category(
      {super.key,
      required this.categoryName,
      required this.items,
      required this.updateScreen,
      required this.desc,
      required this.categoryId});

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
              color: Colors.blueAccent,
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (widget.items.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "No items added for this category.",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 180,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: false,
              child: ListView.separated(
                controller: _scrollController,
                itemCount: widget.items.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return CustomItemTile(
                    itemName: item['name'],
                    itemImage: item['imageUrl'],
                    price: item['price'],
                    itemId: item['_id'],
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 10),
              ),
            ),
          ),
      ],
    );
  }
}
