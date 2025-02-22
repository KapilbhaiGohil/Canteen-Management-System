import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../components/category.dart';
import '../providers/canteenProvider.dart';
import 'cart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeScreen = "Home";
  late Widget _selectedScreen;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  void _updateScreen(String screenName, Widget screenWidget) {
    setState(() {
      _activeScreen = screenName;
      _selectedScreen = screenWidget;
      _isSearching = false;
      _searchController.clear();
    });
    Navigator.pop(context);
  }

  void updateScreen(String screenName, Widget screenWidget,
      [bool shouldPop = true]) {
    setState(() {
      _activeScreen = screenName;
      _selectedScreen = screenWidget;
    });
    if (shouldPop) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedScreen = HomeContent(updateScreen: updateScreen);

    Future.microtask(() async {
      final canteenProvider =
          Provider.of<CanteenProvider>(context, listen: false);
      await canteenProvider.loadCategories();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchController.clear();
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Exit App"),
          content: const Text("Are you sure you want to leave?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                if (Platform.isAndroid) {
                  SystemNavigator.pop();
                } else {
                  exit(0);
                }
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search items...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                onChanged: (value) => print("Searching for: $value"),
              )
            : Text(
                _activeScreen,
                style: const TextStyle(color: Colors.white),
              ),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          if (_activeScreen == "Home") ...[
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search,
                  color: Colors.white),
              onPressed: _toggleSearch,
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {
                setState(() {
                  _activeScreen = "Cart";
                  _selectedScreen = CartScreen();
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            ),
          ],
          if (_activeScreen == 'Cart') ...[
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                setState(() {
                  _activeScreen = "Home";
                  _selectedScreen = HomeContent(
                    updateScreen: updateScreen,
                  );
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            ),
          ],
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: const Text(
                'Actions',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _buildDrawerItem(
                Icons.home,
                "Home",
                HomeContent(
                  updateScreen: updateScreen,
                )),
            _buildDrawerItem(Icons.shopping_bag, "Cart", const CartScreen()),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Exit",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: _showExitDialog,
            ),
          ],
        ),
      ),
      body: _selectedScreen,
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget screen) {
    bool isSelected = _activeScreen == title;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blueAccent : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blueAccent : Colors.black,
        ),
      ),
      onTap: () => _updateScreen(title, screen),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key, required this.updateScreen});
  final Function(String, Widget, [bool]) updateScreen;
  @override
  Widget build(BuildContext context) {
    return Consumer<CanteenProvider>(
      builder: (context, canteenProvider, child) {
        if (canteenProvider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.blueAccent,
          ));
        }

        if (canteenProvider.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("No categories available.",
                    style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: canteenProvider.categories.map((category) {
              return Column(
                children: [
                  Category(
                    categoryId: category['_id'],
                    desc: category['desc'],
                    updateScreen: updateScreen,
                    categoryName: category['name'],
                    items: category['items'] ?? [],
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
