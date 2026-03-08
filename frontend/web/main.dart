import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/admin_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Gallery',
      theme: ThemeData(
        primaryColor: const Color(0xFF6b28c9),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6b28c9)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/admin': (context) => const AdminPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}