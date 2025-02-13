import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FishSurveysApp());
}

class FishSurveysApp extends StatelessWidget {
  const FishSurveysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Surveys',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
} 