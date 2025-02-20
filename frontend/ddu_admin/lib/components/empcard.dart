import 'package:flutter/material.dart';

class EmployeeCard extends StatefulWidget {
  final String name;
  final String email;
  final String role;
  final VoidCallback onEdit;

  const EmployeeCard({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.onEdit,
  });

  @override
  _EmployeeCardState createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  bool _isTapped = false;

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blueAccent),
                title: Text("Edit Employee"),
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit(); // Open Edit Modal
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.redAccent),
                title: Text("Delete Employee"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete ${widget.name}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel delete
              child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                print("Deleted Employee: ${widget.name}");
                // Call API to delete employee here
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showOptions(context), // Show options on long press
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(10),
        width: double.infinity,
        height: _isTapped ? 90 : 80, // Increases height on tap
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 193, 224, 239),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
          border: Border(left: BorderSide(color: Colors.blueAccent, width: 5)),
          boxShadow: _isTapped
              ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 10)]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                Text(
                  widget.email,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                widget.role,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
