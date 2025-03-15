import 'package:flutter/material.dart';
import 'package:hospital/colors/appcolors.dart';
import 'package:provider/provider.dart';
import '../../providers/receptionist/profile.dart';
import '../patients/appointments/patient_appointments.dart';
import '../patients/bills/get_all_bills.dart';
import '../patients/get_all_patients.dart';

class ReceptionistDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> dashboardItems = [
    {'icon': Icons.person, 'label': 'Patients'},
    {'icon': Icons.medical_services, 'label': 'Diagnostics'},
    {'icon': Icons.event, 'label': 'Appointments'},
    {'icon': Icons.receipt, 'label': 'Bill Details'},
    {'icon': Icons.folder_shared, 'label': 'EMR'},
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecepProfileProvider()..fetchProfileData(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Receptionist Dashboard',
            style: TextStyle(
              fontFamily: 'Nunito',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () {},
            ),
          ],
          toolbarHeight: 70,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(height: 30),
              Consumer<RecepProfileProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (provider.profileData.isEmpty) {
                    return Text('No profile data available');
                  }

                  var profileData = provider.profileData;
                  String firstLetter = profileData['name'] != null &&
                          profileData['name'].isNotEmpty
                      ? profileData['name'][0].toUpperCase()
                      : 'N';

                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade300,
                          child: Text(
                            firstLetter,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileData['name'] ?? 'No Name',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: blackColor,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Email: ${profileData['email'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: blackColor,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            Text(
                              'Mobile: ${profileData['phone'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 16,
                                color: blackColor,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: dashboardItems.length,
                  itemBuilder: (context, index) {
                    final item = dashboardItems[index];
                    return GestureDetector(
                      onTap: () {
                        if (item['label'] == 'Patients') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RecepPatients()),
                          );
                        } else if (item['label'] == 'Appointments') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PatientAppointScreen()),
                          );
                        } else if (item['label'] == 'Bill Details') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RecepBillsScreen()),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF193482), Color(0xFF1D4AB5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item['icon'],
                              color: Colors.white,
                              size: 36,
                            ),
                            SizedBox(height: 8),
                            Text(
                              item['label'],
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Nunito',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
