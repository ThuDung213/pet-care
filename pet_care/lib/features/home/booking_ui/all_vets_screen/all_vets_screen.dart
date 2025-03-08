import 'package:flutter/material.dart';

import '../../../../widgets/vet_booking_card.dart';

class AllVetsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> vets;

  AllVetsScreen({required this.vets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              radius: 20,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Programmer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Xử lý khi nhấn vào thông báo
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bác sĩ thú y...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Danh sách bác sĩ thú y',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: vets.map((vet) {
                  return VetBookingCard(
                    name: vet['name'],
                    specialty: vet['specialty'],
                    rating: vet['rating'],
                    image: vet['image'],
                    petType: vet['specialty'].contains('chó') ? 'Chó' : 'Mèo',
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}