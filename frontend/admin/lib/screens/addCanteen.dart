import 'dart:io';
import 'dart:isolate';
import 'package:admin/constants.dart';
import 'package:admin/providers/canteenProvider.dart';
import 'package:admin/screens/home.dart';
import 'package:admin/services/canteenService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/widgets.dart';

class Addcanteen extends StatefulWidget {
  final Function(String, Widget, [bool]) updateScreen;
  final Map<String, dynamic>? canteen;

  const Addcanteen({super.key, required this.updateScreen, this.canteen});

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
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool isUpdating = false;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    if (widget.canteen != null) {
      // Populate fields for updating
      _canteenNameController.text = widget.canteen!['name'] ?? '';
      _collegeNameController.text = widget.canteen!['collegeName'] ?? '';
      _districtController.text = widget.canteen!['district'] ?? '';
      _stateController.text = widget.canteen!['state'] ?? '';
      _pincodeController.text = widget.canteen!['pinCode'] ?? '';
      _existingImageUrl = widget.canteen!['imageUrl'];
      isUpdating = true;
    }
  }

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
                    _existingImageUrl = null; // Clear existing image
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
                    _existingImageUrl = null; // Clear existing image
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
    if (_formKey.currentState!.validate()) {
      final canteenProvider =
          Provider.of<CanteenProvider>(context, listen: false);
      setState(() {
        _isLoading = true;
      });
      if (isUpdating) {
        bool isUpdated = await canteenProvider.updateCanteen(
          canteenId: widget.canteen!['_id'],
          imageFile: _image,
          name: _canteenNameController.text,
          collegeName: _collegeNameController.text,
          district: _districtController.text,
          state: _stateController.text,
          pinCode: _pincodeController.text,
        );

        if (isUpdated) {
          widget.updateScreen(
              "Home", HomeContent(updateScreen: widget.updateScreen), false);
          ShowSnackbar.showMessage(context, "Canteen updated successfully",
              isOk: true);
        }
      } else {
        if (_image == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select an image")),
          );
          return;
        }
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
          widget.updateScreen(
              "Home", HomeContent(updateScreen: widget.updateScreen), false);
          ShowSnackbar.showMessage(context, "Canteen added successfully",
              isOk: true);
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
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
                          backgroundColor: AppConstants.textColor,
                          backgroundImage: _image != null
                              ? FileImage(_image!) as ImageProvider
                              : _existingImageUrl != null
                                  ? NetworkImage(_existingImageUrl!)
                                  : null,
                          child: (_image == null && _existingImageUrl == null)
                              ? const Icon(Icons.image,
                                  size: 50, color: AppConstants.buttonColor)
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
                                color: AppConstants.successColor,
                              ),
                              padding: const EdgeInsets.all(5),
                              child: const Icon(Icons.camera_alt,
                                  color: AppConstants.primaryColor, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomTextFormField(
                    hintText: "Enter canteen name",
                    labelText: "Canteen name",
                    controller: _canteenNameController,
                    suffixIcon: Icons.food_bank,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Canteen name is required";
                      } else if (value.length < 5) {
                        return "Canteen name should be at least 5 characters long";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    hintText: "Enter college name (optional)",
                    labelText: "College name",
                    controller: _collegeNameController,
                    suffixIcon: Icons.school,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          hintText: "Enter district name",
                          labelText: "District",
                          controller: _districtController,
                          suffixIcon: Icons.business,
                          validator: (value) => value == null || value.isEmpty
                              ? "District is required"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextFormField(
                          labelText: 'State',
                          hintText: 'Enter state name',
                          controller: _stateController,
                          suffixIcon: Icons.location_city,
                          validator: (value) => value == null || value.isEmpty
                              ? "State is required"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    keyboardType: TextInputType.number,
                    hintText: 'Enter pincode',
                    labelText: 'Pincode',
                    controller: _pincodeController,
                    suffixIcon: Icons.pin,
                    validator: (value) =>
                        value == null || value.isEmpty || value.length != 6
                            ? "Enter a valid 6-digit pincode"
                            : null,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            child: CustomButton(
                text: isUpdating ? "Update" : "Submit",
                isLoading: _isLoading,
                onPressed: _submitForm),
          ),
        ],
      ),
    );
  }
}
