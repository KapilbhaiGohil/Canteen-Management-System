import 'dart:io';
import 'package:admin/providers/canteenProvider.dart';
import 'package:admin/services/canteen-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../widgets/widgets.dart';

class Addcanteen extends StatefulWidget {
  const Addcanteen({super.key});

  @override
  State<Addcanteen> createState() => _AddcanteenState();
}

class _AddcanteenState extends State<Addcanteen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _canteenNameController = TextEditingController();
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final CanteenService _canteenService = CanteenService();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a Photo"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final canteenProvider =
          Provider.of<CanteenProvider>(context, listen: false);
      bool isAdded = await canteenProvider.addCanteen(
        canteenService: _canteenService,
        imageFile: _image,
        name: _canteenNameController.text,
        collegeName: _collegeNameController.text,
        district: _districtController.text,
        state: _stateController.text,
        pinCode: _pincodeController.text,
        context: context,
      );

      if (isAdded) {
        Navigator.pop(context);
        ShowSnackbar.showMessage(context, "Canteen added successfully");
      }
    }
  }

  @override
  void dispose() {
    _canteenNameController.dispose();
    _collegeNameController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add new canteen",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(15),
              child: Form(
                autovalidateMode: AutovalidateMode.onUnfocus,
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                _image != null ? FileImage(_image!) : null,
                            child: _image == null
                                ? const Icon(Icons.image,
                                    size: 50, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 10,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueAccent,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomTextFormField(
                      hintText: "Enter your canteen name",
                      labelText: "Canteen name",
                      obscureText: false,
                      suffixIcon: Icons.food_bank,
                      controller: _canteenNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Canteen name is required";
                        } else if (value.length < 5) {
                          return "Canteen name should be atleast 5 character long";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    CustomTextFormField(
                      hintText: "Enter your college name (optional)",
                      labelText: "College name",
                      controller: _collegeNameController,
                      obscureText: false,
                      suffixIcon: Icons.school,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            hintText: "Enter district name",
                            labelText: "District",
                            controller: _districtController,
                            suffixIcon: Icons.business,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "District name is required";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomTextFormField(
                            labelText: 'State',
                            hintText: 'Enter state name',
                            controller: _stateController,
                            suffixIcon: Icons.location_city,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "State name is required";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomTextFormField(
                      keyboardType: TextInputType.number,
                      hintText: 'Enter pincode',
                      labelText: 'Pincode',
                      controller: _pincodeController,
                      suffixIcon: Icons.pin,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Pincode is required.";
                        } else if (value.length != 6) {
                          return "Pincode should be 6 digit number only.";
                        }
                        return null;
                      },
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            child: CustomButton(text: "Submit", onPressed: _submitForm),
          ),
        ],
      ),
    );
  }
}
