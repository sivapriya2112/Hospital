import 'package:flutter/material.dart';
import 'package:hospital/colors/appcolors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'RecepAppointments.dart';
import 'RecepPatients.dart';

class ReceptionistDashboard extends StatefulWidget {
  @override
  _ReceptionistDashboardState createState() => _ReceptionistDashboardState();
}

class _ReceptionistDashboardState extends State<ReceptionistDashboard> {
  final String apiUrl =
      'https://hospital-fitq.onrender.com/receptionist/profile/get';

  Future<Map<String, dynamic>> fetchProfileData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('Id');

      if (token == null || id == null) {
        print('Error: Token or Hospital ID not found.');
        return {};
      }

      // Debugging logs
      print('Fetching Profile Data from: $apiUrl');
      print('Using Hospital ID: $id');
      print('Using Token: $token');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'token': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({'id': id}), // Send ID in body
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load profile data: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      return {};
    }
  }

  final List<Map<String, dynamic>> dashboardItems = [
    {'icon': Icons.person, 'label': 'Patients'},
    {'icon': Icons.medical_services, 'label': 'Diagnostics'},
    {'icon': Icons.event, 'label': 'Appointments'},
    {'icon': Icons.receipt, 'label': 'Bill Details'},
    {'icon': Icons.folder_shared, 'label': 'EMR'},
  ];

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Receptionist Dashboard',
          style: TextStyle(
            fontFamily: 'Nunito',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {},
          ),
        ],
        toolbarHeight: 70,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            // Profile Card with API Data
            FutureBuilder<Map<String, dynamic>>(
              future: fetchProfileData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No profile data available');
                }

                var profileData = snapshot.data!;
                // Get the first letter of the name
                String firstLetter = profileData['name'] != null &&
                        profileData['name'].isNotEmpty
                    ? profileData['name'][0].toUpperCase()
                    : 'N'; // Default to 'N' if name is empty or null

                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          firstLetter, // Show first letter of name
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito', // Font family Nunito
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profileData['name'] ?? 'No Name',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: blackColor,
                              fontFamily:
                                  'Nunito', // Font family Nunito for name
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Email: ${profileData['email'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: blackColor,
                              fontFamily:
                                  'Nunito', // Font family Nunito for email
                            ),
                          ),
                          Text(
                            'Mobile: ${profileData['phone'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: blackColor,
                              fontFamily:
                                  'Nunito', // Font family Nunito for phone
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 30),
            // Dashboard Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.3,
                ),
                itemCount: dashboardItems.length,
                itemBuilder: (context, index) {
                  final item = dashboardItems[index];
                  return GestureDetector(
                    onTap: () {
                      if (item['label'] == 'Patients') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RecepPatients()),
                        );
                      } else if (item['label'] == 'Appointments') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RecepAppointments()),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF193482), Color(0xFF1D4AB5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'],
                            color: Colors.white,
                            size: 36,
                          ),
                          SizedBox(height: 8),
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
