import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../colors/appcolors.dart';
import '../../providers/bills/add_bills_provider.dart';

class AddBillDialog extends StatelessWidget {
  final String patientId;
  final VoidCallback onBillAdded;

  AddBillDialog({required this.patientId, required this.onBillAdded});

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add New Bill",
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: "nunito",
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: subjectController,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: "Subject",
                focusColor: primaryColor,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: amountController,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                focusColor: primaryColor,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 2)),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: primaryColor)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Use the provider to add the bill
                    final provider =
                        Provider.of<AddBillsProvider>(context, listen: false);
                    provider.addBill(
                      patientId: patientId,
                      subject: subjectController.text,
                      amount: amountController.text,
                      onSuccess: onBillAdded,
                      context: context,
                    );
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
  }
}
