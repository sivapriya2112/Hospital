import 'package:flutter/material.dart';
import 'package:hospital/colors/appcolors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'RecepPatientProfile.dart';

class RecepAppointments extends StatefulWidget {
  @override
  _RecepAppointmentsState createState() => _RecepAppointmentsState();
}

class _RecepAppointmentsState extends State<RecepAppointments> {
  List<dynamic> appointments = [];
  bool isLoading = true;

  List<dynamic> filteredAppointments = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    print("fetchAppointments called");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hospitalId = prefs.getString('hospitalId');
    String? token = prefs.getString('token');

    if (hospitalId == null || token == null) {
      setState(() {
        isLoading = false;
      });
      print("Hospital ID or Token is null");
      return;
    }

    final url = Uri.parse("https://hospital-fitq.onrender.com/appointment/get");
    final response = await http.post(
      url,
      headers: {
        'token': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"hospitalId": hospitalId}),
    );

    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        appointments = jsonDecode(response.body);
        filteredAppointments =
            List.from(appointments); // Initialize filtered list
        isLoading = false;
      });
    } else {
      print("Error: ${response.statusCode}, ${response.body}");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch appointments. Please try again later.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void filterAppointments(String query) {
    setState(() {
      filteredAppointments = appointments.where((appointment) {
        String patientName =
            "${appointment['patientInfo']?['patientFirstName'] ?? ''} ${appointment['patientInfo']?['patientLastName'] ?? ''}"
                .toLowerCase();
        String uhid = appointment['patientInfo']?['uhid'] ?? '';
        return patientName.contains(query.toLowerCase()) ||
            uhid.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF1F7),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75), // Set height to 70
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 25), // Add top padding to title
            child: Text(
              "Appointments",
              style: TextStyle(fontFamily: "nunito", color: Colors.white),
            ),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(top: 23), // Add top padding to icon
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search by UHID or patient name",
                        prefixIcon: Icon(Icons.search,
                            color: Colors.black), // Change icon color
                        // Change this to your desired background color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                              color: primaryColor), // Default border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.5), // Focused border color
                        ),
                      ),
                      onChanged: filterAppointments,
                    )),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      return AppointmentCard(
                          appointment: filteredAppointments[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final dynamic appointment;

  AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  '${appointment['patientInfo']?['patientFirstName'] ?? "Unknown"} ${appointment['patientInfo']?['patientLastName'] ?? ""}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: blackColor,
                    fontFamily: 'Nunito',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  appointment['patientInfo']?['uhid'] ?? "N/A",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    fontFamily: 'Nunito',
                  ),
                ),
                // String patientType = appointment['patientType'] ?? "N/A"; // Store the value if needed

                Divider(thickness: 1, color: Colors.black26),
              ],
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment['patientInfo']?['patientEmail'] ?? "N/A",
                    style: TextStyle(
                        fontSize: 15, fontFamily: 'Nunito', color: blackColor),
                  ),
                  SizedBox(height: 4),
                  Text(
                    appointment['patientInfo']?['phoneno'] ?? "N/A",
                    style: TextStyle(
                        fontSize: 14, fontFamily: 'Nunito', color: blackColor),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    appointment['date'] ?? "N/A",
                    style: TextStyle(
                        fontSize: 14, fontFamily: 'Nunito', color: blackColor),
                  ),
                  SizedBox(height: 4),
                  Text(
                    appointment['time'] ?? "N/A",
                    style: TextStyle(
                        fontSize: 14, fontFamily: 'Nunito', color: blackColor),
                  ),
                ],
              ),
            ],
          ),
          Divider(thickness: 1, color: Colors.black26),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Doctor : ${appointment['doctorInfo']?['name'] ?? "N/A"}",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Nunito',
                    color: blackColor),
              ),
              Text(
                "Status: ${appointment['status'] ?? "N/A"}",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.redAccent,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecepPatientProfile(
                      name:
                          '${appointment['patientInfo']?['patientFirstName'] ?? ''} ${appointment['patientInfo']?['patientLastName'] ?? ''}'
                              .trim(),
                      email:
                          appointment['patientInfo']?['patientEmail'] ?? 'N/A',
                      age: int.tryParse(appointment['patientInfo']
                                      ?['patientAge']
                                  ?.toString() ??
                              '0') ??
                          0,
                      phoneNo: appointment['patientInfo']?['phoneno'] ?? 'N/A',
                      patientId: appointment['patientInfo']?['uhid'] ?? 'N/A',
                      objectId: appointment['patientInfo']?['_id'] ?? 'N/A',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                "View Details",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
