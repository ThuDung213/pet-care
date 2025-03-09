import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy danh sách lịch làm việc của bác sĩ từ Firestore
  Future<List<Map<String, dynamic>>> getVetSchedules(String vetId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("vet_schedules")
        .where("vetId", isEqualTo: vetId)
        .get();

    return snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        "day": doc["day"],
        "startTime": _parseTime(doc["startTime"]),
        "endTime": _parseTime(doc["endTime"]),
        "isRecurring": doc["isRecurring"] ?? true,
        "closed": doc["closed"] ?? false,
      };
    }).toList();
  }

  /// Thêm hoặc cập nhật lịch làm việc của bác sĩ
  Future<void> addOrUpdateSchedule(
      String vetId, String day, String? startTime, String? endTime, bool closed) async {
    QuerySnapshot existingSchedules = await _firestore
        .collection("vet_schedules")
        .where("vetId", isEqualTo: vetId)
        .where("day", isEqualTo: day)
        .get();

    if (existingSchedules.docs.isNotEmpty) {
      await _firestore.collection("vet_schedules").doc(existingSchedules.docs.first.id).update({
        "startTime": closed ? "Unavailable" : startTime,
        "endTime": closed ? "Unavailable" : endTime,
        "isRecurring": true,
        "closed": closed,
      });
    } else {
      await _firestore.collection("vet_schedules").add({
        "vetId": vetId,
        "day": day,
        "startTime": closed ? "Unavailable" : startTime,
        "endTime": closed ? "Unavailable" : endTime,
        "isRecurring": true,
        "closed": closed,
      });
    }
  }

  /// Xóa một lịch làm việc cụ thể
  Future<void> deleteSchedule(String scheduleId) async {
    await _firestore.collection("vet_schedules").doc(scheduleId).delete();
  }

  /// Lưu lịch làm việc hàng tuần cho bác sĩ
  Future<void> saveWeeklySchedule(String vetId, Map<String, Map<String, dynamic>> weeklySchedule) async {
    WriteBatch batch = _firestore.batch();
    QuerySnapshot existingSchedules = await _firestore
        .collection("vet_schedules")
        .where("vetId", isEqualTo: vetId)
        .get();

    for (var doc in existingSchedules.docs) {
      batch.delete(doc.reference);
    }

    weeklySchedule.forEach((day, times) {
      DocumentReference newDoc = _firestore.collection("vet_schedules").doc();
      batch.set(newDoc, {
        "vetId": vetId,
        "day": day,
        "startTime": times["closed"] ? "Unavailable" : _formatTime(times["startTime"]),
        "endTime": times["closed"] ? "Unavailable" : _formatTime(times["endTime"]),
        "isRecurring": true,
        "closed": times["closed"],
      });
    });

    await batch.commit();
  }

  /// Lấy lịch làm việc hàng tuần của bác sĩ từ Firestore
  Future<Map<String, Map<String, dynamic>>> getWeeklySchedule(String vetId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("vet_schedules")
        .where("vetId", isEqualTo: vetId)
        .get();

    Map<String, Map<String, dynamic>> weeklySchedule = {};
    for (var doc in snapshot.docs) {
      TimeOfDay? startTime = _parseTime(doc["startTime"]);
      TimeOfDay? endTime = _parseTime(doc["endTime"]);

      weeklySchedule[doc["day"]] = {
        "startTime": startTime,
        "endTime": endTime,
        "closed": doc["closed"] ?? false,
      };

      if (startTime != null && endTime != null) {
        print("✅ ${doc["day"]} - Start: ${_formatTime(startTime)}, End: ${_formatTime(endTime)}");
      } else {
        print("❌ Error parsing time: ${doc["day"]}");
      }
    }
    return weeklySchedule;
  }

  /// Chia nhỏ các mốc thời gian cách nhau 30 phút
  List<TimeOfDay> generateTimeSlots(TimeOfDay start, TimeOfDay end) {
    List<TimeOfDay> slots = [];
    TimeOfDay current = start;

    while (_isBeforeOrEqual(current, end)) {
      slots.add(current);
      current = _addMinutes(current, 30);
    }

    return slots;
  }

  /// Chuyển đổi `String` thành `TimeOfDay`
  TimeOfDay? _parseTime(String? time) {
    if (time == null || time.isEmpty || time == "Unavailable") return null;

    try {
      List<String> parts = time.split(":");
      if (parts.length != 2) throw FormatException("Invalid time format");

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        throw FormatException("Time values out of range");
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print("❌ Error parsing time: $time - $e");
      return null;
    }
  }

  /// Chuyển đổi `TimeOfDay` thành `String`
  String _formatTime(TimeOfDay? time) {
    if (time == null) return "Unavailable";
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  /// Kiểm tra xem `TimeOfDay` hiện tại có trước hoặc bằng `end` không
  bool _isBeforeOrEqual(TimeOfDay current, TimeOfDay end) {
    return current.hour < end.hour || (current.hour == end.hour && current.minute <= end.minute);
  }

  /// Cộng thêm phút vào `TimeOfDay`
  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    int newMinutes = time.minute + minutes;
    int newHours = time.hour + (newMinutes ~/ 60);
    newMinutes = newMinutes % 60;
    return TimeOfDay(hour: newHours, minute: newMinutes);
  }
}
