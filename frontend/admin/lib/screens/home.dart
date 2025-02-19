import 'package:admin/screens/addCanteen.dart';
import 'package:flutter/material.dart';
import 'package:admin/widgets/widgets.dart';
import '../services/canteen-service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CanteenService _canteenService = CanteenService();
  List<dynamic> canteens = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchCanteens();
  }

  Future<void> fetchCanteens() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      List<dynamic> fetchedCanteens = await _canteenService.getCanteens();
      setState(() {
        canteens = fetchedCanteens;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent,)) // 🔹 Loading Indicator
                : hasError
                ? const Center(child: Text("Failed to load canteens. Try again!")) // 🔹 Error Message
                : canteens.isEmpty
                ? const Center(child: Text("No canteens available.")) // 🔹 Empty State
                : Scrollbar(
              interactive: true,
              radius: const Radius.circular(8),
              thickness: 5,
              thumbVisibility: true,
              trackVisibility: true,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: ListView.separated(
                  itemCount: canteens.length,
                  itemBuilder: (context, index) {
                    final canteen = canteens[index];
                    return CustomListTile(
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
          Padding(
            padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
            child: CustomButton(
              text: "Add new",
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Addcanteen()),
                );
              },
              icon: Icons.add,
            ),
          ),
        ],
      ),
    );
  }
}
