import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
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
                      .contains(input.toLowerCase()) ||
                  (patient['uhid']?.toString() ?? '')
                      .toLowerCase()
                      .contains(input.toLowerCase());
            }).toList();
    });
  }

  Future<void> _addBill(BuildContext context, String patientId, String subject,
      String amount) async {
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

    final Uri apiUrl =
        Uri.parse("https://hospital-fitq.onrender.com/billing/add");

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

    print("Sending request to: $apiUrl");
    print("Request Headers: {Content-Type: application/json, token: $token}");
    print("Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
          "token": token ?? "",
        },
        body: jsonEncode(requestBody),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Bill added successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context); // for close dialog
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

  void _showAddBillDialog(String id) {
    TextEditingController subjectController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Add New Bill",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: subjectController,
                    maxLength: 30,
                    decoration: InputDecoration(
                      labelText: "Subject",
                      focusColor: primaryColor,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: amountController,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Amount",
                      focusColor: primaryColor,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: primaryColor), // Blue text
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _addBill(context, id, subjectController.text,
                            amountController.text);
                      },
                      child: Text("Submit"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
                                                  Expanded(
                                                      child: Text("Due",
                                                          style: _boldStyle())),
                                                  Expanded(
                                                      child: Text("Status",
                                                          style: _boldStyle())),
                                                ],
                                              ),
                                              Divider(),

                                              // List of bills
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
                                                      Expanded(
                                                        child: Text(
                                                          "${dueAmount.toStringAsFixed(2)}",
                                                          style: _valueStyle(),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "Yet To Pay",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .red, // Set text color to RED
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
                                                  onPressed: () {
                                                    if (bills.isNotEmpty) {
                                                      double totalAmount = 0.0;
                                                      double totalPaid = 0.0;

                                                      // Summing up total and paid amounts
                                                      for (var bill in bills) {
                                                        var billData =
                                                            bill["bill"] ?? {};
                                                        totalAmount += double
                                                                .tryParse(billData[
                                                                        "amount"]
                                                                    .toString()) ??
                                                            0.0;
                                                        totalPaid += double
                                                                .tryParse(billData[
                                                                        "paid"]
                                                                    .toString()) ??
                                                            0.0;
                                                      }

                                                      // Pass data to dialog
                                                      showEditPaymentDialog(
                                                        context,
                                                      );
                                                    }
                                                  },
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

  void showEditPaymentDialog(BuildContext context) {
    final TextEditingController payableAmountController =
        TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding:
              EdgeInsets.symmetric(horizontal: 8), // Margin 5 on each side
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: Color(0xFFFCF8F6),
          child: Container(
            width: double.infinity, // Match parent width
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Edit Payment",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 15),
                  buildLabelValueRow("Subject", "Consultation Fee"),
                  SizedBox(height: 8),
                  buildLabelValueRow("Total Paid", "₹500"),
                  SizedBox(height: 8),
                  buildLabelValueRow("Paid Amount", "₹200"),
                  SizedBox(height: 8),
                  buildLabelValueRow("Total Due", "₹300", isDue: true),
                  SizedBox(height: 15),
                  Text("Enter Payable Amount", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: payableAmountController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      hintText: "Enter amount",
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      counterText: "",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Amount is required';
                      }
                      final double? enteredAmount = double.tryParse(value);
                      if (enteredAmount == null || enteredAmount <= 0) {
                        return 'Enter a valid amount';
                      }
                      if (enteredAmount > 300) {
                        // Replace 300 with dynamic totalDue
                        return 'Amount cannot exceed ₹300';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel",
                            style: TextStyle(color: Colors.black)),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF153A7C),
                          foregroundColor: Colors.white,
                        ),
                        child: Text("Submit"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildLabelValueRow(String label, String value, {bool isDue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start, // Align text at the top
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(width: 8), // Add space between label and value
        Expanded(
          // This prevents overflow
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDue ? Colors.red : Colors.black,
            ),
            overflow: TextOverflow.ellipsis, // Shows "..."
            maxLines: 2, // Allows wrapping
            textAlign: TextAlign.end, // Aligns text to the right
          ),
        ),
      ],
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
