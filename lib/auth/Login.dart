import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import for HTTP requests
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import '../DoctorScreens/Dashboard.dart';
import '../ReceptionistScreens/ReceptionistDashboard.dart';
import '../colors/appcolors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? selectedRole;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late SharedPreferences prefs;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var reqBody = {
        "email": emailController.text,
        "password": passwordController.text,
      };

      // Log request details to the console
      print("Request Body: ${jsonEncode(reqBody)}");

      // Determine the API URL based on the selected role
      String apiUrl = "";

      // Check the selected role and assign the corresponding API URL
      if (selectedRole == 'Doctor') {
        apiUrl = "https://hospital-fitq.onrender.com/doctor/login";
      } else if (selectedRole == 'Receptionist') {
        apiUrl = "https://hospital-fitq.onrender.com/receptionist/login";
      } else {
        // Handle the case when no role is selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a role')),
        );
        return;
      }

      // Send request to the selected URL
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      // Log response details to the console
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['token'] != null) {
          var myToken = jsonResponse['token'];
          var hospitalId = jsonResponse[
              'hospitalId']; // Assuming 'hospitalId' is the key in the JSON response
          var Id =
              jsonResponse['Id']; // Assuming 'objectId' is the key for ObjectId

          // Save token and hospital ID locally
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', myToken);
          prefs.setString('hospitalId', hospitalId); // Store hospital ID
          prefs.setString('Id', Id); // Store ObjectId

          // Navigate based on the adminType
          if (jsonResponse['adminType'] == 'Doctor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          } else if (jsonResponse['adminType'] == 'Receptionist') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ReceptionistDashboard()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Access denied: Invalid admin type')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: Invalid credentials')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: Invalid credentials')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor, // Use the primary color for the background
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sign In Title
                Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'nunito',
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set color to white
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "Sign in to manage appointments and access your health records",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'nunito',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40.0),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30.0, horizontal: 18.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dropdown for Select Role
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelText: 'Select a Role',
                            labelStyle: TextStyle(
                              fontFamily: 'nunito', // Apply the fontFamily here
                            ),
                          ),
                          items: ['Doctor', 'Receptionist']
                              .map((role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(
                                      role,
                                      style: TextStyle(
                                        fontFamily:
                                            'nunito', // Apply nunito font
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16.0),
                        // Email Field
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              fontFamily: 'nunito', // Apply the fontFamily here
                            ),
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16.0),
                        // Password Field
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontFamily: 'nunito', // Apply the fontFamily here
                            ),
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                        ),

                        const SizedBox(height: 24.0),
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              loginUser(); // Call the login function
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'nunito',
                                fontWeight: FontWeight.bold,
                                color: white, // Use the custom white color
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
