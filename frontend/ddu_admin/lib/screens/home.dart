import 'package:flutter/material.dart';
import '../components/category.dart';
import 'addCategory.dart';
import 'addItem.dart';
import 'empolyee.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeScreen = "Home";
  Widget _selectedScreen = const HomeContent();
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

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchController.clear();
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/login");
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
          decoration: InputDecoration(
            hintText: "Search items...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          onChanged: (value) {
            // Handle search logic (e.g., filter items)
            print("Searching for: $value");
          },
        )
            : Text(
          _activeScreen,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: _activeScreen == "Home"
            ? [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: _toggleSearch,
          ),
        ]
            : null,
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
            _buildDrawerItem(Icons.home, "Home", const HomeContent()),
            _buildDrawerItem(Icons.category, "Add Category", const AddCategoryScreen()),
            _buildDrawerItem(Icons.fastfood, "Add Item", const AddItemScreen()),
            _buildDrawerItem(Icons.people, "Employees", const EmployeesScreen()),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Log out",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: _showLogoutDialog,
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
      onTap: () {
        _updateScreen(title, screen);
      },
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Category(categoryName: "category"),
          const SizedBox(height: 8),
          Category(categoryName: "category"),
          const SizedBox(height: 8),
          Category(categoryName: "category"),
          const SizedBox(height: 8),
          Category(categoryName: "category"),
        ],
      ),
    );
  }
}
