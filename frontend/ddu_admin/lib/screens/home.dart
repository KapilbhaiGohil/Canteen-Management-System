import 'package:ddu_admin/providers/authProvider.dart';
import 'package:ddu_admin/screens/itemScreen.dart';
import 'package:ddu_admin/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/category.dart';
import '../providers/canteenProvider.dart';
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
  late Widget _selectedScreen;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
    _selectedScreen = HomeContent(searchQuery: "", updateScreen: updateScreen);

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
      _updateSearchQuery("");
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _selectedScreen =
          HomeContent(updateScreen: updateScreen, searchQuery: query);
    });
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
                onChanged: _updateSearchQuery)
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
                  icon: Icon(_isSearching ? Icons.close : Icons.search,
                      color: Colors.white),
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
            buildDrawerItem(
                Icons.home,
                "Home",
                updateScreen,
                HomeContent(
                  searchQuery: "",
                  updateScreen: updateScreen,
                ),
                _activeScreen),
            buildDrawerItem(
                Icons.category,
                "Add Category",
                updateScreen,
                AddCategoryScreen(
                  updateScreen: updateScreen,
                ),
                _activeScreen),
            buildDrawerItem(
                Icons.fastfood,
                "Add Item",
                updateScreen,
                AddItemScreen(
                  updateScreen: updateScreen,
                ),
                _activeScreen),
            buildDrawerItem(Icons.people, "Employees", updateScreen,
                EmployeesScreen(), _activeScreen),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Log out",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () => {showLogoutDialog(context)},
            ),
          ],
        ),
      ),
      body: _selectedScreen,
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent(
      {super.key, required this.updateScreen, required this.searchQuery});
  final Function(String, Widget, [bool]) updateScreen;
  final String searchQuery;

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
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    updateScreen(
                        "Add Category",
                        AddCategoryScreen(
                          updateScreen: updateScreen,
                        ),
                        false);
                  },
                  child: const Text("Create New Category"),
                ),
              ],
            ),
          );
        }

        void _deleteCategory(String categoryId) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Delete Category"),
                content: const Text(
                    "Are you sure you want to delete this category?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      final canteenProvider =
                          Provider.of<CanteenProvider>(context, listen: false);
                      bool success =
                          await canteenProvider.removeCategory(categoryId);
                      Navigator.pop(context);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Category deleted successfully!")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Failed to delete category.")),
                        );
                      }
                    },
                    child: const Text("Delete",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          );
        }

        final filteredCategories = canteenProvider.categories
            .map((category) {
              final filteredItems = (category['items'] as List)
                  .where((item) => item['name']
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                  .toList();
              return {
                '_id': category['_id'],
                'name': category['name'],
                'desc': category['desc'],
                'items': filteredItems,
              };
            })
            .where((category) => category['items'] != null)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: filteredCategories.map((category) {
              return Column(
                children: [
                  Category(
                    categoryId: category['_id'],
                    desc: category['desc'],
                    updateScreen: updateScreen,
                    categoryName: category['name'],
                    items: category['items'],
                    onDeleteCategory: () => _deleteCategory(category['_id']),
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
