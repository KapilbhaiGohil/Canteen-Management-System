import 'package:admin/widgets/widgets.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Text(
              "Login",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w400
              ),
            ),
            Column(
              children: [
                CustomTextfield(),
                const SizedBox(height: 20,),
                CustomTextfield(),
                const SizedBox(height: 20,),
                CustomeButton()
              ],
            )

          ],
        ),
      )
    );
  }
}
