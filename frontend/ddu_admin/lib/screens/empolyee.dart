import 'package:ddu_admin/components/empcard.dart';
import 'package:ddu_admin/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/canteenProvider.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'foodProvider';
  bool _isEditing = false;
  String? _editingEmployeeId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<CanteenProvider>(context, listen: false);
      provider.loadEmployees();
    });
  }

  void _showAddEmployeeModal(BuildContext context,
      {String? name, String? email, String? role, String? employeeId}) {
    setState(() {
      _isEditing = employeeId != null;
      _editingEmployeeId = employeeId;
      _nameController.text = name ?? "";
      _emailController.text = email ?? "";
      _passwordController.text = "";
      _selectedRole = role ?? "foodProvider";
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
                    color: Colors.blueAccent),
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: _nameController,
                hintText: "Enter employee name",
                labelText: "Employee Name",
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: _emailController,
                hintText: "Enter email",
                labelText: "Email",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
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
              CustomDropdown(
                value: _selectedRole,
                hintText: "Select Role",
                items: ["foodProvider", "Chef"],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: _isEditing ? "Update Employee" : "Add Employee",
                onPressed: () async {
                  var provider =
                      Provider.of<CanteenProvider>(context, listen: false);
                  if (_isEditing) {
                    await provider.updateUser(
                      _editingEmployeeId!,
                      _nameController.text,
                      _emailController.text,
                      _selectedRole,
                    );
                  } else {
                    await provider.registerUser(
                      _nameController.text,
                      _emailController.text,
                      _passwordController.text,
                      _selectedRole,
                    );
                  }
                  Navigator.pop(context);
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
    var provider = Provider.of<CanteenProvider>(context);
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          margin: const EdgeInsets.all(15),
          child: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blueAccent,
                  ),
                )
              : provider.hasError
                  ? const Center(child: Text("Failed to load employees"))
                  : provider.employees.isEmpty
                      ? const Center(child: Text("No employees found"))
                      : ListView.separated(
                          itemCount: provider.employees.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10), // Space between cards
                          itemBuilder: (context, index) {
                            final emp = provider.employees[index];
                            return EmployeeCard(
                              employeeId: emp.id,
                              name: emp.name,
                              email: emp.email,
                              role: emp.role,
                              onEdit: () => _showAddEmployeeModal(
                                context,
                                name: emp.name,
                                email: emp.email,
                                role: emp.role,
                                employeeId: emp.id,
                              ),
                            );
                          },
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
