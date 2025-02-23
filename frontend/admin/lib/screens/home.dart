import 'package:admin/constants.dart';
import 'package:admin/providers/canteenProvider.dart';
import 'package:admin/screens/addCanteen.dart';
import 'package:admin/screens/login.dart';
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppConstants.secondaryColor,
          title: const Text(
            "Log Out",
            style: TextStyle(color: AppConstants.errorColor),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(color: AppConstants.textColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "No",
                style: TextStyle(color: AppConstants.textColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const LoginScreen(),
                  ),
                );
              },
              child: const Text("Yes",
                  style: TextStyle(color: AppConstants.errorColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, Widget screen) {
    bool isSelected = _activeScreen == title;
    return ListTile(
      leading: Icon(icon,
          color:
              isSelected ? AppConstants.successColor : AppConstants.textColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color:
              isSelected ? AppConstants.successColor : AppConstants.textColor,
        ),
      ),
      onTap: () {
        updateScreen(title, screen);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final canteenProvider =
            Provider.of<CanteenProvider>(context, listen: false);
        await canteenProvider.fetchCanteens();
        setState(() {});
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppConstants.primaryColor,
        appBar: AppBar(
          title: Text(
            _activeScreen,
            style: const TextStyle(color: AppConstants.textColor),
          ),
          backgroundColor: AppConstants.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: AppConstants.textColor),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        drawer: Drawer(
          backgroundColor: AppConstants.secondaryColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: AppConstants.primaryColor),
                child: Text(
                  'Actions',
                  style:
                      TextStyle(color: AppConstants.successColor, fontSize: 24),
                ),
              ),
              _buildDrawerItem(
                  "Home", Icons.home, HomeContent(updateScreen: updateScreen)),
              _buildDrawerItem("Add Canteen", Icons.add,
                  Addcanteen(updateScreen: updateScreen)),
              _buildDrawerItem("Managers", Icons.people, ManagerScreen()),
              ListTile(
                leading:
                    const Icon(Icons.logout, color: AppConstants.errorColor),
                title: const Text(
                  "Log out",
                  style: TextStyle(
                      color: AppConstants.errorColor,
                      fontWeight: FontWeight.bold),
                ),
                onTap: _showLogoutDialog,
              ),
            ],
          ),
        ),
        body: _selectedScreen,
      ),
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
            child: CircularProgressIndicator(color: AppConstants.primaryColor),
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
                  style: TextStyle(
                      fontSize: 18,
                      color: AppConstants.textColor,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    updateScreen("Add Canteen",
                        Addcanteen(updateScreen: updateScreen), false);
                  },
                  icon: const Icon(
                    Icons.add,
                    color: AppConstants.primaryColor,
                  ),
                  label: const Text("Add Canteen"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.successColor,
                    foregroundColor: AppConstants.primaryColor,
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
                        pincode:
                            int.tryParse(canteen['pinCode'].toString()) ?? 0,
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
          ],
        );
      },
    );
  }
}
