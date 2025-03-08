import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/data/model/add_pet.dart';
import 'package:pet_care/data/repositories/complete_profile_repository.dart';
import 'package:pet_care/features/home/pet_profile_ui/add_pet_screen/PetBreedSelectionScreen/pet_name_screen/pet_weight_screen/SpecialCharacteristicsScreen/SpecialDayScreen/CaretakerScreen/CompleteProfileScreen/PetProfileScreen/PetProfileScreen.dart';
import 'package:pet_care/widgets/bottom_nav_bar.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String petType;
  final String petBreed;
  final File image;
  final String petName;
  final String weight;
  final String size;
  final String gender;
  final List<String> characteristics;
  final DateTime? birthDate;
  final DateTime? adoptionDate;
  final String ownerName;
  final String ownerPhone;
  final String ownerAddress;

  const CompleteProfileScreen({
    Key? key,
    required this.petType,
    required this.petBreed,
    required this.image,
    required this.petName,
    required this.weight,
    required this.size,
    required this.gender,
    required this.characteristics,
    this.birthDate,
    this.adoptionDate,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerAddress,
  }) : super(key: key);

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  int selectedIndex = 0;
  final CompleteProfileRepository repository = CompleteProfileRepository();

  String formatDate(DateTime? date) {
    return date != null ? DateFormat("dd/MM/yyyy").format(date) : "Chưa cập nhật";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ thú cưng", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 95,
                      backgroundImage: FileImage(widget.image),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          widget.petName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${widget.petType} | ${widget.petBreed}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle("Đặc điểm"),
                  _buildInfoRow("Giới tính", widget.gender),
                  _buildInfoRow("Kích cỡ", widget.size),
                  _buildInfoRow("Cân nặng", widget.weight),
                  _buildInfoRow("Mô tả", widget.characteristics.join(", ")),
                  const SizedBox(height: 16),
                  _buildSectionTitle("Ngày quan trọng"),
                  _buildDateRow("Sinh nhật", widget.birthDate),
                  _buildDateRow("Ngày nhận nuôi", widget.adoptionDate),
                  const SizedBox(height: 16),
                  _buildSectionTitle("Người chăm sóc"),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage("assets/avatar_placeholder.png"),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.ownerName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.ownerPhone,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF254EDB),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          String? petId = await repository.completeProfile(
                            context: context,
                            petType: widget.petType,
                            petBreed: widget.petBreed,
                            image: widget.image,
                            petName: widget.petName,
                            weight: widget.weight,
                            size: widget.size,
                            gender: widget.gender,
                            characteristics: widget.characteristics,
                            birthDate: widget.birthDate,
                            adoptionDate: widget.adoptionDate,
                            ownerName: widget.ownerName,
                            ownerPhone: widget.ownerPhone,
                            ownerAddress: widget.ownerAddress,
                          );
                          if (petId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PetProfileScreen(petId: petId),
                              ),
                            );
                          }
                        },
                        child: const Text("Hoàn tất hồ sơ", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime? date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.event, color: Colors.blue),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(formatDate(date), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
