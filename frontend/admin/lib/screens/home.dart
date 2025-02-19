import 'package:admin/screens/addCanteen.dart';
import 'package:flutter/material.dart';
import 'package:admin/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController collegeNameController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

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
            child: Scrollbar(
              interactive: true,
              radius: Radius.circular(8),
              thickness: 5,
              thumbVisibility: true,
              trackVisibility: true,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: ListView.separated(
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return CustomListTile();
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
            child: CustomButton(
              text: "Add new",
              onPressed: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Addcanteen()))
              },
              icon: Icons.add,
            ),
          )
        ],
      ),
    );
  }
}
