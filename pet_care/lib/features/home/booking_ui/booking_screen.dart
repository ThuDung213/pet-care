import 'package:flutter/material.dart';
import 'package:pet_care/widgets/vet_booking_card.dart';

import '../../../widgets/specialization_button.dart';
import 'all_vets_screen/all_vets_screen.dart';


class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final List<Map<String, dynamic>> allVets = [
    {
      'name': 'Dr. Nguyễn Văn A',
      'specialty': 'Chuyên gia về chó',
      'rating': 4.9,
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Dr. Trần Thị B',
      'specialty': 'Chuyên gia về mèo',
      'rating': 4.8,
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Dr. Lê Văn C',
      'specialty': 'Chuyên gia về chó',
      'rating': 4.7,
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Dr. Phạm Thị D',
      'specialty': 'Chuyên gia về mèo',
      'rating': 4.6,
      'image': 'https://via.placeholder.com/150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final displayedVets = allVets.take(3).toList(); // Chỉ hiển thị 3 bác sĩ thú y ban đầu

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
                'Chuyên môn của bác sĩ thú y',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SpecializationButton(
                    icon: Icons.pets,
                    label: 'Chó',
                    color: Colors.blue,
                  ),
                  SpecializationButton(
                    icon: Icons.pets,
                    label: 'Mèo',
                    color: Colors.orange,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bác sĩ thú y nổi bật',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Chuyển hướng sang trang AllVetsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllVetsScreen(vets: allVets),
                        ),
                      );
                    },
                    child: Text(
                      'Tất cả bác sĩ thú y',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                children: displayedVets.map((vet) {
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