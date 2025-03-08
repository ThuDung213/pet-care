import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> bookAppointment({
    required String userId,
    required String petId,
    required String vetId,
    required DateTime date,
    required String timeSlot,
  }) async {
    await _firestore.collection("appointments").add({
      "userId": userId,
      "petId": petId,
      "vetId": vetId,
      "date": Timestamp.fromDate(date),
      "timeSlot": timeSlot,
      "status": "pending", // Trạng thái mặc định là chờ xác nhận
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getAppointments(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("appointments")
        .where("userId", isEqualTo: userId)
        .orderBy("date", descending: false)
        .get();

    return snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        "userId": doc["userId"],
        "petId": doc["petId"],
        "vetId": doc["vetId"],
        "date": (doc["date"] as Timestamp).toDate(),
        "timeSlot": doc["timeSlot"],
        "status": doc["status"],
      };
    }).toList();
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await _firestore.collection("appointments").doc(appointmentId).update({
      "status": "cancelled",
    });
  }

  Future<List<String>> getAvailableTimeSlots(String vetId, DateTime selectedDate) async {
    String selectedDay = _getDayOfWeek(selectedDate);

    QuerySnapshot snapshot = await _firestore
        .collection("vet_schedules")
        .where("vetId", isEqualTo: vetId)
        .where("day", isEqualTo: selectedDay)
        .get();

    if (snapshot.docs.isEmpty || snapshot.docs.first["closed"] == true) {
      return []; // Bác sĩ không làm việc ngày này
    }

    String startTime = snapshot.docs.first["startTime"];
    String endTime = snapshot.docs.first["endTime"];

    return _generateTimeSlots(startTime, endTime);
  }

  List<String> _generateTimeSlots(String start, String end) {
    TimeOfDay startTime = _parseTime(start)!;
    TimeOfDay endTime = _parseTime(end)!;
    List<String> timeSlots = [];

    int startMinutes = startTime.hour * 60 + startTime.minute;
    int endMinutes = endTime.hour * 60 + endTime.minute;
    int step = 30; // Mỗi slot kéo dài 30 phút

    while (startMinutes + step <= endMinutes) {
      int hour = startMinutes ~/ 60;
      int minute = startMinutes % 60;
      String formattedTime = "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
      timeSlots.add(formattedTime);
      startMinutes += step;
    }

    return timeSlots;
  }

  String _getDayOfWeek(DateTime date) {
    List<String> days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    return days[date.weekday % 7]; // Lấy thứ từ DateTime
  }

  TimeOfDay? _parseTime(String time) {
    List<String> parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
