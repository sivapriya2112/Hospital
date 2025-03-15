import 'package:flutter/material.dart';
import 'package:hospital/receptionist/screens/patients/patient_profile.dart';
import 'package:provider/provider.dart';
import '../../../colors/appcolors.dart';
import '../../providers/patients/get_all_patients.dart';

class RecepPatients extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PatientsProvider()
        ..fetchPatients()
        ..loadAppointmentCounts(),
      child: Scaffold(
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
        body: Consumer<PatientsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: provider.search,
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
                      _buildInfoBox(
                          'Today Appointments',
                          provider.totalAppointmentsCount.toString(),
                          Colors.blue),
                      _buildInfoBox('Inpatients',
                          provider.inpatientCount.toString(), Colors.green),
                      _buildInfoBox('Outpatients',
                          provider.outpatientCount.toString(), Colors.orange),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Patient List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  provider.filteredPatients.isEmpty
                      ? Center(
                          child: Text('No patients found'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: provider.filteredPatients.length >
                                  provider.visibleCount
                              ? provider.visibleCount + 1
                              : provider.filteredPatients.length,
                          itemBuilder: (context, index) {
                            if (index == provider.visibleCount &&
                                provider.filteredPatients.length >
                                    provider.visibleCount) {
                              return TextButton(
                                onPressed: provider.loadMorePatients,
                                child: Text('Show More'),
                              );
                            }

                            final patient = provider.filteredPatients[index];
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
                                    SizedBox(height: 12),
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
                                    SizedBox(height: 12),
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
                                    SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                color: blackColor),
                                            SizedBox(width: 10),
                                            Text(
                                              'Age: ${patient['patientAge'] ?? 'N/A'}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Nunito',
                                                color: blackColor,
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
                                                    PatientEditScreen(
                                                  name:
                                                      '${patient['patientFirstName'] ?? ''} ${patient['patientLastName'] ?? ''}'
                                                          .trim(),
                                                  email:
                                                      patient['patientEmail'] ??
                                                          'N/A',
                                                  age: int.tryParse(
                                                          patient['patientAge']
                                                              .toString()) ??
                                                      0,
                                                  phoneNo: patient['phoneno'] ??
                                                      'N/A',
                                                  patientId:
                                                      patient['uhid'] ?? 'N/A',
                                                  objectId:
                                                      patient['_id'] ?? 'N/A',
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
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            );
          },
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
