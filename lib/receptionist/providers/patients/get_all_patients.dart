import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/api_endpoints.dart';

class PatientsProvider with ChangeNotifier {
  List<dynamic> _patientDetails = [];
  List<dynamic> _filteredPatients = [];
  String _searchInput = "";
  int _visibleCount = 10;
  bool _isLoading = true;
  int _inpatientCount = 0;
  int _outpatientCount = 0;
  int _totalAppointmentsCount = 0;

  List<dynamic> get patientDetails => _patientDetails;
  List<dynamic> get filteredPatients => _filteredPatients;
  String get searchInput => _searchInput;
  int get visibleCount => _visibleCount;
  bool get isLoading => _isLoading;
  int get inpatientCount => _inpatientCount;
  int get outpatientCount => _outpatientCount;
  int get totalAppointmentsCount => _totalAppointmentsCount;

  Future<void> fetchPatients() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? hospitalId = prefs.getString('hospitalId');

      final response = await http.post(
        Uri.parse(ApiEndpoints.getAllPatients), // Use the constant here
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
        body: json.encode({'hospitalId': hospitalId ?? ''}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _patientDetails = data;
        _filteredPatients = data;
      } else {
        _patientDetails = [];
        _filteredPatients = [];
        print('Failed to load patients: ${response.statusCode}');
      }
    } catch (e) {
      _patientDetails = [];
      _filteredPatients = [];
      print('Error fetching patients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAppointmentCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _inpatientCount = prefs.getInt('inpatientCount') ?? 0;
    _outpatientCount = prefs.getInt('outpatientCount') ?? 0;
    _totalAppointmentsCount = prefs.getInt('totalAppointmentsCount') ?? 0;
    notifyListeners();
  }

  void search(String input) {
    _searchInput = input;
    _filteredPatients = input.isEmpty
        ? _patientDetails
        : _patientDetails.where((patient) {
            return (patient['patientEmail'] ?? '')
                    .toLowerCase()
                    .contains(input.toLowerCase()) ||
                (patient['patientLastName'] ?? '').toString().contains(input) ||
                (patient['patientFirstName'] ?? '').toString().contains(input);
          }).toList();
    notifyListeners();
  }

  void loadMorePatients() {
    _visibleCount += 10;
    notifyListeners();
  }
}
