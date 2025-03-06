import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pet_care/features/home/pet_profile_ui/add_pet_screen/PetBreedSelectionScreen/pet_name_screen/pet_weight_screen/SpecialCharacteristicsScreen/SpecialDayScreen/SpecialDayScreen.dart';
import 'package:pet_care/widgets/bottom_nav_bar.dart';

class SpecialCharacteristicsScreen extends StatefulWidget {
  final String petType;
  final String petBreed;
  final File image;
  final String petName;
  final String weight;
  final String size;
  final String gender;

  const SpecialCharacteristicsScreen({
    Key? key,
    required this.petType,
    required this.petBreed,
    required this.image,
    required this.petName,
    required this.weight,
    required this.size,
    required this.gender,
  }) : super(key: key);

  @override
  State<SpecialCharacteristicsScreen> createState() =>
      _SpecialCharacteristicsScreenState();
}

class _SpecialCharacteristicsScreenState
    extends State<SpecialCharacteristicsScreen> {
  int selectedIndex = 2;
  final List<String> _selectedCharacteristics = [];
  final List<String> _characteristics = [
    "Đã triệt sản",
    "Đuôi cụp",
    "Mắt hai màu",
    "Lông xoăn",
    "Lông thẳng",
    "Lông ngắn",
    "Lông dài",
    "Có sẹo"
  ];

  void _toggleSelection(String characteristic) {
    setState(() {
      if (_selectedCharacteristics.contains(characteristic)) {
        _selectedCharacteristics.remove(characteristic);
      } else {
        _selectedCharacteristics.add(characteristic);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 80,
              backgroundImage: FileImage(widget.image),
            ),
            const SizedBox(height: 20),
            const Text(
              "Đặc điểm đặc biệt của thú cưng",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Hãy chọn một vài nhận dạng đặc biệt của thú cưng nhé",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _characteristics.map((characteristic) {
                return ChoiceChip(
                  label: Text(characteristic),
                  selected: _selectedCharacteristics.contains(characteristic),
                  onSelected: (_) => _toggleSelection(characteristic),
                  selectedColor: Colors.blue.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpecialDayScreen(
                        petType: widget.petType,
                        petBreed: widget.petBreed,
                        image: widget.image,
                        petName: widget.petName,
                        weight: widget.weight,
                        size: widget.size,
                        gender: widget.gender,
                        characteristics: _selectedCharacteristics,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF254EDB),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Tiếp tục",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(height: 55),
          BottomNavBar(
            selectedIndex: selectedIndex,
            onItemTapped: (index) {
              setState(() {
                selectedIndex = index;
              });

              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home');
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/');
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/profile_screen');
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, '/');
                  break;
                case 4:
                  Navigator.pushReplacementNamed(context, '/AccountScreen');
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(90),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Hồ sơ thú cưng",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text("Bước 5/7",
                  style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 5 / 7,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
            minHeight: 4,
          ),
        ),
      ),
    );
  }
}
