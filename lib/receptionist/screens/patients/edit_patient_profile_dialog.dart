// screens/edit_profile_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospital/receptionist/screens/patients/patient_edit_screen.dart';
import 'package:provider/provider.dart';

import '../../../colors/appcolors.dart';
import '../../providers/patients/patient_edit_provider.dart';

class EditProfileDialog {
  static void show({
    required BuildContext context,
    required String name,
    required String email,
    required String phoneNo,
    required String patientId,
    required String objectId,
    required int age,
  }) {
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

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    void _showToast(
        BuildContext context, String message, Color backgroundColor) {
      final overlay =
          Overlay.of(context, rootOverlay: true); // Use root overlay
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 100,
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
          insetPadding: const EdgeInsets.fromLTRB(20, 95, 20, 30),
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(16.0),
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
                          TextFormField(
                            controller: firstNameController,
                            style: const TextStyle(fontFamily: 'Nunito'),
                            decoration: const InputDecoration(
                              labelText: "First Name",
                              labelStyle: TextStyle(
                                  fontFamily: 'Nunito', color: primaryColor),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                            maxLength: 20, // Max 20 characters
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'First Name is required';
                              } else if (value.length > 20) {
                                return 'First Name cannot exceed 20 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: lastNameController,
                            style: const TextStyle(fontFamily: 'Nunito'),
                            decoration: const InputDecoration(
                              labelText: "Last Name",
                              labelStyle: TextStyle(
                                  fontFamily: 'Nunito', color: primaryColor),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                            maxLength: 20,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Last Name is required';
                              } else if (value.length > 20) {
                                return 'Last Name cannot exceed 20 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: emailController,
                            style: const TextStyle(fontFamily: 'Nunito'),
                            decoration: const InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(
                                  fontFamily: 'Nunito', color: primaryColor),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                            maxLength: 30, // Max 50 characters for email
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              } else if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: phoneController,
                            style: const TextStyle(fontFamily: 'Nunito'),
                            decoration: const InputDecoration(
                              labelText: "Mobile Number",
                              labelStyle: TextStyle(
                                  fontFamily: 'Nunito', color: primaryColor),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            maxLength: 10, // Max 10 digits
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly, // Only numbers allowed
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mobile Number is required';
                              } else if (value.length != 10 ||
                                  !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                return 'Enter a valid 10-digit mobile number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: ageController,
                            style: const TextStyle(fontFamily: 'Nunito'),
                            decoration: const InputDecoration(
                              labelText: "Age",
                              labelStyle: TextStyle(
                                  fontFamily: 'Nunito', color: primaryColor),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 3, // Max 3 characters
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly, // Only numbers allowed
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Age is required';
                              } else if (value.length > 3) {
                                return 'Age cannot exceed 3 characters';
                              } else if (int.tryParse(value) == null) {
                                return 'Enter a valid age';
                              }
                              return null;
                            },
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
                          if (_formKey.currentState!.validate()) {
                            final updatedData = {
                              "patientFirstName": firstNameController.text,
                              "patientLastName": lastNameController.text,
                              "patientEmail": emailController.text,
                              "phoneno": phoneController.text,
                              "patientAge": int.parse(ageController.text),
                            };

                            final patientEditProvider =
                                Provider.of<PatientEditProvider>(context,
                                    listen: false);
                            final response = await patientEditProvider
                                .editPatient(updatedData, objectId);

                            if (response) {
                              _showToast(context,
                                  "Profile updated successfully", Colors.green);

                              // Close the dialog
                              Navigator.pop(context);

                              // Refresh the page by pushing a new instance of the same route
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PatientEditScreen(
                                    name:
                                        "${firstNameController.text} ${lastNameController.text}",
                                    email: emailController.text,
                                    phoneNo: phoneController.text,
                                    patientId: patientId,
                                    objectId: objectId,
                                    age: int.parse(ageController.text),
                                  ),
                                ),
                              );
                            } else {
                              _showToast(context, "Failed to update profile",
                                  Colors.red);
                            }
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
          ),
        );
      },
    );
  }
}
