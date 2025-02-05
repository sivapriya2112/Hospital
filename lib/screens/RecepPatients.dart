import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors/appcolors.dart';
import 'RecepPatientProfile.dart';

class RecepPatients extends StatefulWidget {
  @override
  _RecepPatientsState createState() => _RecepPatientsState();
}

class _RecepPatientsState extends State<RecepPatients> {
  List<dynamic> patientDetails = [];
  List<dynamic> filteredPatients = [];
  String searchInput = "";
  int visibleCount = 10;
  bool isLoading = true;
  // Variables for appointment counts
  int inpatientCount = 0;
  int outpatientCount = 0;
  int totalAppointmentsCount = 0;

  @override
  void initState() {
    super.initState();
    fetchPatients();
    loadAppointmentCounts(); // Load appointment counts
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
          patientDetails = data;
          filteredPatients = data;
          isLoading = false; // Step 3: Stop loading
        });
      } else {
        setState(() {
          patientDetails = [];
          filteredPatients = [];
          isLoading = false; // Stop loading on failure
        });
        print('Failed to load patients: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        patientDetails = [];
        filteredPatients = [];
        isLoading = false; // Stop loading on error
      });
      print('Error fetching patients: $e');
    }
  }

  // Load appointment counts from SharedPreferences
  Future<void> loadAppointmentCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      inpatientCount = prefs.getInt('inpatientCount') ?? 0;
      outpatientCount = prefs.getInt('outpatientCount') ?? 0;
      totalAppointmentsCount = prefs.getInt('totalAppointmentsCount') ?? 0;
    });
  }

  void search(String input) {
    setState(() {
      searchInput = input;
      filteredPatients = input.isEmpty
          ? patientDetails
          : patientDetails.where((patient) {
              return (patient['patientEmail'] ?? '')
                      .toLowerCase()
                      .contains(input.toLowerCase()) ||
                  (patient['patientLastName'] ?? '')
                      .toString()
                      .contains(input) ||
                  (patient['patientFirstName'] ?? '')
                      .toString()
                      .contains(input);
            }).toList();
    });
  }

  void loadMorePatients() {
    setState(() {
      visibleCount += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Patients',
          style: TextStyle(
            fontFamily: 'Nunito',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF193482),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 70,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: primaryColor)) // Step 4: Show loader
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: search,
                    decoration: InputDecoration(
                      hintText: 'Search patients',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoBox('Today Appointments',
                          totalAppointmentsCount.toString(), Colors.blue),
                      _buildInfoBox('Inpatients', inpatientCount.toString(),
                          Colors.green),
                      _buildInfoBox('Outpatients', outpatientCount.toString(),
                          Colors.orange),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Patient List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  filteredPatients.isEmpty
                      ? Center(
                          child: Text('No patients found'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: filteredPatients.length > visibleCount
                              ? visibleCount + 1
                              : filteredPatients.length,
                          itemBuilder: (context, index) {
                            if (index == visibleCount &&
                                filteredPatients.length > visibleCount) {
                              return TextButton(
                                onPressed: loadMorePatients,
                                child: Text('Show More'),
                              );
                            }

                            final patient = filteredPatients[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Name and UHID in one row (aligned properly)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.person,
                                                color: blackColor),
                                            SizedBox(width: 8),
                                            Text(
                                              '${patient['patientFirstName'] ?? ''} ${patient['patientLastName'] ?? ''}'
                                                  .trim(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'Nunito',
                                                fontWeight: FontWeight.bold,
                                                color: blackColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Id: ${patient['uhid'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Nunito',
                                            color: primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height:
                                            12), // Equal spacing between all rows

                                    /// Email
                                    Row(
                                      children: [
                                        Icon(Icons.email, color: blackColor),
                                        SizedBox(width: 10),
                                        Text(
                                          patient['patientEmail'] ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Nunito',
                                            color: blackColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12), // Reduced spacing

                                    /// Phone No.
                                    Row(
                                      children: [
                                        Icon(Icons.phone, color: blackColor),
                                        SizedBox(width: 10),
                                        Text(
                                          patient['phoneno'] ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'Nunito',
                                            color: blackColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12), // Reduced spacing

                                    /// Age on the left and Button on the right (aligned with UHID)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom:
                                                      15), // Add bottom margin to the icon
                                              child: Icon(Icons.calendar_today,
                                                  color: blackColor),
                                            ),
                                            SizedBox(width: 10),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom:
                                                      15), // Add bottom margin to the text
                                              child: Text(
                                                'Age: ${patient['patientAge'] ?? 'N/A'}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Nunito',
                                                  color: blackColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RecepPatientProfile(
                                                  name:
                                                      '${patient['patientFirstName'] ?? ''} ${patient['patientLastName'] ?? ''}'
                                                          .trim(),
                                                  email:
                                                      patient['patientEmail'] ??
                                                          'N/A',
                                                  age: int.tryParse(
                                                          patient['patientAge']
                                                              .toString()) ??
                                                      0, // Fix here
                                                  phoneNo: patient['phoneno'] ??
                                                      'N/A',
                                                  patientId: patient['uhid'] ??
                                                      'N/A', // This corresponds to 'uhid'
                                                  objectId: patient['_id'] ??
                                                      'N/A', // This corresponds to '_id'
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'View Details',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF193482),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Visibility(
                                      visible:
                                          false, // This will hide the widget
                                      child: Text(
                                        'Object ID: ${patient['_id'] ?? 'N/A'}', // Display the object ID
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Nunito',
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoBox(String title, String count, Color color) {
    return Expanded(
      child: Container(
        height: 100,
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
