import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FuelCalcApp());
}

class FuelCalcApp extends StatelessWidget {
  const FuelCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuel Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
