import 'package:flutter/material.dart';
import '../components/category.dart';
import 'addCategory.dart';
import 'addItem.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              tileColor: Colors.blueAccent,
              leading: const Icon(Icons.category, color: Colors.white),
              title: const Text("Add Category",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCategoryScreen()),
                );
              },
            ),
            ListTile(
              tileColor: Colors.blueAccent,
              leading: const Icon(Icons.fastfood, color: Colors.white),
              title:
                  const Text("Add Item", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItemScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Category(categoryName: "category"),
            const SizedBox(
              height: 8,
            ),
            Category(categoryName: "category"),
            const SizedBox(
              height: 8,
            ),
            Category(categoryName: "category"),
            const SizedBox(
              height: 8,
            ),
            Category(categoryName: "category"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        backgroundColor: Colors.blueAccent,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
