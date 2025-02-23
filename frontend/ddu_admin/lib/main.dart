import 'package:ddu_admin/providers/authProvider.dart';
import 'package:ddu_admin/providers/canteenProvider.dart';
import 'package:ddu_admin/screens/home.dart';
import 'package:ddu_admin/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/itemScreen.dart';
import 'screens/orders.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CanteenProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Canteen App',
            home: _buildHome(authProvider),
          );
        },
      ),
    );
  }

  Widget _buildHome(AuthProvider authProvider) {
    if (authProvider.isLoading) {
      return const SplashScreen(); // Show loading while authentication is in progress
    }
    if (authProvider.isAuthenticated) {
      return const RoleBasedScreen();
    } else {
      return const LoginScreen();
    }
  }
}

class RoleBasedScreen extends StatelessWidget {
  const RoleBasedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.role) {
      case 'manager':
        return const HomeScreen();
      case 'foodProvider':
        return const OrderScreen();
      case 'Chef':
        return const ItemScreen();
      default:
        return const LoginScreen();
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
