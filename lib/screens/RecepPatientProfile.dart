import 'dart:convert'; // For JSON encoding
import 'package:flutter/material.dart';
import 'package:hospital/colors/appcolors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RecepPatientProfile extends StatelessWidget {
  final String name;
  final String email;
  final String phoneNo;
  final String patientId;
  final String objectId;
  final int age;

  const RecepPatientProfile({
    Key? key,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.objectId,
    required this.patientId,
    required this.age,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          'Patient Profile',
          style: TextStyle(fontFamily: 'Nunito', color: Colors.white),
        ),
        backgroundColor: const Color(0xFF193482),
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 70.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        patientId,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Email : $email",
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            color: Colors.black)),
                    const SizedBox(height: 10),
                    Text("Mobile : $phoneNo",
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            color: Colors.black)),
                    const SizedBox(height: 10),
                    Text("Age : $age",
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            color: Colors.black)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showEditDialog(context);
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text("Edit Profile",
                          style: TextStyle(fontFamily: 'Nunito')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF193482),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              buildOptionButton("Appointments"),
              buildOptionButton("Diagnostics"),
              buildOptionButton("Bill Details"),
              buildOptionButton("EMR"),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController firstNameController =
        TextEditingController(text: name.split(" ")[0]);
    final TextEditingController lastNameController = TextEditingController(
        text: name.split(" ").length > 1 ? name.split(" ")[1] : "");
    final TextEditingController emailController =
        TextEditingController(text: email);
    final TextEditingController phoneController =
        TextEditingController(text: phoneNo);
    final TextEditingController ageController =
        TextEditingController(text: age.toString());

    void _showToast(
        BuildContext context, String message, Color backgroundColor) {
      final overlay =
          Overlay.of(context, rootOverlay: true); // Use root overlay
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top:
              100, // Position the toast 50 pixels from the bottom of the screen
          left: MediaQuery.of(context).size.width * 0.2,
          right: MediaQuery.of(context).size.width * 0.2,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );

      overlay?.insert(overlayEntry); // Show the overlay
      Future.delayed(const Duration(seconds: 2), () {
        overlayEntry.remove(); // Remove the toast after 2 seconds
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.fromLTRB(20, 95, 20, 30), // Set margins
          child: Container(
            padding: const EdgeInsets.all(16.0), // Padding inside the dialog
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: firstNameController,
                          style: const TextStyle(fontFamily: 'Nunito'),
                          decoration: const InputDecoration(
                            labelText: "First Name",
                            labelStyle: TextStyle(fontFamily: 'Nunito'),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: lastNameController,
                          style: const TextStyle(fontFamily: 'Nunito'),
                          decoration: const InputDecoration(
                            labelText: "Last Name",
                            labelStyle: TextStyle(fontFamily: 'Nunito'),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: emailController,
                          style: const TextStyle(fontFamily: 'Nunito'),
                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(fontFamily: 'Nunito'),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: phoneController,
                          style: const TextStyle(fontFamily: 'Nunito'),
                          decoration: const InputDecoration(
                            labelText: "Mobile Number",
                            labelStyle: TextStyle(fontFamily: 'Nunito'),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: ageController,
                          style: const TextStyle(fontFamily: 'Nunito'),
                          decoration: const InputDecoration(
                            labelText: "Age",
                            labelStyle: TextStyle(fontFamily: 'Nunito'),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryColor),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                            fontFamily: 'Nunito', color: primaryColor),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final updatedData = {
                          "patientFirstName": firstNameController.text,
                          "patientLastName": lastNameController.text,
                          "patientEmail": emailController.text,
                          "phoneno": phoneController.text,
                          "patientAge": int.parse(ageController.text),
                        };

                        final response = await editPatient(updatedData);

                        if (response) {
                          _showToast(context, "Profile updated successfully",
                              Colors.green);

                          // Close the dialog
                          Navigator.pop(context);
                        } else {
                          _showToast(
                              context, "Failed to update profile", Colors.red);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF193482),
                      ),
                      child: const Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> editPatient(Map<String, dynamic> patientbasicInfos) async {
    const String baseUrl = "https://hospital-fitq.onrender.com";
    final String url = "$baseUrl/patients/edit";

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("token");

      if (token == null) {
        print("Token not found. User might be logged out.");
        return false;
      }

      print("id: $objectId");

      // Add the _id to the patient data if it's not already included
      if (!patientbasicInfos.containsKey('_id')) {
        patientbasicInfos['_id'] = objectId;
      }
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "token": token,
        },
        body: jsonEncode(patientbasicInfos),
      );

      print("Request Body: ${jsonEncode(patientbasicInfos)}");

      final responseData = jsonDecode(response.body);
      print("Response Data: $responseData");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Patient updated successfully: ${responseData['message']}");
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        print("Error updating patient: ${responseData['message']}");
        return false;
      }
    } catch (error) {
      print("Error: $error");
      return false;
    }
  }
}

Widget buildOptionButton(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF193482),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text,
              style: const TextStyle(fontSize: 18, fontFamily: 'Nunito')),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
        ],
      ),
    ),
  );
}
