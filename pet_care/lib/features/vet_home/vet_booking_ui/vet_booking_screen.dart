import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/appointment_repository.dart'; // Import repository
import '../../../data/repositories/pet_repository.dart'; // Import PetRepository
import '../../../data/model/pet_list.dart'; // Import PetModel
import '../../../data/repositories/vet_record_repository.dart';
import '../../home/pet_profile_ui/add_pet_screen/PetBreedSelectionScreen/pet_name_screen/pet_weight_screen/SpecialCharacteristicsScreen/SpecialDayScreen/CaretakerScreen/CompleteProfileScreen/PetProfileScreen/PetProfileScreen.dart';
import '../vet_booking_ui/vet_edit_schedule_screen/vet_edit_schedule_screen.dart';

class VetBookingScreen extends StatelessWidget {
  const VetBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String vetId = FirebaseAuth.instance.currentUser?.uid ?? "";
    final AppointmentRepository appointmentRepository = AppointmentRepository(); // Khởi tạo repository
    final PetRepository petRepository = PetRepository(); // Khởi tạo PetRepository

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch hẹn"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VetEditScheduleScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: appointmentRepository.getVetAppointments(vetId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print("No appointments found for vetId: $vetId");
            print("Snapshot data: ${snapshot.data}"); // In ra dữ liệu snapshot
            return const Center(child: Text("Không có lịch hẹn nào."));
          }

          final appointments = snapshot.data!;
          print("Appointments: $appointments"); // In ra danh sách lịch hẹn

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final appointmentId = appointment['id'];
              final userId = appointment['userId'];
              final petId = appointment['petId']; // Lấy petId từ dữ liệu
              final date = (appointment['date'] as Timestamp).toDate().toString();
              final time = appointment['time'];
              final isConfirmed = appointment['isConfirmed'] ?? false; // Trạng thái xác nhận

              // Sử dụng StreamBuilder để lấy thông tin thú cưng từ petId
              return StreamBuilder<List<PetModel>>(
                stream: petRepository.getAllPets(), // Hoặc getUserPets(userId) nếu bạn muốn lọc theo userId
                builder: (context, petSnapshot) {
                  if (petSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text("Đang tải thông tin thú cưng..."),
                    );
                  }
                  if (!petSnapshot.hasData || petSnapshot.data!.isEmpty) {
                    return const ListTile(
                      title: Text("Không tìm thấy thông tin thú cưng."),
                    );
                  }

                  // Tìm thú cưng có petId trùng khớp
                  final pet = petSnapshot.data!.firstWhere(
                        (pet) => pet.docId == petId,
                    orElse: () => PetModel(docId: '', petName: '', petBreed: '', imageUrl: '', ownerName: '', gender: '', petType: ''), // Giá trị mặc định nếu không tìm thấy
                  );

                  return GestureDetector(
                    onTap: () {
                      // Chuyển hướng đến PetProfileScreen với petId
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetProfileScreen(petId: petId, isVet: true),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: pet.imageUrl.isNotEmpty
                              ? NetworkImage(pet.imageUrl) // Hiển thị hình ảnh từ URL
                              : null, // Nếu không có hình ảnh
                          child: pet.imageUrl.isEmpty
                              ? const Icon(Icons.pets) // Biểu tượng mặc định nếu không có hình ảnh
                              : null,
                        ),
                        title: Text("Lịch hẹn với: ${pet.petName}"),
                        subtitle: Text("Ngày: $date - Giờ: $time"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isConfirmed ? Colors.green : Colors.blue, // Màu nền của nút
                            foregroundColor: Colors.white, // Màu chữ của nút
                          ),
                          onPressed: isConfirmed
                              ? null // Vô hiệu hóa nút nếu đã xác nhận
                              : () {
                            _showSimpleConfirmationDialog(
                              context,
                              appointmentId,
                              userId,
                              vetId,
                              petId,
                              DateTime.parse(date), // Chuyển đổi date thành DateTime
                            );
                          },
                          child: Text(isConfirmed ? "Đã xác nhận" : "Xác nhận"),
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

  void _showSimpleConfirmationDialog(
      BuildContext context,
      String appointmentId,
      String userId,
      String vetId,
      String petId,
      DateTime appointmentDate,
      ) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận lịch hẹn"),
          content: const Text("Bạn có chắc chắn muốn xác nhận lịch hẹn này không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // Xác nhận lịch hẹn
                final AppointmentRepository appointmentRepository = AppointmentRepository();
                await appointmentRepository.confirmAppointment(appointmentId);

                // Tạo PetRecord rỗng
                final VetRecordRepository vetRecordRepository = VetRecordRepository();
                await vetRecordRepository.createPetRecord(
                  userId: userId,
                  vetId: vetId,
                  petId: petId,
                  appointmentId: appointmentId,
                  appointmentDate: appointmentDate,
                );

                // Đóng hộp thoại
                Navigator.pop(context);

                // Hiển thị thông báo thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Lịch hẹn đã được xác nhận và PetRecord đã được tạo!")),
                );
              },
              child: const Text("Có"),
            ),
          ],
        );
      },
    );
  }
}