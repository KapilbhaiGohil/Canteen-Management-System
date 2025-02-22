import 'package:ddu_canteen/providers/authProvider.dart';
import 'package:ddu_canteen/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/canteenProvider.dart';
import 'providers/cartProvider.dart';

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
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..tryAutoLogin(),
        ),
        ChangeNotifierProvider(create: (context) => CanteenProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: SplashScreen(),
            );
          }
          if (authProvider.isServerDown) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: ServerDownScreen(),
            );
          }
          return MaterialApp(
            title: 'Canteen App',
            debugShowCheckedModeBanner: false,
            home: HomeScreen(),
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
        child: CircularProgressIndicator(color:Colors.blueAccent),
      ),
    );
  }
}

class ServerDownScreen extends StatelessWidget {
  const ServerDownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Server is currently unreachable. Please try again later.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
