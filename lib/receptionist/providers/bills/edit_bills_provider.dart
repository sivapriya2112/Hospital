import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../constants/api_endpoints.dart';

class EditBillsProvider with ChangeNotifier {
  Future<bool> submitPayment(
      String billingId, double enteredAmount, double currentPaid) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print('Error: Missing authentication token');
        return false;
      }

      if (billingId.isEmpty) {
        print('Error: Missing Billing ID');
        return false;
      }

      // Calculate new total paid amount
      double newTotalPaid = currentPaid + enteredAmount;

      // Send updated paid amount to backend
      final response = await http.put(
        Uri.parse(ApiEndpoints.editBills),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: json.encode({
          'id': billingId,
          'amount': newTotalPaid, // Sending new total paid amount
        }),
      );

      if (response.statusCode == 200) {
        print('Payment updated successfully');

        Fluttertoast.showToast(
          msg: "Payment updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        notifyListeners();

        return true;
      } else {
        print('Failed to update payment: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting payment: $e');
      return false;
    }
  }
}
