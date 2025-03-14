import 'package:flutter/material.dart';
import 'package:hospital/colors/appcolors.dart';
import 'package:hospital/receptionist/screens/bills/recep_bills_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/bills/edit_bills_provider.dart';

class PaymentTableScreen extends StatefulWidget {
  final List<PaymentEntry> payments;
  final String patientName;
  final String patientId;
  final String billingId;
  final String patientEmail;
  final String phoneNumber;

  PaymentTableScreen({
    required this.payments,
    required this.patientName,
    required this.patientId,
    required this.billingId,
    required this.patientEmail,
    required this.phoneNumber,
  });

  @override
  _PaymentTableScreenState createState() => _PaymentTableScreenState();
}

class _PaymentTableScreenState extends State<PaymentTableScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _isEditing = {}; // Track edit state

  String? selectedSubject;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.payments.length; i++) {
      String key = 'payment_${widget.payments[i].id}';
      _controllers[key] =
          TextEditingController(text: widget.payments[i].totalDue.toString());
      _controllers[key]?.addListener(() {
        setState(() {});
      });
      _isEditing[key] = false;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bill Details",
          style: TextStyle(fontFamily: "nunito", color: Colors.white),
        ),
        backgroundColor: Color(0xFF153A7C),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Row(
            children: [
              Text(
                "Print",
                style: TextStyle(
                  fontFamily: "nunito",
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 5), // Spacing between text and icon
              IconButton(
                icon: Icon(Icons.print, color: Colors.white),
                onPressed: () async {},
              ),
            ],
          ),
        ],
        toolbarHeight: 80,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailText("Name: ${widget.patientName}"),
                    _buildDetailText("Patient ID: ${widget.patientId}"),
                    _buildDetailText("Email: ${widget.patientEmail}"),
                    _buildDetailText("Phone: ${widget.phoneNumber}"),
                  ],
                ),
              ),
            ),

            SizedBox(height: 15),

            // Payment Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16.0,
                  headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Color(0xFF153A7C)),
                  columns: [
                    DataColumn(
                        label: Text("Billing ID", style: _headerTextStyle())),
                    DataColumn(
                        label: Text("Subject", style: _headerTextStyle())),
                    DataColumn(
                        label: Text("Total Amount", style: _headerTextStyle())),
                    DataColumn(
                        label: Text("Paid Amount", style: _headerTextStyle())),
                    DataColumn(
                        label: Text("Total Due", style: _headerTextStyle())),
                    DataColumn(
                        label: Text("Action", style: _headerTextStyle())),
                  ],
                  rows: widget.payments.map((payment) {
                    return DataRow(cells: [
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Text(
                            _isExpanded
                                ? payment.id
                                : (payment.id.length > 10
                                    ? "${payment.id.substring(0, 10)}..."
                                    : payment.id),
                            style: _valueTextStyle(),
                          ),
                        ),
                      ),
                      DataCell(Text(payment.subject, style: _valueTextStyle())),
                      DataCell(Text(
                          "₹${payment.totalAmount.toStringAsFixed(2)}",
                          style: _valueTextStyle())),
                      DataCell(Text("₹${payment.paidAmount.toStringAsFixed(2)}",
                          style: _valueTextStyle())),

                      DataCell(Text("₹${payment.totalDue.toStringAsFixed(2)}",
                          style: _valueTextStyle(color: Colors.red))), //

                      DataCell(
                        IconButton(
                          icon: Icon(Icons.edit, color: primaryColor),
                          onPressed: () {
                            int index = widget.payments.indexOf(payment);
                            String key = 'payment_$index';

                            setState(() {
                              selectedSubject = payment.subject;
                            });

                            // Get the current paid amount from the list
                            double currentPaid = payment.paidAmount;

                            showEditPaymentDialog(
                              context,
                              payment.id,
                              payment.subject,
                              payment.totalAmount,
                              payment.paidAmount,
                              payment.totalDue,
                              currentPaid,
                              (enteredAmount) {
                                setState(() {
                                  if (!_controllers.containsKey(key)) {
                                    _controllers[key] = TextEditingController();
                                  }
                                  _controllers[key]!.text =
                                      enteredAmount.toString();
                                });
                              },
                              () => setState(() {}),
                            );
                          },
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showEditPaymentDialog(
  BuildContext context,
  String billingId,
  String subject,
  double totalPaid,
  double paid,
  double totalDue,
  double currentPaid,
  Function(double) onSubmit,
  VoidCallback setStateCallback,
) {
  final TextEditingController payableAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: Color(0xFFFCF8F6),
        child: Padding(
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                buildLabelValueRow("Subject", subject),
                SizedBox(height: 10),
                buildLabelValueRow("Total Paid", "$totalPaid"),
                SizedBox(height: 10),
                buildLabelValueRow("Paid Amount", "$paid"),
                SizedBox(height: 10),
                buildLabelValueRow("Total Due", "$totalDue", isDue: true),
                SizedBox(height: 20),
                Text("Enter Payable Amount", style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                TextFormField(
                  controller: payableAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter amount",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount is required';
                    }
                    final double? enteredAmount = double.tryParse(value);
                    if (enteredAmount == null || enteredAmount <= 0) {
                      return 'Enter a valid amount';
                    }
                    if (enteredAmount > totalDue) {
                      return 'Amount cannot exceed $totalDue';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child:
                          Text("Cancel", style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          double enteredAmount =
                              double.parse(payableAmountController.text);

                          final editBillsProvider =
                              Provider.of<EditBillsProvider>(context,
                                  listen: false);

                          editBillsProvider
                              .submitPayment(
                            billingId,
                            enteredAmount,
                            currentPaid,
                          )
                              .then((success) {
                            if (success) {
                              Navigator.pop(context);
                              setStateCallback();
                              onSubmit(enteredAmount);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RecepBillsScreen()),
                              );
                              //for ui update immediate
                              final provider = Provider.of<EditBillsProvider>(
                                  context,
                                  listen: false);
                              provider.notifyListeners();
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
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
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      Text(
        value,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDue ? Colors.red : Colors.black),
      ),
    ],
  );
}

Widget _buildDetailText(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(
      text,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: blackColor,
      ),
    ),
  );
}

TextStyle _headerTextStyle() {
  return TextStyle(
      fontFamily: 'Nunito',
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white);
}

TextStyle _valueTextStyle({Color color = Colors.black}) {
  return TextStyle(fontFamily: 'Nunito', fontSize: 14, color: color);
}

class PaymentEntry {
  final String id;
  final String subject;
  final double totalAmount;
  final double paidAmount;
  final double totalDue;

  PaymentEntry({
    required this.id,
    required this.subject,
    required this.totalAmount,
    required this.paidAmount,
    required this.totalDue,
  });
}
