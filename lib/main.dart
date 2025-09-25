import 'package:chatgpt_clone/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:chatgpt_clone/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT Clone',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // Auto switch light/dark
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(), // Replace with your main screen
      },
    );
  }
}

