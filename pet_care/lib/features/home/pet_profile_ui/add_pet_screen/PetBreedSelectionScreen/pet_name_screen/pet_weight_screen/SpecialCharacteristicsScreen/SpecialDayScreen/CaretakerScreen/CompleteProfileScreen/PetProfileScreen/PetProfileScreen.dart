import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pet_care/data/repositories/pet_profile_repository.dart';
import 'package:pet_care/features/home/pet_profile_ui/profile_screen.dart';
import 'package:pet_care/widgets/bottom_nav_bar.dart';

import '../../../../../../../../../../../vet_home/vet_booking_ui/vet_booking_screen.dart';

class PetProfileScreen extends StatefulWidget {
  final String petId; // Nhận petId từ CompleteProfileScreen hoặc ProfileScreen
  final bool isVet; // Thêm biến để xác định người dùng là vet hay không

  const PetProfileScreen({Key? key, required this.petId, this.isVet = false}) : super(key: key);

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  bool isEditing = false;

  // Controllers cho các trường chỉnh sửa
  late TextEditingController petNameController;
  late TextEditingController petBreedController;
  late TextEditingController weightController;
  late TextEditingController ownerNameController;
  late TextEditingController ownerPhoneController;
  late TextEditingController ownerAddressController;

  String selectedSize = "";
  String selectedGender = "";
  List<String> selectedCharacteristics = [];
  DateTime? birthDate;
  DateTime? adoptionDate;
  String currentImageUrl = "";
  int selectedIndex = 2;

  // Tùy chọn Dropdown
  final List<String> sizeOptions = ["Nhỏ", "Vừa", "Lớn"];
  final List<String> genderOptions = ["Đực", "Cái"];
  final List<String> characteristicsOptions = [
    "Đã triệt sản",
    "Đuôi cụp",
    "Mắt hai màu",
    "Lông xoăn",
    "Lông thẳng",
    "Lông ngắn",
    "Lông dài",
    "Có sẹo"
  ];

  final PetProfileRepository repository = PetProfileRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    petNameController = TextEditingController();
    petBreedController = TextEditingController();
    weightController = TextEditingController();
    ownerNameController = TextEditingController();
    ownerPhoneController = TextEditingController();
    ownerAddressController = TextEditingController();
  }

  @override
  void dispose() {
    petNameController.dispose();
    petBreedController.dispose();
    weightController.dispose();
    ownerNameController.dispose();
    ownerPhoneController.dispose();
    ownerAddressController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Chưa cập nhật";
    return DateFormat("dd/MM/yyyy").format(date);
  }

  Future<void> _pickPetImage() async {
    String? newUrl = await repository.pickPetImage();
    if (newUrl != null) {
      setState(() {
        currentImageUrl = newUrl;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isBirth) async {
    final initialDate = isBirth ? (birthDate ?? DateTime.now()) : (adoptionDate ?? DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isBirth) {
          birthDate = picked;
        } else {
          adoptionDate = picked;
        }
      });
    }
  }

  Future<void> _updatePetData() async {
    bool success = await repository.updatePetData(
      petId: widget.petId,
      petName: petNameController.text,
      petBreed: petBreedController.text,
      weight: weightController.text,
      selectedSize: selectedSize,
      selectedGender: selectedGender,
      selectedCharacteristics: selectedCharacteristics,
      birthDate: birthDate,
      adoptionDate: adoptionDate,
      ownerName: ownerNameController.text,
      ownerPhone: ownerPhoneController.text,
      ownerAddress: ownerAddressController.text,
      imageUrl: currentImageUrl,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thành công!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thất bại!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference docRef = FirebaseFirestore.instance.collection('pets').doc(widget.petId);

    return Scaffold(
      appBar: AppBar(
        // Nút Back chuyển hướng về trang phù hợp
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.isVet) {
              // Nếu là vet, quay lại màn hình trước đó
              Navigator.pop(context);
            } else {
              // Nếu là chủ thú cưng, quay lại ProfileScreen
              Navigator.pop(context);
            }
          },
        ),
        title: const Text("Hồ sơ thú cưng", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Chỉ hiển thị nút chỉnh sửa nếu người dùng là chủ thú cưng
          if (!widget.isVet)
            IconButton(
              icon: Icon(isEditing ? Icons.done : Icons.edit),
              onPressed: () async {
                if (isEditing) {
                  // Khi bấm Done trong chế độ edit, cập nhật dữ liệu lên Firebase
                  await _updatePetData();
                }
                setState(() {
                  isEditing = !isEditing;
                });
              },
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Nếu không đang chỉnh sửa, cập nhật các controller và biến trạng thái từ Firestore
          if (!isEditing) {
            petNameController.text = data['petName'] ?? "";
            petBreedController.text = data['petBreed'] ?? "";
            weightController.text = data['weight'] ?? "";
            selectedSize = data['size'] ?? "";
            selectedGender = data['gender'] ?? "";
            selectedCharacteristics = data['characteristics'] != null
                ? List<String>.from(data['characteristics'])
                : [];
            birthDate = data['birthDate'] != null ? DateTime.tryParse(data['birthDate']) : null;
            adoptionDate = data['adoptionDate'] != null ? DateTime.tryParse(data['adoptionDate']) : null;
            ownerNameController.text = data['ownerName'] ?? "";
            ownerPhoneController.text = data['ownerPhone'] ?? "";
            ownerAddressController.text = data['ownerAddress'] ?? "";
            currentImageUrl = data['imageUrl'] ?? "";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: isEditing
                ? _buildEditView(currentImageUrl)
                : _buildProfileView(currentImageUrl, data['petType'] ?? "Chó"),
          );
        },
      ),
    );
  }

  // Widget dùng chung: tiêu đề cho mỗi phần
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget dùng chung: TextField cho chế độ edit
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // Widget dùng chung: hiển thị thông tin ngày kèm icon (chế độ xem)
  Widget _buildDateRow(String label, DateTime? date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.event, color: Colors.blue),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(_formatDate(date), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget dùng chung: hiển thị dòng chọn ngày trong chế độ edit
  Widget _buildDatePickerRow(DateTime? date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _formatDate(date),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
        ],
      ),
    );
  }

  // Widget dùng chung: hiển thị 1 dòng thông tin (chế độ xem)
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

  // Widget hiển thị giao diện chỉnh sửa
  Widget _buildEditView(String imageUrl) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickPetImage,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 95,
                backgroundImage: currentImageUrl.isNotEmpty
                    ? NetworkImage(currentImageUrl)
                    : const AssetImage('assets/dog_avatar.png') as ImageProvider,
              ),
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField("Tên thú cưng", petNameController),
        _buildTextField("Giống", petBreedController),
        _buildTextField("Cân nặng (kg)", weightController),
        const SizedBox(height: 8),
        _buildSectionTitle("Kích cỡ"),
        DropdownButton<String>(
          isExpanded: true,
          value: selectedSize,
          items: sizeOptions
              .map((e) => DropdownMenuItem<String>(
            value: e,
            child: Text(e),
          ))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedSize = val ?? "";
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle("Giới tính"),
        DropdownButton<String>(
          isExpanded: true,
          value: selectedGender,
          items: genderOptions
              .map((e) => DropdownMenuItem<String>(
            value: e,
            child: Text(e),
          ))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedGender = val ?? "";
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle("Đặc điểm"),
        Wrap(
          spacing: 8.0,
          children: characteristicsOptions.map((option) {
            final isSelected = selectedCharacteristics.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedCharacteristics.add(option);
                  } else {
                    selectedCharacteristics.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle("Sinh nhật"),
        InkWell(
          onTap: () => _selectDate(context, true),
          child: _buildDatePickerRow(birthDate),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle("Ngày nhận nuôi"),
        InkWell(
          onTap: () => _selectDate(context, false),
          child: _buildDatePickerRow(adoptionDate),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle("Người chăm sóc"),
        _buildTextField("Tên chủ", ownerNameController),
        _buildTextField("SĐT", ownerPhoneController),
        _buildTextField("Địa chỉ", ownerAddressController),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF254EDB),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await _updatePetData();
              setState(() {
                isEditing = false;
              });
            },
            child: const Text("Hoàn tất", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  // Widget hiển thị giao diện xem thông tin
  Widget _buildProfileView(String imageUrl, String petTypeFromData) {
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 95,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : const AssetImage('assets/dog_avatar.png') as ImageProvider,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          petNameController.text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "$petTypeFromData | ${petBreedController.text}",
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        _buildSectionTitle("Đặc điểm"),
        _buildInfoRow("Giới tính", selectedGender),
        _buildInfoRow("Kích cỡ", selectedSize),
        _buildInfoRow("Cân nặng", "${weightController.text} kg"),
        _buildInfoRow(
          "Mô tả",
          selectedCharacteristics.isNotEmpty ? selectedCharacteristics.join(", ") : "Chưa cập nhật",
        ),
        const SizedBox(height: 16),
        _buildSectionTitle("Ngày quan trọng"),
        _buildDateRow("Sinh nhật", birthDate),
        _buildDateRow("Ngày nhận nuôi", adoptionDate),
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
                  ownerNameController.text,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  ownerPhoneController.text,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            ownerAddressController.text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}