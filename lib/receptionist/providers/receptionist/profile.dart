import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/api_endpoints.dart';

class RecepProfileProvider with ChangeNotifier {
  Map<String, dynamic> _profileData = {};
  bool _isLoading = false;

  Map<String, dynamic> get profileData => _profileData;
  bool get isLoading => _isLoading;

  Future<void> fetchProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('Id');

      if (token == null || id == null) {
        print('Error: Token or Receptionist ID not found.');
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.profileGet),
        headers: {
          'token': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({'id': id}),
      );

      if (response.statusCode == 200) {
        _profileData = json.decode(response.body);
      } else {
        print('Failed to load profile data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
