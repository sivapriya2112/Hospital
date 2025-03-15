import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/api_endpoints.dart';

class GetDoctorsProvider with ChangeNotifier {
  List<Map<String, String>> doctors = [];
  List<Map<String, String>> filteredDoctors = [];
  bool isLoading = true;

  Future<Map<String, String>> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String hospitalId = prefs.getString('hospitalId') ?? '';
    return {
      'token': token,
      'hospitalId': hospitalId,
    };
  }

  Future<void> fetchDoctors() async {
    try {
      Map<String, String> preferences = await getPreferences();
      String token = preferences['token']!;
      String hospitalId = preferences['hospitalId']!;

      // Use the endpoint from ApiEndPoints
      final uri = Uri.parse(ApiEndpoints.getDoctors);
      final headers = {
        'Content-Type': 'application/json',
        'token': token,
      };

      final body = json.encode({
        'hospitalId': hospitalId,
      });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          doctors = data.map<Map<String, String>>((doctor) {
            return {
              'name': doctor['name'] ?? '',
              'specialization': doctor['specialization'] ?? '',
              'email': doctor['email'] ?? '',
              'phone': doctor['phone'] ?? '',
            };
          }).toList();
          filteredDoctors = doctors; // Initialize with all doctors
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load doctors: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching doctors: $error');
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load doctors');
    }
  }

  void filterDoctors(String query) {
    query = query.toLowerCase();
    setState(() {
      filteredDoctors = doctors.where((doctor) {
        return doctor['name']!.toLowerCase().contains(query) ||
            doctor['specialization']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Helper method to update state (similar to setState in StatefulWidget)
  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }
}
