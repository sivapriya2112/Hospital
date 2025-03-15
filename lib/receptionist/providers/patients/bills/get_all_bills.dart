// providers/get_all_bills.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../constants/api_endpoints.dart';

class RecepBillsProvider with ChangeNotifier {
  List<Map<String, dynamic>> bills = [];
  List<Map<String, dynamic>> patients = [];
  String searchInput = "";
  List<dynamic> filteredPatients = [];
  bool isLoading = true;

  Future<void> fetchPatients() async {
    setStateLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? hospitalId = prefs.getString('hospitalId');

      // Use the endpoint from ApiEndPoints
      final response = await http.post(
        Uri.parse(ApiEndpoints.getAllPatients),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
        body: json.encode({'hospitalId': hospitalId ?? ''}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          patients = List<Map<String, dynamic>>.from(data);
          filteredPatients = List.from(patients);
          isLoading = false;
        });
      } else {
        setState(() {
          patients = [];
          isLoading = false;
        });
        print('Failed to load patients: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        patients = [];
        isLoading = false;
      });
      print('Error fetching patients: $e');
    }
  }

  Future<void> fetchBills(String patientId) async {
    setStateLoading(true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? hospitalId = prefs.getString('hospitalId');

      final response = await http.post(
        Uri.parse(ApiEndpoints.getBills),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
        body: json.encode({
          'hospitalId': hospitalId ?? '',
          'patientId': patientId,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          bills = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          bills = [];
          isLoading = false;
        });
        print('Failed to load bills: ${response.body}');
      }
    } catch (e) {
      setState(() {
        bills = [];
        isLoading = false;
      });
      print('Error fetching bills: $e');
    }
  }

  void search(String input) {
    setState(() {
      searchInput = input;
      filteredPatients = input.isEmpty
          ? patients
          : patients.where((patient) {
              return (patient['patientLastName'] ?? '')
                      .toLowerCase()
                      .contains(input.toLowerCase()) ||
                  (patient['patientFirstName'] ?? '')
                      .toLowerCase()
                      .contains(input.toLowerCase()) ||
                  (patient['uhid']?.toString() ?? '')
                      .toLowerCase()
                      .contains(input.toLowerCase());
            }).toList();
    });
  }

  void setStateLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void setState(VoidCallback callback) {
    callback();
    notifyListeners();
  }
}
