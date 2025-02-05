import 'package:flutter/material.dart';
import 'package:hospital/screens/Splash.dart';
import 'colors/appcolors.dart'; // Import your AppColors file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      title: 'HMS',
      color: primaryColor,
      home: SplashScreen(), // Start with the Splash screen
    );
  }
}
