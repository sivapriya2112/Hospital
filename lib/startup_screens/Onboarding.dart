import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_ui.dart';
import '../colors/appcolors.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int currentPage = 0;

  List<Widget> _buildPageIndicators() {
    return List<Widget>.generate(3, (int index) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        height: 10.0,
        width: 10.0, // Keep width constant for a circular appearance
        decoration: BoxDecoration(
          color: index == currentPage ? primaryColor : Colors.grey,
          shape: BoxShape.circle, // Ensure the shape is a circle
        ),
      );
    });
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'onboarding_completed', true); // Set onboarding complete flag
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => LoginPage()), // Navigate to login screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                currentPage = page;
              });
            },
            children: [
              OnboardingPage(
                imagePath: 'assets/images/onboarding1.png',
                title: 'Learn About Your Doctors',
                description:
                    'Explore detailed profiles of doctors, including their expertise, qualifications, and patient reviews, to make informed choices.',
              ),
              OnboardingPage(
                imagePath: 'assets/images/onboarding2.png',
                title: 'Effortless Appointment Booking',
                description:
                    'Book appointments quickly and easily with just a few taps, and manage your schedule seamlessly.',
              ),
              OnboardingPage(
                imagePath: 'assets/images/onboarding3.png',
                title: 'Discover Experienced Doctors',
                description:
                    'Find top-rated doctors in your area and connect with healthcare professionals you can trust.',
              ),
            ],
          ),
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                currentPage == 0
                    ? SizedBox.shrink()
                    : Container(
                        width: 45.0, // Adjust size of the circle
                        height: 45.0, // Adjust size of the circle
                        decoration: BoxDecoration(
                          color: Colors.transparent, // No fill color
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor, // Stroke color
                            width: 2.0, // Stroke width
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: primaryColor),
                          onPressed: () {
                            _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease);
                          },
                        ),
                      ),
                Row(
                  children: _buildPageIndicators(),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: primaryColor, // Filled background color
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () {
                      if (currentPage < 2) {
                        _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease);
                      } else {
                        // Complete onboarding
                        _completeOnboarding(); // Call the method to complete onboarding
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50.0,
            right: 20.0,
            child: GestureDetector(
              onTap: () {
                if (currentPage < 2) {
                  // Move to the next page in the onboarding
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                } else {
                  // If it's the last page, complete onboarding
                  _completeOnboarding();
                }
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 300.0),
          SizedBox(height: 20.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontFamily: 'nunito', // Apply font here
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.0),
          Text(
            description,
            style: TextStyle(
              fontSize: 16.0,
              fontFamily: 'nunito', // Apply font here
              color: Colors.black54, // Comma added here
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
