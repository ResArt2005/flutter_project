import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('О сайте'),
      ),
      body: const Center(
        child: Text(
          'Этот сайт создан с использованием Flutter и PostgreSQL.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}