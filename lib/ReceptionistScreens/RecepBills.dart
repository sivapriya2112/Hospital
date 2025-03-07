import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../colors/appcolors.dart';

class RecepBills extends StatefulWidget {
  @override
  _RecepBillsState createState() => _RecepBillsState();
}

class _RecepBillsState extends State<RecepBills> {
  int? expandedIndex;
  List<Map<String, dynamic>> bills = [];
  List<Map<String, dynamic>> patients = [];
  String searchInput = "";
  List<dynamic> filteredPatients = [];
  bool isLoading = true; // To track API loading state

  @override
  void initState() {
    super.initState();
    fetchPatients().then((_) {
      if (patients.isNotEmpty) {
        filteredPatients = List.from(patients); // Initialize filteredPatients
        fetchBills(patients[0]["_id"]); // Fetch bills for the first patient
      }
    });
  }

  Future<void> fetchPatients() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? hospitalId = prefs.getString('hospitalId');

      final response = await http.post(
        Uri.parse('https://hospital-fitq.onrender.com/patients/getall'),
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
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? hospitalId = prefs.getString('hospitalId');

      final response = await http.post(
        Uri.parse('https://hospital-fitq.onrender.com/billing/get'),
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
                      .contains(input.toLowerCase());
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAEFF6),
      appBar: AppBar(
        backgroundColor: Color(0xFF153A7C),
        title: Text(
          "Billing",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: TextField(
                onChanged: search,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: "Search Patients",
                  hintStyle: TextStyle(fontFamily: 'Nunito'),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),

            // Patient List or Loading Indicator
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator()) // Show loader
                  : patients.isEmpty
                      ? Center(
                          child: Text(
                            "No patients found",
                            style:
                                TextStyle(fontFamily: 'Nunito', fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredPatients.length,
                          itemBuilder: (context, index) {
                            bool isExpanded = expandedIndex == index;
                            var patient =
                                filteredPatients[index]; // Use filtered list
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        expandedIndex = null;
                                        bills = []; // Clear previous bills
                                      } else {
                                        expandedIndex = index;
                                        fetchBills(patient["_id"]);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    margin: EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.grey.shade400,
                                          radius: 24,
                                          child: Text(
                                            (patient["patientFirstName"] ??
                                                    "N/A")
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: 'Nunito',
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${patient['patientFirstName'] ?? ''} ${patient['patientLastName'] ?? ''}'
                                                    .trim(),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'Nunito',
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                patient["uhid"] ?? "N/A",
                                                style: TextStyle(
                                                  fontFamily: 'Nunito',
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Visibility(
                                                visible: false,
                                                child: Text(
                                                  patient["_id"] ?? "N/A",
                                                  style: TextStyle(
                                                    fontFamily: 'Nunito',
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          isExpanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Billing details section
                                if (isExpanded)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    margin: EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: bills.isEmpty
                                        ? Text(
                                            "No billing records found",
                                            style:
                                                TextStyle(fontFamily: 'Nunito'),
                                          )
                                        : Column(
                                            children: [
                                              ...bills.map((bill) {
                                                var billData =
                                                    bill["bill"] ?? {};

                                                double totalAmount =
                                                    double.tryParse(
                                                            billData["amount"]
                                                                .toString()) ??
                                                        0.0;
                                                double paidAmount =
                                                    double.tryParse(
                                                            billData["paid"]
                                                                .toString()) ??
                                                        0.0;
                                                double dueAmount =
                                                    totalAmount - paidAmount;

                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _infoText(
                                                        "Subject",
                                                        billData["subject"]
                                                                ?.toString() ??
                                                            "N/A"),
                                                    _infoText("Total Amount",
                                                        "₹${totalAmount.toStringAsFixed(2)}"),
                                                    _infoText("Paid Amount",
                                                        "₹${paidAmount.toStringAsFixed(2)}"),
                                                    _infoText("Due Amount",
                                                        "₹${dueAmount.toStringAsFixed(2)}"),
                                                    _infoText(
                                                        "Date",
                                                        bill["createdAt"]
                                                                ?.toString() ??
                                                            "N/A"),
                                                    SizedBox(height: 8),
                                                  ],
                                                );
                                              }).toList(),
                                              SizedBox(height: 8),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Color(0xFF153A7C),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                  ),
                                                  onPressed: () {},
                                                  child: Text(
                                                    "Edit",
                                                    style: TextStyle(
                                                      fontFamily: 'Nunito',
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

// Helper function for displaying bill details
  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
