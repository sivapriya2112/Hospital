import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../constants/api_endpoints.dart';

class AddBillsProvider with ChangeNotifier {
  Future<void> addBill({
    required String patientId,
    required String subject,
    required String amount,
    required VoidCallback onSuccess,
    required BuildContext context,
  }) async {
    if (subject.trim().isEmpty || amount.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Error: Subject and Amount are required",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? hospitalId = prefs.getString("hospitalId");
    String? token = prefs.getString("token");

    if (hospitalId == null) {
      Fluttertoast.showToast(
        msg: "Error: Hospital ID not found",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // Use the endpoint from ApiEndPoints
    final Uri apiUrl = Uri.parse(ApiEndpoints.addBills);

    final Map<String, dynamic> requestBody = {
      "patientId": patientId,
      "hospitalId": hospitalId,
      "bill": [
        {
          "subject": subject,
          "amount": amount,
          "paid": true,
        }
      ]
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
          "token": token ?? "",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Bill added successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        onSuccess();
        notifyListeners();
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
          msg: "Failed to add bill: ${response.body}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
