import 'package:flutter/material.dart';

class VetCard extends StatelessWidget {
  final List<Map<String, String>> doctors = [
    {"name": "BS. Đặng Mai Linh", "location": "Bệnh viện Thú y Hà Nội", "image": "assets/profile.jpg", "rating": "4.8", "distance": "12 km"},
    {"name": "BS. Nguyễn Anh Tuấn", "location": "Bệnh viện Thú y Hà Nội", "image": "assets/profile.jpg", "rating": "4.9", "distance": "8 km"},
    {"name": "BS. Đặng Mai Linh", "location": "Bệnh viện Thú y Hà Nội", "image": "assets/profile.jpg", "rating": "4.8", "distance": "12 km"},
    {"name": "BS. Nguyễn Anh Tuấn", "location": "Bệnh viện Thú y Hà Nội", "image": "assets/profile.jpg", "rating": "4.9", "distance": "8 km"},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(radius: 55, backgroundImage: AssetImage("assets/profile.jpg"),),
              SizedBox(height: 8),
              Text(doctor["name"]!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(doctor["location"]!, style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 16),
                  Text(doctor["rating"]!, style: TextStyle(color: Colors.white, fontSize: 14)),
                  SizedBox(width: 8),
                  Icon(Icons.location_on, color: Colors.white70, size: 16),
                  Text(doctor["distance"]!, style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}