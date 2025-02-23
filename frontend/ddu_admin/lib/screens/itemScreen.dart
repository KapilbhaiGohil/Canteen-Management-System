import 'package:ddu_admin/screens/itemContent.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/canteenProvider.dart';
import '../widgets/widgets.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeScreen = "Items";
  late Widget _selectedScreen;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedScreen = const ItemContent(); // Initialize here
    Future.microtask(() {
      final provider = Provider.of<CanteenProvider>(context, listen: false);
      provider.loadPendingOrders();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) _searchController.clear();
    });
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
                  onChanged: (value) {
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
          actions: _activeScreen == "Items"
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
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blueAccent),
                child: Text(
                  'Actions',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              buildDrawerItem(Icons.home, "Items", updateScreen,
                  const ItemContent(), _activeScreen),
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
        body: _selectedScreen);
  }
}
