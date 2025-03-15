// screens/get_all_bills.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/patients/bills/get_all_bills.dart';
import 'add_bills.dart';
import 'update_bills.dart';

class RecepBillsScreen extends StatefulWidget {
  @override
  _RecepBillsScreenState createState() => _RecepBillsScreenState();
}

class _RecepBillsScreenState extends State<RecepBillsScreen> {
  int? expandedIndex;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RecepBillsProvider>(context, listen: false);

    provider.fetchPatients().then((_) {
      if (provider.patients.isNotEmpty) {
        provider.fetchBills(provider.patients[0]["_id"]);
      }
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

  void _showAddBillDialog(String id, RecepBillsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AddBillDialog(
        patientId: id,
        onBillAdded: () {
          setState(() {});
          provider.fetchBills(id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecepBillsProvider>(context);
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
                onChanged: provider.search,
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
              child: provider.isLoading
                  ? Center(child: CircularProgressIndicator()) // Show loader
                  : provider.patients.isEmpty
                      ? Center(
                          child: Text(
                            "No patients found",
                            style:
                                TextStyle(fontFamily: 'Nunito', fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: provider.filteredPatients.length,
                          itemBuilder: (context, index) {
                            bool isExpanded = expandedIndex == index;
                            var patient = provider.filteredPatients[index];
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        expandedIndex = null;
                                        provider.bills =
                                            []; // Clear previous bills
                                      } else {
                                        expandedIndex = index;
                                        provider.fetchBills(patient["_id"]);
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
                                                  _showAddBillDialog(
                                                      patient["_id"], provider);
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
                                    child: provider.bills.isEmpty
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
                                                "Bill Details",
                                                style: TextStyle(
                                                  fontFamily: 'Nunito',
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 10),
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
                                                      child: Text("Status",
                                                          style: _boldStyle())),
                                                ],
                                              ),
                                              Divider(),
                                              ...(provider.bills.length > 2
                                                      ? provider.bills.sublist(
                                                          provider.bills
                                                                  .length -
                                                              2)
                                                      : provider.bills)
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
                                                    if (provider
                                                        .bills.isNotEmpty) {
                                                      double totalAmount = 0.0;
                                                      double totalPaidAmount =
                                                          0.0;
                                                      for (var bill
                                                          in provider.bills) {
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
                                                      List<String> billIds =
                                                          provider.bills
                                                              .map((bill) =>
                                                                  bill["_id"]
                                                                      ?.toString() ??
                                                                  "")
                                                              .toList();
                                                      String billIdsString =
                                                          billIds.join(",");
                                                      navigateToPaymentTableScreen(
                                                        context,
                                                        provider.bills
                                                            .map<PaymentEntry>(
                                                                (bill) {
                                                          var billData =
                                                              bill["bill"] ??
                                                                  {};
                                                          return PaymentEntry(
                                                            id: bill["_id"] ??
                                                                "",
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
      fontSize: 12,
      color: Colors.black87,
    );
  }

  TextStyle _boldStyle() {
    return TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
  }
}
