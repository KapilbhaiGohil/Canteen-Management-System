import 'package:flutter/material.dart';

import '../components/manCard.dart';
import '../widgets/widgets.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  _ManagerScreenState createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedCanteen; // No default selection
  bool _isEditing = false;
  String? _editingEmployeeId;

  void _showAddEmployeeModal(BuildContext context,
      {String? name, String? email, String? role, String? employeeId}) {
    setState(() {
      _isEditing = employeeId != null;
      _editingEmployeeId = employeeId;
      _nameController.text = name ?? "";
      _emailController.text = email ?? "";
      _passwordController.text = "";
      _selectedCanteen = role; // Can be null for no selection
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isEditing ? "Edit Employee" : "Add Employee",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),

              // Employee Name Field
              CustomTextFormField(
                controller: _nameController,
                hintText: "Enter employee name",
                labelText: "Employee Name",
              ),
              const SizedBox(height: 10),

              // Email Field
              CustomTextFormField(
                controller: _emailController,
                hintText: "Enter email",
                labelText: "Email",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),

              // Password Field (Only required for adding new employee)
              if (!_isEditing)
                Column(
                  children: [
                    CustomTextFormField(
                      controller: _passwordController,
                      hintText: "Enter password",
                      labelText: "Password",
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),

              // Role Dropdown
              CustomDropdown(
                value: _selectedCanteen,
                hintText: "Select Canteen",
                items: ["Canteen1", "Canteen2", "Canteen3"],
                onChanged: (value) {
                  setState(() {
                    _selectedCanteen = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a canteen' : null,
              ),

              const SizedBox(height: 20),

              // Submit Button
              CustomButton(
                text: _isEditing ? "Update Employee" : "Add Employee",
                onPressed: () {
                  if (_isEditing) {
                    print(
                        "Updated Employee: ${_nameController.text}, Role: $_selectedCanteen, ID: $_editingEmployeeId");
                    // Call API to update employee
                  } else {
                    print(
                        "Added Employee: ${_nameController.text}, Role: $_selectedCanteen");
                    // Call API to add employee
                  }
                  Navigator.pop(context); // Close modal
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          margin: const EdgeInsets.all(15),
          child: Column(
            children: [
              ManagerCard(
                name: "John Doe",
                email: "john@example.com",
                canteenName: "Canteen1",
                onEdit: () => _showAddEmployeeModal(
                  context,
                  name: "John Doe",
                  email: "john@example.com",
                  role: "Canteen1",
                  employeeId: "123",
                ),
              ),
              const SizedBox(height: 8),
              ManagerCard(
                name: "Jane Smith",
                email: "jane@example.com",
                canteenName: "Canteen2",
                onEdit: () => _showAddEmployeeModal(
                  context,
                  name: "Jane Smith",
                  email: "jane@example.com",
                  role: "Canteen2",
                  employeeId: "456",
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () => _showAddEmployeeModal(context),
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
