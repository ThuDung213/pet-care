import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pet_care/data/model/pet_list.dart';
import 'package:pet_care/data/repositories/appointment_repository.dart';
import 'package:pet_care/data/repositories/pet_repository.dart';

class VetHomeMainScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppointmentRepository _appointmentRepository = AppointmentRepository();
  final PetRepository _petRepository =
      PetRepository(); // Initialize PetRepository

  final List<String> newsBanners = [
    "assets/dogslide.jpg",
    "assets/dogslide2.jpg",
  ];

  final List<Map<String, String>> pastPatients = [
    {"name": "Buddy", "owner": "Pham Van D", "date": "01/03/2025"},
    {"name": "Daisy", "owner": "Ngo Thi E", "date": "28/02/2025"},
    {"name": "Max", "owner": "Vo Van F", "date": "25/02/2025"},
  ];

  @override
  Widget build(BuildContext context) {
    String? vetId = _auth.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text("Vet Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // News Banner
            CarouselSlider(
              options: CarouselOptions(
                height: 150,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: newsBanners.map((image) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(image,
                      fit: BoxFit.cover, width: double.infinity),
                );
              }).toList(),
            ),
            SizedBox(height: 30),

            // Appointments Section
            Text("📅 Lịch hẹn hôm nay",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _appointmentRepository.getVetAppointments(vetId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi khi tải dữ liệu"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Không có lịch hẹn nào"));
                }

                List<Map<String, dynamic>> appointments = snapshot.data!;
                return Column(
                  children: appointments.map((appt) {
                    String petId = appt['petId']; // Get petId

                    return FutureBuilder<PetModel?>(
                      future:
                          _petRepository.getPetById(petId), // Fetch pet info
                      builder: (context, petSnapshot) {
                        if (petSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (!petSnapshot.hasData) {
                          return ListTile(
                            title: Text("Không tìm thấy thú cưng"),
                            subtitle: Text("Chủ: ${appt['owner']}"),
                          );
                        }

                        PetModel pet = petSnapshot.data!;
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.pets, color: Colors.blueAccent),
                            title: Text("${pet.petName}"), // Show petName
                            subtitle: Text("Chủ: ${pet.ownerName}"),
                            trailing: Text("${appt['time']}",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
            Text("📜 Danh sách bệnh nhân đã từng khám",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            ...pastPatients.map((patient) => Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text("${patient['name']}"),
                    subtitle: Text("Chủ: ${patient['owner']}"),
                    trailing: Text("${patient['date']}"),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
