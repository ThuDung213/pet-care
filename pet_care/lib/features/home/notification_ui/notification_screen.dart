import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thông báo')),
        body: const Center(child: Text("Vui lòng đăng nhập để xem thông báo")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('userId', isEqualTo: user.uid)
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Không có thông báo nào."));
            }

            final List<Map<String, dynamic>> appointments =
            snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList();

            // Nhóm thông báo theo ngày
            Map<String, List<Map<String, dynamic>>> groupedAppointments = {};
            for (var data in appointments) {
              String dateKey = DateFormat('dd/MM/yyyy')
                  .format((data['date'] as Timestamp).toDate());
              groupedAppointments.putIfAbsent(dateKey, () => []).add(data);
            }

            return ListView(
              children: groupedAppointments.entries.map((entry) {
                String date = entry.key;
                List<Map<String, dynamic>> items = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date == DateFormat('dd/MM/yyyy').format(DateTime.now())
                          ? "Hôm nay"
                          : date,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: items.map((data) {
                        String vetName = data['vetName'] ?? "bác sĩ";
                        String status = data['status'] ?? "pending";
                        String time = data['time'] ?? "không rõ";

                        // Nội dung thông báo
                        String message;
                        if (status == "pending") {
                          message =
                          "Bạn đã đặt lịch với bác sĩ $vetName vào $time. Hãy chờ xác nhận!";
                        } else if (status == "confirmed") {
                          message =
                          "Bác sĩ $vetName đã xác nhận lịch hẹn của bạn vào $time!";
                        } else if (status == "cancelled") {
                          message =
                          "Lịch hẹn với bác sĩ $vetName vào $time đã bị hủy.";
                        } else {
                          message =
                          "Cập nhật mới về lịch hẹn với bác sĩ $vetName.";
                        }

                        return _buildNotificationCard(
                          _getIconForStatus(status),
                          message,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  /// Trả về icon phù hợp với trạng thái của lịch hẹn
  IconData _getIconForStatus(String status) {
    if (status == "pending") {
      return LucideIcons.clock; // Đang chờ xác nhận
    } else if (status == "confirmed") {
      return LucideIcons.checkCircle; // Đã xác nhận
    } else if (status == "cancelled") {
      return LucideIcons.xCircle; // Đã hủy
    }
    return LucideIcons.bell; // Mặc định
  }

  /// Tạo thẻ thông báo UI
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
