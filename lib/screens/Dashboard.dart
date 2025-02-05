import 'package:flutter/material.dart';

import '../colors/appcolors.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0; // Track the selected index for the bottom navigation

  // List of pages to navigate to
  final List<Widget> _pages = [
    PatientList(),
    AppointmentsScreen(),
  ];

  // Function to handle bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Icon for Patients
            label: 'Patients', // Label updated to Patients
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), // Icon for Appointments
            label: 'Appointments', // Label for Appointments
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
            primaryColor, // Use your primary color for selected item
        onTap: _onItemTapped, // Handle taps on the navigation items
      ),
    );
  }
}

class PatientList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Your Patients will be listed here.',
        style: TextStyle(fontSize: 24, fontFamily: 'nunito'),
      ),
    );
  }
}

// Example Appointments Screen
class AppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Your Appointments will be listed here.',
        style: TextStyle(fontSize: 24, fontFamily: 'nunito'),
      ),
    );
  }
}
