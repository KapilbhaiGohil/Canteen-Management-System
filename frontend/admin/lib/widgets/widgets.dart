import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String labelText;
  final IconData? suffixIcon;
  final Function(String)? onChanged;
  final bool obscureText;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.labelText,
    this.suffixIcon,
    this.onChanged,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.blueAccent)
            : null,
        fillColor: Colors.black12,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.normal,
        ),
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.blueAccent,
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
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String labelText;
  final IconData? suffixIcon;
  final Function(String)? onChanged;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  const CustomTextFormField({
    super.key,
    this.controller,
    required this.hintText,
    required this.labelText,
    this.suffixIcon,
    this.onChanged,
    required this.obscureText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.blueAccent)
            : null,
        fillColor: Colors.black12,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.normal,
        ),
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.blueAccent,
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
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Takes full width
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
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class ShowSnackbar {
  static void showMessage(BuildContext context, String message, {bool isOk = false}) {
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
