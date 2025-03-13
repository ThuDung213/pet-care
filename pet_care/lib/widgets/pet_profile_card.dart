import 'package:flutter/material.dart';
import 'package:pet_care/data/model/pet_list.dart';

class PetProfileCard extends StatelessWidget {
  final List<PetModel>? petData;

  PetProfileCard({required this.petData});

  @override
  Widget build(BuildContext context) {
    if (petData == null || petData!.isEmpty) {
      return Center(
        child: Text(
          "Không có dữ liệu thú cưng",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // Để tránh lỗi layout
      physics:
          NeverScrollableScrollPhysics(), // Tránh conflict cuộn nếu trong NestedScrollView
      itemCount: petData!.length,
      itemBuilder: (context, index) {
        final pet = petData![index];

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          height: 150,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[300]!],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 5,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pet.petName ?? "Không có tên",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${pet.petType} | ${pet.petBreed}",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(pet.imageUrl)
                    as ImageProvider, // Nếu không, dùng ảnh mặc định
              ),
            ],
          ),
        );
      },
    );
  }
}
