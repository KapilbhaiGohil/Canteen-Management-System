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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Canteens",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<CanteenProvider>(
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
      ),
    );
  }
}
