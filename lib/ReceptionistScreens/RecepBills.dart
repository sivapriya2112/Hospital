import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../PopupDialogs/AddBillDialog.dart';
import '../PopupDialogs/EditPaymentDialog.dart';

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
                      .contains(input.toLowerCase()) ||
                  (patient['uhid']?.toString() ?? '')
                      .toLowerCase()
                      .contains(input.toLowerCase());
            }).toList();
    });
  }

  void navigateToPaymentTableScreen(
    BuildContext context,
    List<PaymentEntry> payments,
    String patientName,
    String patientId,
    String billingId,
    String patientEmail,
    String phoneNumber,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentTableScreen(
          payments: payments,
          patientName: patientName,
          patientId: patientId,
          billingId: billingId,
          patientEmail: patientEmail,
          phoneNumber: phoneNumber,
        ),
      ),
    );
  }

  void _showAddBillDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AddBillDialog(
        patientId: id,
        onBillAdded: () {
          fetchBills(id); // Refresh the bills instantly
        },
      ),
    );
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

            // Patient List
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
                                                  patient["patientEmail"] ??
                                                      "N/A",
                                                  style: TextStyle(
                                                    fontFamily: 'Nunito',
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: false,
                                                child: Text(
                                                  patient["phoneno"] ?? "N/A",
                                                  style: TextStyle(
                                                    fontFamily: 'Nunito',
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
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
                                        IconButton(
                                          icon: Icon(
                                            isExpanded
                                                ? Icons.add
                                                : Icons.expand_more,
                                            color: Colors.black,
                                          ),
                                          onPressed: isExpanded
                                              ? () {
                                                  _showAddBillDialog(patient[
                                                      "_id"]); // Pass bill id (patient id)
                                                }
                                              : null, // Disable button if not expanded
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                                            "No bill details added yet",
                                            style:
                                                TextStyle(fontFamily: 'Nunito'),
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Bill Details", // General title
                                                style: TextStyle(
                                                  fontFamily: 'Nunito',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 10),

                                              // Table Headers
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                      child: Text("Subject",
                                                          style: _boldStyle())),
                                                  Expanded(
                                                      child: Text("Total",
                                                          style: _boldStyle())),
                                                  Expanded(
                                                      child: Text("Paid",
                                                          style: _boldStyle())),
                                                  Visibility(
                                                    visible:
                                                        false, // Hides the "Due" column
                                                    child: Expanded(
                                                        child: Text("Due",
                                                            style:
                                                                _boldStyle())),
                                                  ),
                                                  Expanded(
                                                      child: Text("Status",
                                                          style: _boldStyle())),
                                                ],
                                              ),
                                              Divider(),

                                              // List of bills
                                              ...(bills.length > 2
                                                      ? bills.sublist(
                                                          bills.length - 2)
                                                      : bills)
                                                  .map((bill) {
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

                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          billData["subject"]
                                                                  ?.toString() ??
                                                              "N/A",
                                                          style: _valueStyle(),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "${totalAmount.toStringAsFixed(2)}",
                                                          style: _valueStyle(),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "${paidAmount.toStringAsFixed(2)}",
                                                          style: _valueStyle(),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            false, // Hides the "Due" value
                                                        child: Expanded(
                                                          child: Text(
                                                            "${dueAmount.toStringAsFixed(2)}",
                                                            style:
                                                                _valueStyle(),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "Yet To Pay",
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),

                                              SizedBox(height: 10),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (bills.isNotEmpty) {
                                                      double totalAmount = 0.0;
                                                      double totalPaidAmount =
                                                          0.0;

                                                      // Calculate total amount and total paid amount by summing up all bills
                                                      for (var bill in bills) {
                                                        var billData =
                                                            bill["bill"] ?? {};
                                                        totalAmount += double
                                                                .tryParse(billData[
                                                                        "amount"]
                                                                    .toString()) ??
                                                            0.0;
                                                        totalPaidAmount += double
                                                                .tryParse(billData[
                                                                        "paid"]
                                                                    .toString()) ??
                                                            0.0;
                                                      }

                                                      List<String> billIds = bills
                                                          .map((bill) =>
                                                              bill["_id"]
                                                                  ?.toString() ??
                                                              "")
                                                          .toList();

// Convert List<String> to a single string (comma-separated)
                                                      String billIdsString =
                                                          billIds.join(",");

                                                      navigateToPaymentTableScreen(
                                                        context,
                                                        bills.map<PaymentEntry>(
                                                            (bill) {
                                                          var billData =
                                                              bill["bill"] ??
                                                                  {};
                                                          return PaymentEntry(
                                                            id: bill["_id"] ??
                                                                "",
                                                            // Ensure each entry has an ID
                                                            subject: billData[
                                                                        "subject"]
                                                                    ?.toString() ??
                                                                "Unknown",
                                                            totalAmount: double.tryParse(
                                                                    billData["amount"]
                                                                            ?.toString() ??
                                                                        "0") ??
                                                                0,
                                                            paidAmount: double.tryParse(
                                                                    billData["paid"]
                                                                            ?.toString() ??
                                                                        "0") ??
                                                                0,
                                                            totalDue: (double.tryParse(
                                                                        billData["amount"]?.toString() ??
                                                                            "0") ??
                                                                    0) -
                                                                (double.tryParse(
                                                                        billData["paid"]?.toString() ??
                                                                            "0") ??
                                                                    0),
                                                          );
                                                        }).toList(),
                                                        "${patient['patientFirstName']} ${patient['patientLastName']}",
                                                        patient["uhid"] ?? "",
                                                        billIdsString,
                                                        // ✅ Pass the string version of bill IDs
                                                        patient["patientEmail"] ??
                                                            "",
                                                        patient["phoneno"] ??
                                                            "",
                                                      );
                                                    }
                                                  },
                                                  child: Text(
                                                    "View All...",
                                                    style: TextStyle(
                                                      fontFamily: 'Nunito',
                                                      fontSize: 14,
                                                      color: Color(0xFF153A7C),
                                                      // Blue color similar to button
                                                      fontWeight:
                                                          FontWeight.bold,
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

  TextStyle _valueStyle() {
    return TextStyle(
      fontFamily: 'Nunito',
      fontSize: 12, // Reduced font size for values
      color: Colors.black87, // Slightly muted color for readability
    );
  }

  // Existing bold style function (used for both labels and values)
  TextStyle _boldStyle() {
    return TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14, // Default size for bold text
      fontWeight: FontWeight.bold,
    );
  }
}
