import 'dart:io';
import 'package:ddu_admin/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/canteenProvider.dart';
import '../widgets/widgets.dart';

class AddItemScreen extends StatefulWidget {
  final Function(String, Widget, [bool]) updateScreen;
  final String? itemId; // NULL if adding new item
  final String? initialName;
  final String? initialPrice;
  final String? initialImage;
  final String? initialCategoryId;

  const AddItemScreen({
    super.key,
    required this.updateScreen,
    this.itemId,
    this.initialName,
    this.initialPrice,
    this.initialImage,
    this.initialCategoryId,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _categories = [];

  String? _selectedCategoryId;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.itemId != null) {
      _itemNameController.text = widget.initialName ?? "";
      _priceController.text = widget.initialPrice ?? "";
      _selectedCategoryId = widget.initialCategoryId;
      _existingImageUrl = widget.initialImage;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    final provider = Provider.of<CanteenProvider>(context, listen: false);
    await provider.loadCategories();
    setState(() {
      _categories = provider.categories;
    });
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
                    _existingImageUrl = null;
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
                    _existingImageUrl = null;
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
    if (_image == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<CanteenProvider>(context, listen: false);
      bool success = false;

      if (widget.itemId == null) {
        if (_image == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select an image")),
          );
          return;
        }
        success = await provider.addItem(
          _itemNameController.text.trim(),
          _selectedCategoryId!,
          double.parse(_priceController.text.trim()),
          _image?.path ?? "",
        );
      } else {
        success = await provider.updateItem(
          widget.itemId!,
          _itemNameController.text.trim(),
          _selectedCategoryId!,
          double.parse(_priceController.text.trim()),
          true,
          _image,
        );
      }

      if (success) {
        widget.updateScreen(
            "Home",
            HomeContent(searchQuery: "", updateScreen: widget.updateScreen),
            false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.itemId == null
                  ? "Item added successfully!"
                  : "Item updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Operation failed.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                            image: _image != null
                                ? DecorationImage(
                                    image: FileImage(_image!),
                                    fit: BoxFit.cover,
                                  )
                                : (_existingImageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(_existingImageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null),
                          ),
                          child: (_image == null && _existingImageUrl == null)
                              ? const Icon(Icons.image,
                                  size: 50, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
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
                    hintText: "Enter item name",
                    labelText: "Item name",
                    controller: _itemNameController,
                    suffixIcon: Icons.food_bank,
                    validator: (value) =>
                        value!.isEmpty ? "Item name is required" : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    hint: const Text("Select Category"),
                    items:
                        _categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category['_id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategoryId = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Category is required' : null,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    keyboardType: TextInputType.number,
                    hintText: 'Enter price',
                    labelText: 'Price',
                    controller: _priceController,
                    suffixIcon: Icons.currency_rupee,
                    validator: (value) =>
                        value!.isEmpty ? "Price is required" : null,
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
          child: CustomButton(
            text: widget.itemId == null ? "Add Item" : "Update Item",
            onPressed: _submitForm,
          ),
        ),
      ],
    );
  }
}
