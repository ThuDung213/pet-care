import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class VetNotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? vet = FirebaseAuth.instance.currentUser;
    if (vet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thông báo')),
        body: const Center(child: Text("Vui lòng đăng nhập để xem thông báo")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo Bác Sĩ'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('vetId', isEqualTo: vet.uid)
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Không có thông báo nào."));
            }

            final appointments = snapshot.data!.docs;

            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                var appointmentData =
                appointments[index].data() as Map<String, dynamic>;
                return FutureBuilder<Map<String, String>>(
                  future: _fetchUserAndPetInfo(
                    appointmentData['userId'],
                    appointmentData['petId'],
                  ),
                  builder: (context, userPetSnapshot) {
                    if (!userPetSnapshot.hasData) {
                      return const SizedBox(); // Ẩn nếu chưa có dữ liệu
                    }

                    String userName = userPetSnapshot.data!['userName'] ?? "Người dùng";
                    String petName = userPetSnapshot.data!['petName'] ?? "thú cưng";
                    String time = appointmentData['time'] ?? "không rõ";
                    String status = appointmentData['status'] ?? "pending";
                    String date = DateFormat('dd/MM/yyyy').format(
                      (appointmentData['date'] as Timestamp).toDate(),
                    );

                    // Nội dung thông báo
                    String message;
                    if (status == "pending") {
                      message =
                      "$userName đã đặt lịch cho $petName vào $time. Vui lòng xác nhận!";
                    } else if (status == "confirmed") {
                      message =
                      "Bạn đã xác nhận lịch hẹn của $userName ($petName) vào $time.";
                    } else if (status == "cancelled") {
                      message =
                      "Lịch hẹn với $userName ($petName) vào $time đã bị hủy.";
                    } else {
                      message =
                      "Cập nhật mới về lịch hẹn với $userName ($petName).";
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            date == DateFormat('dd/MM/yyyy').format(DateTime.now())
                                ? "Hôm nay"
                                : date,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildNotificationCard(
                          _getIconForStatus(status),
                          message,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Hàm lấy tên User và tên Pet từ Firestore
  Future<Map<String, String>> _fetchUserAndPetInfo(String userId, String petId) async {
    String userName = "Người dùng";
    String petName = "Thú cưng";

    try {
      // Lấy userName từ Firestore
      var userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        userName = userSnapshot.data()?['name'] ?? "Người dùng";
      }

      // Lấy petName từ Firestore
      var petSnapshot = await FirebaseFirestore.instance.collection('pets').doc(petId).get();
      if (petSnapshot.exists) {
        petName = petSnapshot.data()?['petName'] ?? "Thú cưng";
      }
    } catch (e) {
      print("Lỗi khi lấy thông tin user hoặc pet: $e");
    }

    return {'userName': userName, 'petName': petName};
  }

  /// Icon phù hợp với trạng thái lịch hẹn
  IconData _getIconForStatus(String status) {
    if (status == "pending") {
      return LucideIcons.clock;
    } else if (status == "confirmed") {
      return LucideIcons.checkCircle;
    } else if (status == "cancelled") {
      return LucideIcons.xCircle;
    }
    return LucideIcons.bell;
  }

  /// UI của thông báo
  Widget _buildNotificationCard(IconData icon, String text) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
