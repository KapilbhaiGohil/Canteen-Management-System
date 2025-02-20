import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class CustomListTile extends StatelessWidget {
  final String canteenName;
  final String collegeName;
  final String district;
  final String state;
  final int pincode;
  final String imageUrl;

  const CustomListTile({
    super.key,
    required this.canteenName,
    required this.collegeName,
    required this.district,
    required this.state,
    required this.pincode,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.4),
        borderRadius: BorderRadius.circular(5),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(5), // Rounded corners for the image
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover, // Ensure the image covers the area nicely
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.error,
                color: Colors.red,
                size: 50,
              ), // Show error icon if image fails to load
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                canteenName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text("$collegeName, $district"),
              const SizedBox(height: 4),
              Text("$state, $pincode"),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<String> items;
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
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
