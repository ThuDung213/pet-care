import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentRepository {
  final CollectionReference appointments =
      FirebaseFirestore.instance.collection('appointments');

  /// Đặt lịch hẹn (mặc định chưa xác nhận)
  Future<void> bookAppointment({
    required String userId,
    required String petId,
    required String vetId,
    required String vetName,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    try {
      await appointments.add({
        'userId': userId,
        'petId': petId,
        'vetId': vetId,
        'vetName': vetName,
        'date': Timestamp.fromDate(date),
        'time': '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        'status': 'pending', // Trạng thái ban đầu
        'isConfirmed': false, // Mặc định chưa xác nhận
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      print("Lỗi khi đặt lịch hẹn: $e");
    }
  }

  /// Cập nhật trạng thái xác nhận (bác sĩ xác nhận)
  Future<void> confirmAppointment(String appointmentId) async {
    try {
      await appointments.doc(appointmentId).update({
        'isConfirmed': true,
        'status': 'confirmed',
      });
    } catch (e) {
      print("Lỗi khi xác nhận lịch hẹn: $e");
    }
  }

  /// Hủy lịch hẹn
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await appointments.doc(appointmentId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      print("Lỗi khi hủy lịch hẹn: $e");
    }
  }

  /// Lấy danh sách lịch hẹn của một người dùng
  Stream<List<Map<String, dynamic>>> getUserAppointments(String userId) {
    return appointments
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id; // Thêm ID của document vào dữ liệu
              return data;
            }).toList());
  }

  /// Lấy danh sách lịch hẹn của bác sĩ thú y
  Stream<List<Map<String, dynamic>>> getVetAppointments(String? vetId) {
    return appointments
        .where('vetId', isEqualTo: vetId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id; // Thêm ID của document vào dữ liệu
              return data;
            }).toList());
  }
}
