import 'package:flutter/material.dart';

import '../colors/appcolors.dart';
import 'Onboarding.dart'; // Import color constants

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigate to the next screen after the animation
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OnboardingScreen()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor, // Using your custom primary color
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Text(
            "HMS",
            style: TextStyle(
              fontSize: 30, // Reduced font size
              fontWeight: FontWeight.bold,
              color: white, // Using your custom white color
            ),
          ),
        ),
      ),
    );
  }
}
