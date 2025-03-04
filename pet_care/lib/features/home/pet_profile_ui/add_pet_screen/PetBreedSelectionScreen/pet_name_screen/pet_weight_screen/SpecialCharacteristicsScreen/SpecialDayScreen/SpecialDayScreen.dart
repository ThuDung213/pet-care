import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pet_care/features/home/pet_profile_ui/add_pet_screen/PetBreedSelectionScreen/pet_name_screen/pet_weight_screen/SpecialCharacteristicsScreen/SpecialDayScreen/CaretakerScreen/CaretakerScreen.dart';
import 'package:pet_care/widgets/bottom_nav_bar.dart';


class SpecialDayScreen extends StatefulWidget {
  final String petType;
  final String petBreed;
  final File image;
  final String petName;
  final String weight;
  final String size;
  final String gender;
  final List<String> characteristics;

  const SpecialDayScreen({
    Key? key,
    required this.petType,
    required this.petBreed,
    required this.image,
    required this.petName,
    required this.weight,
    required this.size,
    required this.gender,
    required this.characteristics,
  }) : super(key: key);

  @override
  State<SpecialDayScreen> createState() => _SpecialDayScreenState();
}

class _SpecialDayScreenState extends State<SpecialDayScreen> {
  int selectedIndex = 2;
  DateTime? birthDate;
  DateTime? adoptionDate;

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          birthDate = picked;
        } else {
          adoptionDate = picked;
        }
      });
    }
  }

  bool get _isButtonEnabled => birthDate != null || adoptionDate != null;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            CircleAvatar(
              radius: 100,
              backgroundImage: FileImage(widget.image),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context, true),
              child: ListTile(
                leading: const Icon(Icons.cake, color: Colors.blue),
                title: const Text("Sinh nhật"),
                subtitle: Text(birthDate != null ? "${birthDate!.day}/${birthDate!.month}/${birthDate!.year}" : "Chọn ngày"),
              ),
            ),
            GestureDetector(
              onTap: () => _selectDate(context, false),
              child: ListTile(
                leading: const Icon(Icons.home, color: Colors.blue),
                title: const Text("Ngày nhận nuôi"),
                subtitle: Text(adoptionDate != null ? "${adoptionDate!.day}/${adoptionDate!.month}/${adoptionDate!.year}" : "Chọn ngày"),
              ),
            ),
            const Spacer(),
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
                onPressed: _isButtonEnabled ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CaretakerScreen(
                        petType: widget.petType,
                        petBreed: widget.petBreed,
                        image: widget.image,
                        petName: widget.petName,
                        weight: widget.weight,
                        size: widget.size,
                        gender: widget.gender,
                        characteristics: widget.characteristics,
                        birthDate: birthDate,
                        adoptionDate: adoptionDate,
                      ),
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF254EDB),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Tiếp tục", style: TextStyle(color: Colors.white, fontSize: 16)),
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

              // Điều hướng đến màn hình tương ứng
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home'); // Trang chủ
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/'); // Đặt lịch
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/profile_screen'); // Hồ sơ (màn hình hiện tại)
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, '/'); // Chat
                  break;
                case 4:
                  Navigator.pushReplacementNamed(context, '/AccountScreen'); // Tài khoản
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
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text("Bước 6/7", style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 6 / 7,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
            minHeight: 4,
          ),
        ),
      ),
    );
  }
}
