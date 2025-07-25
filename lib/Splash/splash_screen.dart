import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:gpa_calculator/Home/homepage.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3000,
      splashIconSize: 250.0,
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Color(0xFF2d3748),
      splash: Lottie.asset(
        'assets/splash/splash.json',
      ),
      nextScreen: const HomePage(),
    );
  }
}
