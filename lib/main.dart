import 'package:flutter/material.dart';
import 'package:hospital/receptionist/providers/doctors/get_doctors.dart';
import 'package:hospital/receptionist/providers/patients/appointments/patient_appointments.dart';
import 'package:hospital/receptionist/providers/patients/bills/add_bills.dart';
import 'package:hospital/receptionist/providers/patients/bills/get_all_bills.dart';
import 'package:hospital/receptionist/providers/patients/bills/update_bills.dart';
import 'package:hospital/receptionist/providers/patients/update_patient_profile.dart';
import 'package:hospital/receptionist/providers/patients/get_all_patients.dart';
import 'package:hospital/receptionist/providers/receptionist/profile.dart';
import 'package:hospital/startup_screens/Splash.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'colors/appcolors.dart'; // Import your AppColors file

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientEditProvider()),
        ChangeNotifierProvider(create: (_) => PatientsProvider()),
        ChangeNotifierProvider(create: (_) => RecepProfileProvider()),
        ChangeNotifierProvider(create: (_) => RecepBillsProvider()),
        ChangeNotifierProvider(create: (_) => EditBillsProvider()),
        ChangeNotifierProvider(create: (_) => AddBillsProvider()),
        ChangeNotifierProvider(create: (_) => PatientAppointmentProvider()),
        ChangeNotifierProvider(create: (_) => GetDoctorsProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HMS',
      color: primaryColor,
      home: SplashScreen(),
    );
  }
}
