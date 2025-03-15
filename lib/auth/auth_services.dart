import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';

class AuthService {
  Future<SharedPreferences> initSharedPref() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> loginUser(String email, String password, String selectedRole,
      Function onSuccess, Function(String) onError) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      var reqBody = {
        "email": email,
        "password": password,
      };

      // Log request details to the console
      print("Request Body: ${jsonEncode(reqBody)}");

      // Determine the API URL based on the selected role
      String apiUrl = "";

      if (selectedRole == 'Doctor') {
        apiUrl = ApiEndpoints.doctorLogin;
      } else if (selectedRole == 'Receptionist') {
        apiUrl = ApiEndpoints.recepLogin;
      } else {
        onError('Please select a role');
        return;
      }

      // Send request to the selected URL
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      // Log response details to the console
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['token'] != null) {
          var myToken = jsonResponse['token'];
          var hospitalId = jsonResponse[
              'hospitalId']; // Assuming 'hospitalId' is the key in the JSON response
          var Id = jsonResponse['Id']; // Assuming 'Id' is the key for ObjectId

          // Save token and hospital ID locally
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', myToken);
          prefs.setString('hospitalId', hospitalId); // Store hospital ID
          prefs.setString('Id', Id); // Store ObjectId

          // Navigate based on the adminType
          onSuccess(jsonResponse['adminType']);
        } else {
          onError('Login failed: Invalid credentials');
        }
      } else {
        onError('Login failed: Invalid credentials');
      }
    } else {
      onError('Please fill in all fields');
    }
  }
}
