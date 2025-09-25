import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _circleScaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 720),
      vsync: this,
    )..forward();

    // Icon scales down from 1 → 0.15
    _scaleAnimation = Tween<double>(begin: 1.1, end: 0.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Circle scales slightly bigger at end (0.15 → 0.3)
    _circleScaleAnimation = Tween<double>(begin: 0.12, end: 0.24).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
    );

    // Navigate to home after 2s
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final iconPath = brightness == Brightness.dark
        ? 'assets/chatgpt_dark.png'
        : 'assets/chatgpt_light.png';
    final circleColor = brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: brightness == Brightness.dark ? Colors.black : Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double scale = _scaleAnimation.value;

            // Use circleScaleAnimation when icon is tiny
            double displayScale = scale <= 0.2 ? _circleScaleAnimation.value : scale;

            return Transform.rotate(
              angle: _controller.value * 3.14, // speed
              child: ClipOval(
                child: Container(
                  width: 120 * displayScale,
                  height: 120 * displayScale,
                  color: scale <= 0.2 ? circleColor : null,
                  child: scale > 0.2
                      ? Image.asset(iconPath, fit: BoxFit.contain)
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
