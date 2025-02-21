import 'package:admin/providers/canteenProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/addCanteen.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String labelText;
  final IconData? suffixIcon;
  final Function(String)? onChanged;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.labelText,
    this.suffixIcon,
    this.onChanged,
    required this.obscureText,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.blueAccent)
            : null,
        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.normal,
        ),
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      inputFormatters: inputFormatters ?? [],
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String labelText;
  final IconData? suffixIcon;
  final Function(String)? onChanged;
  final bool? obscureText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const CustomTextFormField({
    super.key,
    this.controller,
    required this.hintText,
    required this.labelText,
    this.suffixIcon,
    this.onChanged,
    this.obscureText,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType ?? TextInputType.text,
      validator: validator,
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText ?? false,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.blueAccent)
            : null,
        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.normal,
        ),
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      inputFormatters: inputFormatters ?? [],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: textColor,
                backgroundColor: backgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 8,
                      )
                    ],
                    Text(
                      text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowSnackbar {
  static void showMessage(BuildContext context, String message,
      {bool isOk = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isOk ? Colors.green : Colors.red,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class CustomListTile extends StatefulWidget {
  final String canteenName;
  final String collegeName;
  final String district;
  final String state;
  final int pincode;
  final String imageUrl;
  final int index;
  final String canteenId;
  final CanteenProvider canteenProvider;
  final Function(String, Widget, [bool]) updateScreen;

  const CustomListTile({
    super.key,
    required this.canteenName,
    required this.collegeName,
    required this.district,
    required this.state,
    required this.pincode,
    required this.imageUrl,
    required this.index,
    required this.canteenProvider,
    required this.canteenId,
    required this.updateScreen,
  });

  @override
  _CustomListTileState createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  bool _isTapped = false;

  void _confirmDelete(BuildContext context, CanteenProvider canteenProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Are you sure you want to delete ${widget.canteenName}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await canteenProvider.deleteCanteen(canteenId: widget.canteenId);
                Navigator.pop(context);
                print("Deleted canteen: ${widget.canteenId}");
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _updateCanteen(BuildContext context) {
    widget.updateScreen(
      "Update Canteen",
      Addcanteen(
        updateScreen: widget.updateScreen,
        canteen: {
          '_id': widget.canteenId,
          'name': widget.canteenName,
          'collegeName': widget.collegeName,
          'district': widget.district,
          'state': widget.state,
          'pinCode': widget.pincode.toString(),
          'imageUrl': widget.imageUrl,
        },
      ),
      false,
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blueAccent),
              title: const Text("Update Canteen"),
              onTap: () {
                Navigator.pop(context);
                _updateCanteen(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text("Delete Canteen"),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, widget.canteenProvider);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showOptions(context),
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        height: _isTapped ? 120 : 110,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 193, 224, 239),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
          border: Border(left: BorderSide(color: Colors.blueAccent, width: 5)),
          boxShadow: _isTapped
              ? [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 10,
            )
          ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                widget.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.canteenName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text("${widget.collegeName}, ${widget.district}"),
                const SizedBox(height: 4),
                Text("${widget.state}, ${widget.pincode}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<Map<String, String>> items; // ✅ Accepts list of maps
  final Function(String?)? onChanged;
  final FormFieldValidator<String>? validator;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.normal,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      items: items.map((canteen) {
        return DropdownMenuItem<String>(
          value: canteen['id'], // ✅ Store ID
          child: Text(canteen['name']!), // ✅ Display Name
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
