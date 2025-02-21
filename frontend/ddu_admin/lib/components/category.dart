import 'package:ddu_admin/screens/addCategory.dart';
import 'package:ddu_admin/screens/addItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/canteenProvider.dart';
import '../widgets/widgets.dart';

class Category extends StatefulWidget {
  final String categoryName;
  final List<dynamic> items;
  final VoidCallback onDeleteCategory;
  final Function(String, Widget, [bool]) updateScreen;
  final String desc;
  final String categoryId;
  const Category({
    super.key,
    required this.categoryName,
    required this.items,
    required this.updateScreen,
    required this.onDeleteCategory,
    required this.desc,
    required this.categoryId,
  });

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

  void _deleteItem(String itemId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final canteenProvider =
                    Provider.of<CanteenProvider>(context, listen: false);
                bool success = await canteenProvider.removeItem(itemId);
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Item deleted successfully!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to delete item.")),
                  );
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _updateItem(Map<String, dynamic> item) {
    widget.updateScreen(
        "Add Item",
        AddItemScreen(
          updateScreen: widget.updateScreen,
          itemId: item['_id'],
          initialName: item['name'],
          initialPrice: item['price'].toString(),
          initialImage: item['imageUrl'],
        ),
        false);
  }

  void _showCategoryOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blueAccent),
              title: const Text("Update Category"),
              onTap: () {
                Navigator.pop(context);
                widget.updateScreen(
                  "Update Category",
                  AddCategoryScreen(
                    updateScreen: widget.updateScreen,
                    categoryName: widget.categoryName,
                    isUpdate: true,
                    categoryDesc: widget.desc,
                    categoryId: widget.categoryId,
                  ),
                  false,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete Category"),
              onTap: () {
                Navigator.pop(context);
                widget.onDeleteCategory();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.black),
              title: const Text("Cancel"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showCategoryOptions, // Show options on long press
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Title
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

          // If no items are available
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
                      updateScreen: widget.updateScreen,
                      itemName: item['name'],
                      itemImage: item['imageUrl'],
                      price: item['price'].toString(),
                      onUpdate: () => _updateItem(item),
                      onDelete: () => _deleteItem(item['_id']),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
