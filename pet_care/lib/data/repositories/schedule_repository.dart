import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getVetSchedules(String vetId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("vet_schedules")
        .where("vetId", isEqualTo: vetId)
        .get();
    return snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        "day": doc["day"],
        "startTime": doc["startTime"],
        "endTime": doc["endTime"],
        "isRecurring": doc["isRecurring"] ?? true,
        "closed": doc["closed"] ?? false,
      };
    }).toList();
  }

  Future<void> addOrUpdateSchedule(String vetId, String day, String? startTime, String? endTime, bool closed) async {
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

  Future<void> deleteSchedule(String scheduleId) async {
    await _firestore.collection("vet_schedules").doc(scheduleId).delete();
  }

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
        "startTime": times["closed"] ? "Unavailable" : (times["startTime"] != null ? "${times["startTime"].hour}:${times["startTime"].minute}" : "Unavailable"),
        "endTime": times["closed"] ? "Unavailable" : (times["endTime"] != null ? "${times["endTime"].hour}:${times["endTime"].minute}" : "Unavailable"),
        "isRecurring": true,
        "closed": times["closed"],
      });
    });

    await batch.commit();
  }

  Future<Map<String, Map<String, dynamic>>> getWeeklySchedule(String vetId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("vet_schedules")
        .where("vetId", isEqualTo: vetId)
        .get();

    Map<String, Map<String, dynamic>> weeklySchedule = {};
    for (var doc in snapshot.docs) {
      weeklySchedule[doc["day"]] = {
        "startTime": _parseTime(doc["startTime"]),
        "endTime": _parseTime(doc["endTime"]),
        "closed": doc["closed"] ?? false,
      };
    }
    return weeklySchedule;
  }

  TimeOfDay? _parseTime(String? time) {
    if (time == null || time == "Unavailable") return null;
    List<String> parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
