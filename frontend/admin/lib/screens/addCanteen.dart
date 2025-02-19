import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class Addcanteen extends StatefulWidget {
  const Addcanteen({super.key});

  @override
  State<Addcanteen> createState() => _AddcanteenState();
}

class _AddcanteenState extends State<Addcanteen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "Add new canteen",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Form(
                  child: Column(
                children: [
                  CustomTextFormField(
                      hintText: "Enter your canteen name",
                      labelText: "Canteen name",
                      obscureText: false),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomTextField(
                      hintText: "Enter your college name",
                      labelText: "College name",
                      obscureText: false),
                  const SizedBox(
                    height: 9,
                  ),
                ],
              )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
            child: CustomButton(
              text: "Submit",
              onPressed: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Addcanteen()))
              },
            ),
          )
        ],
      ),
    );
  }
}
