import 'package:flutter/material.dart';

class VetCard extends StatelessWidget {
  final List<Map<String, dynamic>>? vetData;

  VetCard({required this.vetData});

  @override
  Widget build(BuildContext context) {
    if (vetData == null || vetData!.isEmpty) {
      return Center(
        child: Text("Không có dữ liệu bác sĩ thú y",
            style: TextStyle(color: Colors.white)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: vetData!.length,
      itemBuilder: (context, index) {
        final vet = vetData![index];

        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundImage:
                    vet['avatar'] != null && vet['avatar'].startsWith("http")
                        ? NetworkImage(vet['avatar'])
                        : AssetImage("assets/profile.jpg") as ImageProvider,
              ),
              SizedBox(height: 8),
              Text(vet['name'] ?? "Không có tên",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text(vet['specialization'] ?? "Không có địa chỉ",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 16),
                  Text(vet['rating']?.toString() ?? "N/A",
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  SizedBox(width: 8),
                  Icon(Icons.location_on, color: Colors.white70, size: 16),
                  Text(vet['clinicAddress']?.toString() ?? "N/A",
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
