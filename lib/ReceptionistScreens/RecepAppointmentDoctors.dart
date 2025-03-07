import 'package:flutter/material.dart';
import 'package:hospital/colors/appcolors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecepAppointmentDoctors extends StatefulWidget {
  @override
  _RecepAppointmentDoctorsState createState() =>
      _RecepAppointmentDoctorsState();
}

class _RecepAppointmentDoctorsState extends State<RecepAppointmentDoctors> {
  List<Map<String, String>> doctors = [];
  List<Map<String, String>> filteredDoctors = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDoctors();

    // Listen to changes in the search field
    searchController.addListener(() {
      filterDoctors();
    });
  }

  Future<Map<String, String>> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String hospitalId = prefs.getString('hospitalId') ?? '';
    return {
      'token': token,
      'hospitalId': hospitalId,
    };
  }

  Future<void> fetchDoctors() async {
    try {
      Map<String, String> preferences = await getPreferences();
      String token = preferences['token']!;
      String hospitalId = preferences['hospitalId']!;

      final uri = Uri.parse('https://hospital-fitq.onrender.com/doctor/getall');
      final headers = {
        'Content-Type': 'application/json',
        'token': token,
      };

      final body = json.encode({
        'hospitalId': hospitalId,
      });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          doctors = data.map<Map<String, String>>((doctor) {
            return {
              'name': doctor['name'] ?? '',
              'specialization': doctor['specialization'] ?? '',
              'email': doctor['email'] ?? '',
              'phone': doctor['phone'] ?? '',
            };
          }).toList();
          filteredDoctors = doctors; // Initialize with all doctors
        });
      } else {
        throw Exception('Failed to load doctors: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching doctors: $error');
      throw Exception('Failed to load doctors');
    }
  }

  void filterDoctors() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredDoctors = doctors.where((doctor) {
        return doctor['name']!.toLowerCase().contains(query) ||
            doctor['specialization']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E398F),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "All Doctors",
          style: TextStyle(fontFamily: 'Nunito', color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search field
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or specialization',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: primaryColor, // Set the border color to blue
                  ),
                ),
                hintStyle: TextStyle(
                  fontFamily: 'Nunito', // Apply Nunito font to hint text
                ),
              ),
              style: TextStyle(
                fontFamily: 'Nunito', // Apply Nunito font to input text
              ),
            ),

            SizedBox(height: 20), // Add space between search field and grid
            filteredDoctors.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        return DoctorCard(
                          name: filteredDoctors[index]["name"]!,
                          specialization: filteredDoctors[index]
                              ["specialization"]!,
                          email: filteredDoctors[index]["email"]!,
                          phone: filteredDoctors[index]["phone"]!,
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialization;
  final String email;
  final String phone;

  const DoctorCard({
    required this.name,
    required this.specialization,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: Color(0xFF1E398F),
              child: Text(
                name[0],
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
            Text(
              specialization,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Nunito',
              ),
            ),
            SizedBox(height: 10),
            Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.grey),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        email,
                        style: TextStyle(fontSize: 14, fontFamily: 'Nunito'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        phone,
                        style: TextStyle(fontSize: 14, fontFamily: 'Nunito'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 15),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E398F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: FittedBox(
                      child: Text(
                        "Book Appointment",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
