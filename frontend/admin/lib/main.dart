import 'package:admin/providers/authProvider.dart';
import 'package:admin/screens/home.dart';
import 'package:admin/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider()..tryAutoLogin(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: SplashScreen(),
            );
          }
          return MaterialApp(
            title: 'Canteen App',
            debugShowCheckedModeBanner: false,
            home: authProvider.isAuthenticated ? HomeScreen() : LoginScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}