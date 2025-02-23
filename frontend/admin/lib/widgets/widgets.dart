import 'package:admin/constants.dart';
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
      style: const TextStyle(color: AppConstants.textColor),
      decoration: InputDecoration(
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: AppConstants.accentColor)
            : null,
        fillColor: AppConstants.secondaryColor,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(color: AppConstants.hintTextColor),
        labelText: labelText,
        labelStyle: const TextStyle(color: AppConstants.textColor),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppConstants.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppConstants.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppConstants.accentColor),
          borderRadius: BorderRadius.circular(8),
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
      style: const TextStyle(color: AppConstants.textColor),
      decoration: InputDecoration(
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: AppConstants.successColor)
            : null,
        fillColor: AppConstants.secondaryColor,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppConstants.hintTextColor,
          fontWeight: FontWeight.normal,
        ),
        labelText: labelText,
        labelStyle: const TextStyle(
          color: AppConstants.textColor,
          fontSize: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppConstants.successColor),
          borderRadius: BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppConstants.successColor),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppConstants.successColor),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      inputFormatters: inputFormatters ?? [],
    );
  }
}

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: widget.textColor ?? AppConstants.primaryColor,
                backgroundColor:
                    widget.backgroundColor ?? AppConstants.successColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: AppConstants.textColor),
                          const SizedBox(width: 8),
                        ],
                        Text(widget.text, style: const TextStyle(fontSize: 16)),
                      ],
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
          style: const TextStyle(
            color: AppConstants.primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            isOk ? AppConstants.successColor : AppConstants.errorColor,
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
          backgroundColor: AppConstants.secondaryColor,
          title: const Text("Confirm Delete",
              style: TextStyle(color: AppConstants.errorColor)),
          content: Text(
              "Are you sure you want to delete ${widget.canteenName}?",
              style: const TextStyle(color: AppConstants.textColor)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: AppConstants.textColor)),
            ),
            TextButton(
              onPressed: () async {
                await canteenProvider.deleteCanteen(
                    canteenId: widget.canteenId);
                Navigator.pop(context);
                print("Deleted canteen: ${widget.canteenId}");
              },
              child: const Text("Delete",
                  style: TextStyle(color: AppConstants.errorColor)),
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
      backgroundColor: AppConstants.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppConstants.accentColor),
              title: const Text("Update Canteen",
                  style: TextStyle(color: AppConstants.textColor)),
              onTap: () {
                Navigator.pop(context);
                _updateCanteen(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppConstants.errorColor),
              title: const Text("Delete Canteen",
                  style: TextStyle(color: AppConstants.textColor)),
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
          color: AppConstants.successColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
          border:
              Border(left: BorderSide(color: AppConstants.infoColor, width: 5)),
          boxShadow: _isTapped
              ? [
                  BoxShadow(
                    color: AppConstants.borderColor.withOpacity(0.3),
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
                  color: AppConstants.errorColor,
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
                    color: AppConstants.primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text("${widget.collegeName}, ${widget.district}",
                    style: const TextStyle(color: AppConstants.primaryColor)),
                const SizedBox(height: 4),
                Text("${widget.state}, ${widget.pincode}",
                    style: const TextStyle(color: AppConstants.primaryColor)),
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
        fillColor: AppConstants.secondaryColor,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppConstants.textColor,
          fontWeight: FontWeight.normal,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppConstants.successColor),
          borderRadius: BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppConstants.successColor),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppConstants.successColor),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      dropdownColor: AppConstants.secondaryColor,
      iconEnabledColor: AppConstants.successColor,
      style: const TextStyle(color: AppConstants.textColor),
      items: items.map((canteen) {
        return DropdownMenuItem<String>(
          value: canteen['id'], // ✅ Store ID
          child: Text(
            canteen['name']!,
            style: const TextStyle(color: AppConstants.textColor),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
