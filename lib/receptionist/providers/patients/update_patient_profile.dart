// providers/update_patient_profile.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/api_endpoints.dart';

class PatientEditProvider with ChangeNotifier {
  Future<bool> editPatient(
      Map<String, dynamic> patientBasicInfos, String objectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("token");

      if (token == null) {
        print("Token not found. User might be logged out.");
        return false;
      }

      print("id: $objectId");

      if (!patientBasicInfos.containsKey('_id')) {
        patientBasicInfos['_id'] = objectId;
      }

      final response = await http.put(
        Uri.parse(ApiEndpoints.editPatient),
        headers: {
          "Content-Type": "application/json",
          "token": token,
        },
        body: jsonEncode(patientBasicInfos),
      );

      print("Request Body: ${jsonEncode(patientBasicInfos)}");

      final responseData = jsonDecode(response.body);
      print("Response Data: $responseData");

      if (response.statusCode == 200) {
        print("Patient updated successfully: ${responseData['message']}");
        return true;
      } else {
        print("Error updating patient: ${responseData['message']}");
        return false;
      }
    } catch (error) {
      print("Error: $error");
      return false;
    }
  }
}
