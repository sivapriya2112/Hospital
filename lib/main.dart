import 'package:flutter/material.dart';
import 'package:hospital/receptionist/providers/bills/add_bills_provider.dart';
import 'package:hospital/receptionist/providers/bills/edit_bills_provider.dart';
import 'package:hospital/receptionist/providers/patients/patient_edit_provider.dart';
import 'package:hospital/receptionist/providers/bills/recep_bills_provider.dart';
import 'package:hospital/receptionist/providers/patients/patients_provider.dart';
import 'package:hospital/receptionist/providers/receptionist/recep_profile_provider.dart';
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
