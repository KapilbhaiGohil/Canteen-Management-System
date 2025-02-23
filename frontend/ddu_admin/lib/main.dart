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
        ChangeNotifierProvider(
            create: (context) => AuthProvider()..tryAutoLogin()),
        ChangeNotifierProvider(create: (context) => CanteenProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAuthenticated) {
            switch (authProvider.role) {
              case 'manager':
                return const MaterialApp(
                    title: 'Canteen App', home: HomeScreen());
              case 'foodProvider':
                return const MaterialApp(
                    title: 'Canteen App', home: OrderScreen());
              case 'Chef':
                return const MaterialApp(
                    title: 'Canteen App', home: ItemScreen());
              default:
                return const MaterialApp(home: SplashScreen());
            }
          }
          if (!authProvider.isAuthenticated) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: LoginScreen(),
            );
          }
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
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
        child: CircularProgressIndicator(
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
