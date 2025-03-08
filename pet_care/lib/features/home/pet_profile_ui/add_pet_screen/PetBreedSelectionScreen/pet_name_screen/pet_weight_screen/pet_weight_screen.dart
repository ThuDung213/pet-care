import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pet_care/features/home/pet_profile_ui/add_pet_screen/PetBreedSelectionScreen/pet_name_screen/pet_weight_screen/SpecialCharacteristicsScreen/SpecialCharacteristicsScreen.dart';
import 'package:pet_care/widgets/bottom_nav_bar.dart';

class PetWeightScreen extends StatefulWidget {
  final String petType;
  final String petBreed;
  final File image;
  final String petName;

  const PetWeightScreen({
    Key? key,
    required this.petType,
    required this.petBreed,
    required this.image,
    required this.petName,
  }) : super(key: key);

  @override
  State<PetWeightScreen> createState() => _PetWeightScreenState();
}

class _PetWeightScreenState extends State<PetWeightScreen> {
  final TextEditingController _weightController = TextEditingController();
  String? _selectedSize;
  String? _selectedGender;
  int selectedIndex = 2;

  bool get _isButtonEnabled =>
      _weightController.text.isNotEmpty &&
          _selectedSize != null &&
          _selectedGender != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 80,
              backgroundImage: FileImage(widget.image),
            ),
            const SizedBox(height: 20),
            Text(
              widget.petType,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildWeightTextField(),
            const SizedBox(height: 20),
            _buildSizeDropdown(),
            const SizedBox(height: 20),
            _buildGenderSelector(),
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
                onPressed: _isButtonEnabled
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpecialCharacteristicsScreen(
                        petType: widget.petType,
                        petBreed: widget.petBreed,
                        image: widget.image,
                        petName: widget.petName,
                        weight: _weightController.text,
                        size: _selectedSize!,
                        gender: _selectedGender!,
                      ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF254EDB),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Tiếp tục",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 55),
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
              child: Text("Bước 4/7",
                  style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 4 / 7,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
            minHeight: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildWeightTextField() {
    return TextField(
      controller: _weightController,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: "Nhập cân nặng của thú cưng (kg)",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSizeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSize,
      decoration: InputDecoration(
        labelText: "Chọn kích thước",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: ["Nhỏ", "Vừa", "Lớn"]
          .map((size) => DropdownMenuItem(value: size, child: Text(size)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedSize = value;
        });
      },
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Chọn giới tính",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Radio<String>(
              value: "Đực",
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const Text("Đực"),
            const SizedBox(width: 20),
            Radio<String>(
              value: "Cái",
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const Text("Cái"),
          ],
        ),
      ],
    );
  }
}
