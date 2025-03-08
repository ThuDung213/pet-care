import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VetEditScheduleScreen extends StatefulWidget {
  const VetEditScheduleScreen({super.key});

  @override
  State<VetEditScheduleScreen> createState() => _VetEditScheduleScreenState();
}

class _VetEditScheduleScreenState extends State<VetEditScheduleScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  Map<String, Map<String, dynamic>> _weeklySchedule = {
    'Monday': {'startTime': null, 'endTime': null, 'closed': true},
    'Tuesday': {'startTime': null, 'endTime': null, 'closed': true},
    'Wednesday': {'startTime': null, 'endTime': null, 'closed': true},
    'Thursday': {'startTime': null, 'endTime': null, 'closed': true},
    'Friday': {'startTime': null, 'endTime': null, 'closed': true},
    'Saturday': {'startTime': null, 'endTime': null, 'closed': true},
    'Sunday': {'startTime': null, 'endTime': null, 'closed': true},
  };

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    String? vetId = _auth.currentUser?.uid;
    if (vetId == null) return;

    QuerySnapshot snapshot = await _firestore
        .collection("vet_schedules")
        .where("vetId", isEqualTo: vetId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      Map<String, Map<String, dynamic>> loadedSchedule = {};

      for (var doc in snapshot.docs) {
        String day = doc["day"];
        bool isClosed = doc["closed"] ?? false;

        loadedSchedule[day] = {
          "startTime": isClosed ? null : _parseTimeOfDay(doc["startTime"]),
          "endTime": isClosed ? null : _parseTimeOfDay(doc["endTime"]),
          "closed": isClosed,
        };
      }

      setState(() {
        _weeklySchedule = loadedSchedule;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  TimeOfDay? _parseTimeOfDay(String? time) {
    if (time == null || time.isEmpty) return null;
    List<String> parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _pickTime(String day, String timeType) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _weeklySchedule[day]?[timeType] ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _weeklySchedule[day]?["closed"] = false;
        _weeklySchedule[day]?[timeType] = pickedTime;
      });
    }
  }

  void _toggleClosed(String day) {
    setState(() {
      _weeklySchedule[day]?["closed"] = !(_weeklySchedule[day]?["closed"] as bool);
      if (_weeklySchedule[day]?["closed"] == true) {
        _weeklySchedule[day]?["startTime"] = null;
        _weeklySchedule[day]?["endTime"] = null;
      }
    });
  }

  void _saveSchedule() async {
    String? vetId = _auth.currentUser?.uid;
    if (vetId == null) return;

    WriteBatch batch = _firestore.batch();

    QuerySnapshot existingSchedules = await _firestore
        .collection("vet_schedules")
        .where("vetId", isEqualTo: vetId)
        .get();

    for (var doc in existingSchedules.docs) {
      batch.delete(doc.reference);
    }

    _weeklySchedule.forEach((day, times) {
      bool isClosed = times["closed"] as bool;
      DocumentReference newDoc = _firestore.collection("vet_schedules").doc();

      batch.set(newDoc, {
        "vetId": vetId,
        "day": day,
        "closed": isClosed,
        "startTime": isClosed ? "" : "${times["startTime"]!.hour}:${times["startTime"]!.minute}",
        "endTime": isClosed ? "" : "${times["endTime"]!.hour}:${times["endTime"]!.minute}",
        "isRecurring": true,
      });
    });

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lịch làm việc đã được lưu!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa lịch làm việc"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSchedule,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: _weeklySchedule.keys.map((day) {
          bool isClosed = _weeklySchedule[day]?["closed"] as bool;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text("Bận cả ngày"),
                    value: isClosed,
                    onChanged: (value) => _toggleClosed(day),
                  ),
                  if (!isClosed) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Giờ bắt đầu: ${_weeklySchedule[day]?["startTime"]?.format(context) ?? "Chưa chọn"}"),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _pickTime(day, "startTime"),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Giờ kết thúc: ${_weeklySchedule[day]?["endTime"]?.format(context) ?? "Chưa chọn"}"),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _pickTime(day, "endTime"),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
