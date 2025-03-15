import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/doctors/get_doctors.dart';

class GetDoctorsScreen extends StatefulWidget {
  @override
  _GetDoctorsScreenState createState() => _GetDoctorsScreenState();
}

class _GetDoctorsScreenState extends State<GetDoctorsScreen> {
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

  Future<void> fetchDoctors() async {
    try {
      await Provider.of<GetDoctorsProvider>(context, listen: false)
          .fetchDoctors();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load doctors. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void filterDoctors() {
    Provider.of<GetDoctorsProvider>(context, listen: false)
        .filterDoctors(searchController.text);
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
                    color: Color(0xFF1E398F), // Set the border color to blue
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
            Consumer<GetDoctorsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (provider.filteredDoctors.isEmpty) {
                  return Center(child: Text("No doctors found."));
                } else {
                  return Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: provider.filteredDoctors.length,
                      itemBuilder: (context, index) {
                        return DoctorCard(
                          name: provider.filteredDoctors[index]["name"]!,
                          specialization: provider.filteredDoctors[index]
                              ["specialization"]!,
                          email: provider.filteredDoctors[index]["email"]!,
                          phone: provider.filteredDoctors[index]["phone"]!,
                        );
                      },
                    ),
                  );
                }
              },
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
