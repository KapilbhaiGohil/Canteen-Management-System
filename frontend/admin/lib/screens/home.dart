import 'package:admin/providers/canteenProvider.dart';
import 'package:admin/screens/addCanteen.dart';
import 'package:admin/screens/manager.dart';
import 'package:flutter/material.dart';
import 'package:admin/widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../providers/authProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeScreen = "Home";
  late Widget _selectedScreen;

  @override
  void initState() {
    super.initState();
    _selectedScreen = HomeContent(updateScreen: updateScreen);

    Future.microtask(() async {
      final canteenProvider =
      Provider.of<CanteenProvider>(context, listen: false);
      await canteenProvider.fetchCanteens();
    });
  }

  void updateScreen(String screenName, Widget screenWidget, [bool shouldPop = true]) {
    setState(() {
      _activeScreen = screenName;
      _selectedScreen = screenWidget;
    });
    if (shouldPop) {
      Navigator.pop(context);
    }
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
              onPressed: () async {
                Navigator.pop(context);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }


  Widget _buildDrawerItem(String title,IconData icon, Widget screen) {
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
        updateScreen(title, screen);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
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
            _buildDrawerItem("Home", Icons.home, HomeContent(updateScreen: updateScreen)),
            _buildDrawerItem("Add Canteen", Icons.add, Addcanteen(updateScreen: updateScreen)),
            _buildDrawerItem("Managers", Icons.people, ManagerScreen()),
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
}

class HomeContent extends StatelessWidget {
  final Function(String, Widget, [bool]) updateScreen;

  HomeContent({super.key, required this.updateScreen});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<CanteenProvider>(
      builder: (context, canteenProvider, _) {
        if (canteenProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }

        if (canteenProvider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Failed to load canteens. Try again!"),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await canteenProvider.fetchCanteens();
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (canteenProvider.canteens.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "No canteens available. Add a new one!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(

                  onPressed: () {
                    updateScreen("Add Canteen", Addcanteen(updateScreen: updateScreen),false);
                  },
                  icon: const Icon(Icons.add,color: Colors.white,),
                  label: const Text("Add Canteen"),
                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: Scrollbar(
                interactive: true,
                radius: const Radius.circular(8),
                thickness: 5,
                thumbVisibility: true,
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount: canteenProvider.canteens.length,
                    itemBuilder: (context, index) {
                      final canteen = canteenProvider.canteens[index];
                      return CustomListTile(
                        updateScreen: updateScreen,
                        canteenProvider: canteenProvider,
                        index: index,
                        canteenId: canteen['_id'],
                        canteenName: canteen['name'] ?? 'N/A',
                        collegeName: canteen['collegeName'] ?? 'N/A',
                        district: canteen['district'] ?? 'N/A',
                        pincode: int.tryParse(canteen['pinCode'].toString()) ?? 0,
                        imageUrl: canteen['imageUrl'] ?? 'https://via.placeholder.com/150',
                        state: canteen['state'] ?? 'N/A',
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}