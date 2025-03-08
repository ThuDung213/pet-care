import 'package:cloud_firestore/cloud_firestore.dart';

class VetSchedule {
  String id;
  String vetId;
  List<AvailableDate> availableSlots;
  DateTime updatedAt;

  VetSchedule({
    required this.id,
    required this.vetId,
    required this.availableSlots,
    required this.updatedAt,
  });

  factory VetSchedule.fromMap(String id, Map<String, dynamic> data) {
    return VetSchedule(
      id: id,
      vetId: data['vetId'],
      availableSlots: (data['availableSlots'] as List)
          .map((e) => AvailableDate.fromMap(e))
          .toList(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vetId': vetId,
      'availableSlots': availableSlots.map((e) => e.toMap()).toList(),
      'updatedAt': updatedAt,
    };
  }
}

class AvailableDate {
  String date;
  List<TimeSlot> slots;

  AvailableDate({
    required this.date,
    required this.slots,
  });

  factory AvailableDate.fromMap(Map<String, dynamic> data) {
    return AvailableDate(
      date: data['date'],
      slots: (data['slots'] as List)
          .map((e) => TimeSlot.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'slots': slots.map((e) => e.toMap()).toList(),
    };
  }
}

class TimeSlot {
  String time;
  String status;

  TimeSlot({
    required this.time,
    required this.status,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> data) {
    return TimeSlot(
      time: data['time'],
      status: data['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'status': status,
    };
  }
}
