import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/manCard.dart';
import '../widgets/widgets.dart';
import '../providers/canteenProvider.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  _ManagerScreenState createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedCanteen;
  bool _isEditing = false;
  String? _editingManagerId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<CanteenProvider>(context, listen: false);
      provider.fetchCanteens();
      provider.fetchManagers();
    });
  }

  void _showAddManagerModal(BuildContext context,
      {String? name, String? email, String? canteenId, String? managerId}) {
    setState(() {
      _isEditing = managerId != null;
      _editingManagerId = managerId;
      _nameController.text = name ?? "";
      _emailController.text = email ?? "";
      _passwordController.text = "";
      _selectedCanteen = canteenId;
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
                _isEditing ? "Edit Manager" : "Add Manager",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),

              CustomTextFormField(
                controller: _nameController,
                hintText: "Enter manager name",
                labelText: "Manager Name",
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

              Consumer<CanteenProvider>(
                builder: (context, provider, child) {
                  return CustomDropdown(
                    value: _selectedCanteen,
                    hintText: "Select Canteen",
                    items: provider.canteens.map((canteen) {
                      return {
                        'id': canteen['_id'].toString(),
                        'name': canteen['name'].toString(),
                      };
                    }).toList().cast<Map<String, String>>(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCanteen = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              CustomButton(
                text: _isEditing ? "Update Manager" : "Add Manager",
                onPressed: () async {
                  final provider =
                  Provider.of<CanteenProvider>(context, listen: false);

                  if (_selectedCanteen == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a canteen")),
                    );
                    return;
                  }

                  bool success;
                  if (_isEditing) {
                    success = await provider.updateManager(
                      managerId: _editingManagerId!,
                      name: _nameController.text,
                      email: _emailController.text,
                      canteenId: _selectedCanteen!,
                      role: 'manager',
                    );
                  } else {
                    success = await provider.registerManager(
                      name: _nameController.text,
                      email: _emailController.text,
                      password: _passwordController.text,
                      canteenId: _selectedCanteen!,
                      role: 'manager',
                    );
                  }

                  if (success) {
                    provider.fetchManagers();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(_isEditing
                              ? "Failed to update manager"
                              : "Failed to add manager")),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content:
        const Text("Are you sure you want to delete this manager?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
            const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CanteenProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              margin: const EdgeInsets.all(15),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.managers.isEmpty
                  ? const Center(child: Text("No managers found"))
                  : ListView.builder(
                itemCount: provider.managers.length,
                itemBuilder: (context, index) {
                  final manager = provider.managers[index];
                  return ManagerCard(
                    name: manager['name'],
                    email: manager['email'],
                    canteenName: manager['canteenName'],
                    onEdit: () => _showAddManagerModal(
                      context,
                      name: manager['name'],
                      email: manager['email'],
                      canteenId: manager['canteenId'],
                      managerId: manager['id'],
                    ),
                    onDelete: () async {
                      bool confirmDelete =
                      await _showDeleteConfirmationDialog(
                          context);
                      if (confirmDelete) {
                        await provider.deleteManager(
                            managerId: manager['id']);
                        provider.fetchManagers();
                      }
                    },
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () => _showAddManagerModal(context),
                backgroundColor: Colors.blueAccent,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
