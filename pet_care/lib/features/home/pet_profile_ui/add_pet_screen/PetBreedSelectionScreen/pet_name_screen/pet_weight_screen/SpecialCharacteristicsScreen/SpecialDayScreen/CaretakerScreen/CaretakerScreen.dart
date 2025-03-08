import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pet_care/features/home/pet_profile_ui/add_pet_screen/PetBreedSelectionScreen/pet_name_screen/pet_weight_screen/SpecialCharacteristicsScreen/SpecialDayScreen/CaretakerScreen/CompleteProfileScreen/CompleteProfileScreen.dart';
import 'package:pet_care/widgets/bottom_nav_bar.dart';


class CaretakerScreen extends StatefulWidget {
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

  const CaretakerScreen({
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
  }) : super(key: key);

  @override
  State<CaretakerScreen> createState() => _CaretakerScreenState();
}

class _CaretakerScreenState extends State<CaretakerScreen> {
  int selectedIndex = 2;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool get _isButtonEnabled =>
      nameController.text.isNotEmpty &&
      phoneController.text.isNotEmpty &&
      addressController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_updateButtonState);
    phoneController.addListener(_updateButtonState);
    addressController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {}); // Cập nhật UI khi nhập dữ liệu
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

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
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 80,
              backgroundImage: FileImage(widget.image),
            ),
            const SizedBox(height: 20),
            _buildTextField("Tên chủ nuôi*", controller: nameController),
            _buildTextField("SĐT*", controller: phoneController, keyboardType: TextInputType.phone),
            _buildTextField("Địa chỉ*", controller: addressController),
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
                      builder: (context) => CompleteProfileScreen(
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
                        ownerName: nameController.text,
                        ownerPhone: phoneController.text,
                        ownerAddress: addressController.text, 

                      ),
                    ),
                  );


                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled ? const Color(0xFF254EDB) : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Tiếp tục", style: TextStyle(color: Colors.white, fontSize: 16)),
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
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text("Bước 7/7", style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 7 / 7,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
            minHeight: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {TextEditingController? controller, bool enabled = true, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: enabled ? const Icon(Icons.edit, color: Colors.blue) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Chưa cập nhật";
    return "${date.day}/${date.month}/${date.year}";
  }
}
