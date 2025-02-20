import 'package:admin/providers/canteenProvider.dart';
import 'package:admin/screens/addCanteen.dart';
import 'package:flutter/material.dart';
import 'package:admin/widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../services/canteen-service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CanteenService _canteenService = CanteenService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final canteenProvider =
      Provider.of<CanteenProvider>(context, listen: false);
      await canteenProvider.fetchCanteens(_canteenService);
    });
  }


  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    String _activeScreen = "Home";
    Widget _selectedScreen =  HomeContent();

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

    void _updateScreen(String screenName, Widget screenWidget) {
      setState(() {
        _activeScreen = screenName;
        _selectedScreen = screenWidget;
      });
      Navigator.pop(context);
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
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blueAccent),
                child: const Text(
                  'Actions',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              _buildDrawerItem(Icons.home, "Home", HomeContent()),
              _buildDrawerItem(Icons.category, "Add Category", const Addcanteen()),

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
  HomeContent({super.key});
  final CanteenService _canteenService = CanteenService();

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
                    await canteenProvider.fetchCanteens(_canteenService);
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: canteenProvider.canteens.isEmpty
                  ? const Center(child: Text("No canteens available."))
                  : Scrollbar(
                interactive: true,
                radius: const Radius.circular(8),
                thickness: 5,
                thumbVisibility: true,
                trackVisibility: true,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: ListView.separated(
                    itemCount: canteenProvider.canteens.length,
                    itemBuilder: (context, index) {
                      final canteen = canteenProvider.canteens[index];
                      return CustomListTile(
                        canteenName: canteen['name'] ?? 'N/A',
                        collegeName: canteen['collegeName'] ?? 'N/A',
                        district: canteen['district'] ?? 'N/A',
                        pincode: int.tryParse(
                            canteen['pinCode'].toString()) ??
                            0,
                        imageUrl: canteen['imageUrl'] ??
                            'https://via.placeholder.com/150',
                        state: canteen['state'] ?? 'N/A',
                      );
                    },
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              child: CustomButton(
                text: "Add new",
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Addcanteen()),
                  );
                  await Provider.of<CanteenProvider>(context, listen: false)
                      .fetchCanteens(_canteenService);
                },
                icon: Icons.add,
              ),
            ),
          ],
        );
      },
    );
  }
}
