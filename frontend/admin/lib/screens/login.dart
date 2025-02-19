import 'package:admin/providers/authProvider.dart';
import 'package:admin/services/canteen-service.dart';
import 'package:admin/widgets/widgets.dart';
import 'package:admin/screens/home.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final CanteenService _canteenService = CanteenService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthProvider _authProvider = AuthProvider();
  bool _isLoading = false; // Add loading state

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      ShowSnackbar.showMessage(context, "Please fill in valid details.",
          isOk: false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String email = emailController.text;
      String password = passwordController.text;
      final resData = await _authProvider.login(email, password);
      if (resData['isOk']) {
        ShowSnackbar.showMessage(context, resData['message'], isOk: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ShowSnackbar.showMessage(context, resData['error'], isOk: false);
      }
    } catch (error) {
      ShowSnackbar.showMessage(context, "Something went wrong. Try again!",
          isOk: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Login",
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w400,
                    color: Colors.blueAccent),
              ),
              const SizedBox(height: 60),
              Column(
                children: [
                  CustomTextFormField(
                    hintText: 'Enter your email.',
                    labelText: 'Email',
                    suffixIcon: Icons.email,
                    controller: emailController,
                    obscureText: false,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    hintText: 'Enter your password.',
                    labelText: 'Password',
                    suffixIcon: Icons.lock,
                    controller: passwordController,
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                    text: 'Submit',
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    onPressed: _login,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
