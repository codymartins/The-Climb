import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const StartTheClimbApp());
}

class StartTheClimbApp extends StatelessWidget {
  const StartTheClimbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Start The Climb',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color.fromARGB(255, 160, 160, 160), // soft background
        primaryColor: const Color.fromARGB(255, 42, 46, 51), // deep navy blue
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 42, 46, 51),
          primary: const Color.fromARGB(255, 42, 46, 51),
          secondary: const Color.fromARGB(255, 42, 46, 51), // accent yellow
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          titleMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 42, 46, 51),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 42, 46, 51),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const MainScreen(phase: 1), // Use SharedPreferences if needed later
    );
  }
}
