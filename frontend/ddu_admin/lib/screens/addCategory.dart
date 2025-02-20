import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/widgets.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _categoryDescController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add new category",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
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
                    TextFormField(
                      maxLines: 4,
                      minLines: 4,
                      maxLength: 200,
                      controller: _categoryDescController,
                      decoration: InputDecoration(
                        hintText: "Enter category description",
                        labelText: "Category description",
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        alignLabelWithHint: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        suffixIcon: Icon(
                          Icons.description,
                          color: Colors.blueAccent,
                        ),
                      ),
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
            child: CustomButton(
              text: "Submit",
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Handle form submission
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
