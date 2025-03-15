import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants/api_endpoints.dart';

class PatientAppointmentProvider with ChangeNotifier {
  List<dynamic> appointments = [];
  bool isLoading = true;
  List<dynamic> filteredAppointments = [];

  Future<void> fetchAppointments() async {
    print("fetchAppointments called");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hospitalId = prefs.getString('hospitalId');
    String? token = prefs.getString('token');

    if (hospitalId == null || token == null) {
      isLoading = false;
      notifyListeners();
      print("Hospital ID or Token is null");
      return;
    }

    // Use the endpoint from ApiEndPoints
    final url = Uri.parse(ApiEndpoints.getAppointments);
    final response = await http.post(
      url,
      headers: {
        'token': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"hospitalId": hospitalId}),
    );

    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      appointments = jsonDecode(response.body);
      filteredAppointments = List.from(appointments);
      isLoading = false;
      notifyListeners();
    } else {
      print("Error: ${response.statusCode}, ${response.body}");
      isLoading = false;
      notifyListeners();
    }
  }

  void filterAppointments(String query) {
    filteredAppointments = appointments.where((appointment) {
      String patientName =
          "${appointment['patientInfo']?['patientFirstName'] ?? ''} ${appointment['patientInfo']?['patientLastName'] ?? ''}"
              .toLowerCase();
      String uhid = appointment['patientInfo']?['uhid'] ?? '';
      return patientName.contains(query.toLowerCase()) || uhid.contains(query);
    }).toList();
    notifyListeners();
  }
}
