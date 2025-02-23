import 'package:ddu_admin/screens/itemContent.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/canteenProvider.dart';
import '../widgets/widgets.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeScreen = "Orders";
  late Widget _selectedScreen;

  @override
  void initState() {
    super.initState();
    _selectedScreen = const OrderContent();
    Future.microtask(() {
      final provider = Provider.of<CanteenProvider>(context, listen: false);
      provider.loadCookedOrders();
    });
  }

  void updateScreen(String screenName, Widget screenWidget, [bool pop = true]) {
    setState(() {
      _activeScreen = screenName;
      _selectedScreen = screenWidget;
    });
    if (pop) Navigator.pop(context);
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
            buildDrawerItem(Icons.list, "Orders", updateScreen,
                const OrderContent(), _activeScreen),
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

class OrderContent extends StatefulWidget {
  const OrderContent({super.key});

  @override
  State<OrderContent> createState() => _OrderContentState();
}

class _OrderContentState extends State<OrderContent> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CanteenProvider>(context);

    return NotificationListener<ScrollEndNotification>(
      onNotification: (scrollEnd) {
        if (scrollEnd.metrics.atEdge && scrollEnd.metrics.pixels != 0) {
          provider.loadCookedOrders();
        }
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async => provider.loadCookedOrders(),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.hasError
                ? const Center(
                    child: Text('No completed orders found.',
                        style: TextStyle(color: Colors.black87)))
                : provider.cookedOrders.isEmpty
                    ? const Center(
                        child: Text('No completed orders',
                            style: TextStyle(color: Colors.black87)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.cookedOrders.length,
                        itemBuilder: (context, index) {
                          final order = provider.cookedOrders[index];
                          return OrderCard(
                            order: order,
                            provider: provider,
                            isCompleted: true,
                          );
                        },
                      ),
      ),
    );
  }
}
