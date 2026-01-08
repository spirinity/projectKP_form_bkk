import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/inspection_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InspectionProvider()),
      ],
      child: MaterialApp(
        title: 'Karantina Kesehatan Balikpapan',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF005c4b)), // Greenish medical/safety
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
