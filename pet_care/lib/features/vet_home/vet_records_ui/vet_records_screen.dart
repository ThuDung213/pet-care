import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/features/vet_home/vet_records_ui/vet_record_single_screen/vet_record_single_screen.dart';
import '../../../../data/repositories/vet_record_repository.dart'; // Import VetRecordRepository
import '../../../../data/repositories/pet_repository.dart'; // Import PetRepository
import '../../../../data/model/pet_list.dart'; // Import PetModel

class VetRecordsScreen extends StatelessWidget {
  final String vetId; // ID của vet

  const VetRecordsScreen({Key? key, required this.vetId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VetRecordRepository _vetRecordRepository = VetRecordRepository();
    final PetRepository _petRepository = PetRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ bác sĩ"), // Đổi tiêu đề thành "Hồ sơ bác sĩ"
        backgroundColor: Colors.blue, // Màu nền của AppBar
        elevation: 0, // Bỏ đổ bóng
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _vetRecordRepository.getRecordsByVetId(vetId), // Sử dụng phương thức từ repository
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Không có bản ghi nào.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          final records = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0), // Thêm padding cho ListView
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final recordId = record['id'];
              final diagnosis = record['diagnosis'];
              final treatment = record['treatment'];
              final note = record['note'];
              final recordImg = record['recordImg'] as List<dynamic>;
              final createdAt = (record['createdAt'] as Timestamp).toDate();
              final petId = record['petId']; // Lấy petId từ record

              // Sử dụng FutureBuilder để lấy thông tin thú cưng
              return FutureBuilder<PetModel?>(
                future: _petRepository.getPetById(petId), // Lấy thông tin thú cưng
                builder: (context, petSnapshot) {
                  if (petSnapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (!petSnapshot.hasData || petSnapshot.data == null) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Không tìm thấy thông tin thú cưng."),
                      ),
                    );
                  }

                  final pet = petSnapshot.data!;
                  final petName = pet.petName ?? "Không có tên";
                  final ownerName = pet.ownerName ?? "Không có tên chủ";

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0), // Khoảng cách giữa các Card
                    elevation: 2, // Độ đổ bóng của Card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bo góc
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12), // Bo góc cho hiệu ứng khi nhấn
                      onTap: () {
                        // Chuyển đến màn hình chi tiết
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VetRecordSingleScreen(
                              recordId: recordId,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hiển thị tên pet làm tiêu đề lớn
                            Text(
                              "Bệnh nhân: $petName",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8), // Khoảng cách giữa các dòng
                            // Hiển thị tên chủ
                            Text(
                              "Chủ: $ownerName",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Hiển thị ngày khám
                            Text(
                              "Ngày khám: ${createdAt.toLocal()}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12), // Khoảng cách giữa thông tin và ảnh
                            // Hiển thị ảnh đầu tiên (nếu có)
                            if (recordImg.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  recordImg.first,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 12), // Khoảng cách giữa ảnh và nội dung
                            // Hiển thị chẩn đoán
                            Text(
                              "Chẩn đoán: $diagnosis",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8), // Khoảng cách giữa các dòng
                            // Hiển thị điều trị
                            Text(
                              "Điều trị: $treatment",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Hiển thị ghi chú
                            Text(
                              "Ghi chú: $note",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}