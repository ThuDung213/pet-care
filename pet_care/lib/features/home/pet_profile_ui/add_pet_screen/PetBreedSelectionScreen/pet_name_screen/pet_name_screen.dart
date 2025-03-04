import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care/features/home/pet_profile_ui/add_pet_screen/PetBreedSelectionScreen/pet_name_screen/pet_weight_screen/pet_weight_screen.dart';
import 'package:pet_care/widgets/bottom_nav_bar.dart';


class PetNameScreen extends StatefulWidget {
  final String petBreed;
  final String petType; // Thêm loại thú cưng

  const PetNameScreen({
    super.key,
    required this.petBreed,
    required this.petType,
  });

  @override
  State<PetNameScreen> createState() => _PetNameScreenState();
}


class _PetNameScreenState extends State<PetNameScreen> {
  File? _image;
  final TextEditingController _nameController = TextEditingController();
  int selectedIndex = 2;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

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
            _buildImagePicker(),
            const SizedBox(height: 10),
            Text(widget.petBreed, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 45),
            _buildTextField(),
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
                onPressed: (_image == null || _nameController.text.isEmpty) ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetWeightScreen(
                        petType: widget.petType,  
                        petBreed: widget.petBreed, 
                        image: _image!,                
                        petName: _nameController.text,  
                      ),
                    ),
                  );



                },
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
              child: Text("Bước 3/7", style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 3 / 7,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellow),
            minHeight: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 100,
        backgroundImage: _image != null ? FileImage(_image!) : null,
        child: _image == null
            ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _nameController,
      onChanged: (value) {
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: "Tên thú cưng của bạn",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}