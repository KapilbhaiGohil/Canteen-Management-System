import 'package:ddu_admin/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/canteenProvider.dart';
import '../widgets/widgets.dart';

class AddCategoryScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final String? categoryDesc;
  final bool isUpdate;
  final Function(String, Widget, [bool]) updateScreen;
  const AddCategoryScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.categoryDesc,
    this.isUpdate = false,
    required this.updateScreen,
  });

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _categoryDescController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.isUpdate) {
      _categoryNameController.text = widget.categoryName ?? '';
      _categoryDescController.text = widget.categoryDesc ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canteenProvider = Provider.of<CanteenProvider>(context);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextFormField(
                    hintText: "Enter category name",
                    labelText: "Category name",
                    obscureText: false,
                    suffixIcon: Icons.category,
                    controller: _categoryNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Category name is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    hintText: "Enter category description",
                    labelText: "Category description",
                    obscureText: false,
                    suffixIcon: Icons.description,
                    controller: _categoryDescController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Category description is required";
                      } else if (value.length < 10) {
                        return "Category description must be at least 10 characters long";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                ))
              : CustomButton(
                  text: widget.isUpdate ? "Update" : "Submit",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);

                      bool success;
                      if (widget.isUpdate) {
                        // Update category
                        success = await canteenProvider.updateCategory(
                          widget.categoryId!,
                          _categoryNameController.text,
                          _categoryDescController.text,
                        );
                      } else {
                        // Create new category
                        success = await canteenProvider.createCategory(
                          _categoryNameController.text,
                          _categoryDescController.text,
                        );
                      }

                      setState(() => _isLoading = false);
                      widget.updateScreen(
                          "Home",
                          HomeContent(
                              searchQuery: "",
                              updateScreen: widget.updateScreen),
                          false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? widget.isUpdate
                                  ? "Category updated!"
                                  : "Category added!"
                              : "Failed to ${widget.isUpdate ? 'update' : 'add'} category!"),
                        ),
                      );

                      if (success) {
                        _categoryNameController.clear();
                        _categoryDescController.clear();
                      }
                    }
                  },
                ),
        ),
      ],
    );
  }
}
