import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/species_screen.dart';
import 'screens/county_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FishSurveysApp(),
    ),
  );
}

class FishSurveysApp extends StatelessWidget {
  const FishSurveysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Surveys',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
} 