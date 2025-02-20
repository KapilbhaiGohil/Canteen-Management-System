import 'package:flutter/material.dart';

import '../components/empcard.dart';
import '../widgets/widgets.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'Provider';
  bool _isEditing = false; // Track whether it's an edit operation
  String? _editingEmployeeId; // Store the ID of the employee being edited

  void _showAddEmployeeModal(BuildContext context, {String? name, String? email, String? role, String? employeeId}) {
    setState(() {
      _isEditing = employeeId != null; // If employeeId exists, it's an edit operation
      _editingEmployeeId = employeeId;
      _nameController.text = name ?? "";
      _emailController.text = email ?? "";
      _passwordController.text = ""; // Password shouldn't be prefilled
      _selectedRole = role ?? "Provider";
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
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
                value: _selectedRole,
                hintText: "Select Role",
                items: ["Provider", "Manager", "Chef"],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Submit Button
              CustomButton(
                text: _isEditing ? "Update Employee" : "Add Employee",
                onPressed: () {
                  if (_isEditing) {
                    print("Updated Employee: ${_nameController.text}, Role: $_selectedRole, ID: $_editingEmployeeId");
                    // Call API to update employee
                  } else {
                    print("Added Employee: ${_nameController.text}, Role: $_selectedRole");
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
              EmployeeCard(
                name: "John Doe",
                email: "john@example.com",
                role: "Manager",
                onEdit: () => _showAddEmployeeModal(context, name: "John Doe", email: "john@example.com", role: "Manager", employeeId: "123"),
              ),
              const SizedBox(height: 8),
              EmployeeCard(
                name: "Jane Smith",
                email: "jane@example.com",
                role: "Chef",
                onEdit: () => _showAddEmployeeModal(context, name: "Jane Smith", email: "jane@example.com", role: "Chef", employeeId: "456"),
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
