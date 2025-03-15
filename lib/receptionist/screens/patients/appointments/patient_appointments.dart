import 'package:flutter/material.dart';
import 'package:hospital/colors/appcolors.dart';
import 'package:provider/provider.dart';
import '../../../providers/patients/appointments/patient_appointments.dart';
import '../patient_profile.dart';

class PatientAppointScreen extends StatefulWidget {
  @override
  _PatientAppointScreenState createState() => _PatientAppointScreenState();
}

class _PatientAppointScreenState extends State<PatientAppointScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<PatientAppointmentProvider>(context, listen: false)
        .fetchAppointments();
  }

  void filterAppointments(String query) {
    Provider.of<PatientAppointmentProvider>(context, listen: false)
        .filterAppointments(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF1F7),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Text(
              "Appointments",
              style: TextStyle(fontFamily: "nunito", color: Colors.white),
            ),
          ),
          backgroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(top: 23),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Consumer<PatientAppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
                child: CircularProgressIndicator(color: primaryColor));
          }
          return Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search by UHID or patient name",
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                    onChanged: filterAppointments,
                  )),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.filteredAppointments.length,
                  itemBuilder: (context, index) {
                    return AppointmentCard(
                        appointment: provider.filteredAppointments[index]);
                  },
                ),
              ),
            ],
          );
        },
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
                    builder: (context) => PatientEditScreen(
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
