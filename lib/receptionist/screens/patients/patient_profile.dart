// screens/update_patient_profile.dart
import 'package:flutter/material.dart';
import '../doctors/get_doctors.dart';
import 'update_patient_dialog.dart';

class PatientEditScreen extends StatelessWidget {
  final String name;
  final String email;
  final String phoneNo;
  final String patientId;
  final String objectId;
  final int age;

  const PatientEditScreen({
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
                        EditProfileDialog.show(
                          context: context,
                          name: name,
                          email: email,
                          phoneNo: phoneNo,
                          patientId: patientId,
                          objectId: objectId,
                          age: age,
                        );
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
              buildOptionButton("Appointments", context, name, email, phoneNo,
                  patientId.toString(), objectId, age.toString()),
              buildOptionButton("Diagnostics", context, name, email, phoneNo,
                  patientId.toString(), objectId, age.toString()),
              buildOptionButton("Bill Details", context, name, email, phoneNo,
                  patientId.toString(), objectId, age.toString()),
              buildOptionButton("EMR", context, name, email, phoneNo,
                  patientId.toString(), objectId, age.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOptionButton(
    String text,
    BuildContext context,
    String name,
    String email,
    String phoneNo,
    String patientId,
    String objectId,
    String age,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          if (text == "Appointments") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GetDoctorsScreen(),
              ),
            );
          }
        },
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
}
