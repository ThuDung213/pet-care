import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/repositories/vet_record_repository.dart';
import '../../../../data/repositories/pet_repository.dart'; // Import PetRepository
import '../../../../data/repositories/auth_repository.dart'; // Import AuthRepository
import '../../../../data/model/pet_list.dart'; // Import PetModel
import '../../../../data/model/user_model.dart'; // Import UserModel

class VetRecordSingleScreen extends StatefulWidget {
  final String recordId;

  const VetRecordSingleScreen({Key? key, required this.recordId})
      : super(key: key);

  @override
  _VetRecordSingleScreenState createState() => _VetRecordSingleScreenState();
}

class _VetRecordSingleScreenState extends State<VetRecordSingleScreen> {
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<String> _recordImages = [];
  final VetRecordRepository _vetRecordRepository = VetRecordRepository();
  final PetRepository _petRepository = PetRepository();
  final AuthRepository _authRepository = AuthRepository();
  bool _isEditing = false;
  DateTime? _createdAt; // Ngày khám
  String? _petId; // ID của pet
  PetModel? _pet; // Thông tin pet
  UserModel? _currentUser; // Thông tin người dùng hiện tại

  @override
  void initState() {
    super.initState();
    _loadRecordData();
    _loadCurrentUser();
  }

  // Tải dữ liệu từ Firestore
  Future<void> _loadRecordData() async {
    try {
      // Lấy thông tin record từ VetRecordRepository
      final recordData =
          await _vetRecordRepository.getCurrentRecord(widget.recordId);
      if (recordData != null) {
        _diagnosisController.text = recordData['diagnosis'] ?? '';
        _treatmentController.text = recordData['treatment'] ?? '';
        _noteController.text = recordData['note'] ?? '';
        _createdAt = (recordData['createdAt'] as Timestamp).toDate();
        _petId = recordData['petId'];
        setState(() {
          _recordImages = List<String>.from(recordData['recordImg'] ?? []);
        });

        // Lấy thông tin pet từ PetRepository
        if (_petId != null) {
          final pet = await _petRepository.getPetById(_petId!);
          setState(() {
            _pet = pet;
          });
        }
      }
    } catch (e) {
      print("Lỗi khi tải dữ liệu: $e");
    }
  }

  // Lấy thông tin người dùng hiện tại
  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      print("Lỗi khi lấy thông tin người dùng: $e");
    }
  }

  // Chọn nhiều ảnh
  Future<void> _pickMultipleImages() async {
    final List<XFile> images = await _vetRecordRepository.pickMultipleImages();
    if (images.isNotEmpty) {
      final List<String> imageUrls =
          await _vetRecordRepository.uploadImages(images);
      setState(() {
        _recordImages.addAll(imageUrls);
      });
    }
  }

  // Lưu thay đổi vào Firestore
  Future<void> _saveRecord() async {
    try {
      await _vetRecordRepository.updatePetRecord(
        recordId: widget.recordId,
        diagnosis: _diagnosisController.text,
        treatment: _treatmentController.text,
        note: _noteController.text,
        recordImg: _recordImages,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã lưu thay đổi!")),
      );
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      print("Lỗi khi lưu thay đổi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi lưu thay đổi!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ bệnh án"),
        backgroundColor: Colors.blue.shade100, // Màu nhẹ nhàng
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing
                ? _saveRecord
                : () => setState(() => _isEditing = true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị ngày khám
            if (_createdAt != null)
              Card(
                elevation: 4,
                color: Colors.blue.shade50, // Màu nền nhẹ nhàng
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        "Hồ sơ ngày ${_createdAt!.toLocal().toString().split(' ')[0]}", // Lấy ngày (bỏ qua giờ)
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Thông tin cá nhân
            if (_pet != null)
              Card(
                elevation: 4,
                color: Colors.blue.shade50, // Màu nền nhẹ nhàng
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Thông tin cá nhân",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow("Tên pet", _pet!.petName),
                      _buildInfoRow("Loại pet", _pet!.petType),
                      _buildInfoRow("Giới tính", _pet!.gender),
                      _buildInfoRow("Giống", _pet!.petBreed),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Chủ
            if (_currentUser != null)
              Card(
                elevation: 4,
                color: Colors.blue.shade50, // Màu nền nhẹ nhàng
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Chủ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow("Tên", _currentUser!.name),
                      _buildInfoRow("Điện thoại", _currentUser!.phone),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Chẩn đoán
            _buildSection("Chẩn đoán", _diagnosisController, _isEditing),
            const SizedBox(height: 20),
            // Điều trị
            _buildSection("Điều trị", _treatmentController, _isEditing),
            const SizedBox(height: 20),
            // Ghi chú
            _buildSection("Ghi chú", _noteController, _isEditing),
            const SizedBox(height: 20),
            // Ảnh
            if (_recordImages.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ảnh:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: _recordImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Xem ảnh lớn khi nhấn vào
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: Image.network(_recordImages[index]),
                            ),
                          );
                        },
                        child: Image.network(_recordImages[index],
                            fit: BoxFit.cover),
                      );
                    },
                  ),
                ],
              ),
            if (_isEditing)
              ElevatedButton(
                onPressed: _pickMultipleImages,
                child: const Text("Thêm ảnh"),
              ),
          ],
        ),
      ),
    );
  }

  // Hàm xây dựng một hàng thông tin
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm xây dựng một phần thông tin (chẩn đoán, điều trị, ghi chú)
  Widget _buildSection(
      String title, TextEditingController controller, bool isEditing) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            isEditing
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Nhập $title",
                    ),
                  )
                : Text(
                    controller.text.isEmpty
                        ? "Không có dữ liệu"
                        : controller.text,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
          ],
        ),
      ),
    );
  }
}
