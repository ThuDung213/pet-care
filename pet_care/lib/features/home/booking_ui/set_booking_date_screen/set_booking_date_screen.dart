import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/repositories/schedule_repository.dart';
import 'choose_pet_booking_screen/choose_pet_booking_screen.dart';

class SetBookingDateScreen extends StatefulWidget {
  final String vetName;
  final String address;
  final double rating;
  final String image;
  final String vetId;
  final String specialization;

  const SetBookingDateScreen({
    Key? key,
    required this.vetName,
    required this.address,
    required this.rating,
    required this.image,
    required this.vetId,
    required this.specialization,
  }) : super(key: key);



  @override
  _SetBookingDateScreenState createState() => _SetBookingDateScreenState();
}

class _SetBookingDateScreenState extends State<SetBookingDateScreen> {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  Map<String, List<TimeOfDay>> availableTimes = {};
  Map<String, List<DateTime>> groupedDates = {};
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    Map<String, Map<String, dynamic>> schedule =
    await _scheduleRepository.getWeeklySchedule(widget.vetId);

    Map<String, List<TimeOfDay>> tempAvailableTimes = {};
    schedule.forEach((day, details) {
      if (!(details["closed"] ?? false) && details["startTime"] != null && details["endTime"] != null) {
        tempAvailableTimes[day] = _generateTimeSlots(
          details["startTime"],
          details["endTime"],
        );
      }
    });

    setState(() {
      availableTimes = tempAvailableTimes;
      groupedDates = _groupDates();
      isLoading = false;
    });
  }

  List<TimeOfDay> _generateTimeSlots(TimeOfDay start, TimeOfDay end) {
    List<TimeOfDay> slots = [];
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    while (startMinutes + 30 <= endMinutes) {
      slots.add(TimeOfDay(hour: startMinutes ~/ 60, minute: startMinutes % 60));
      startMinutes += 30;
    }
    return slots;
  }

  Map<String, List<DateTime>> _groupDates() {
    DateTime now = DateTime.now();
    Map<String, List<DateTime>> grouped = {};

    for (int i = 0; i < 30; i++) {
      DateTime date = now.add(Duration(days: i));
      String dayOfWeek = DateFormat('EEEE').format(date);

      if (availableTimes.containsKey(dayOfWeek)) {
        grouped.putIfAbsent(dayOfWeek, () => []).add(date);
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chọn ngày và giờ hẹn")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Chọn ngày", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: groupedDates.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entry.value.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 5, top: 10, bottom: 5),
                            child: Text(
                              entry.key,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: entry.value.map((date) {
                              bool isSelected = selectedDate == date;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDate = date;
                                    selectedTime = null;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blue : Colors.white,
                                    border: Border.all(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    DateFormat('dd/MM').format(date),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 5),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (selectedDate != null) ...[
              Text("Chọn giờ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: availableTimes[DateFormat('EEEE').format(selectedDate!)]!
                    .map((time) {
                  bool isSelected = selectedTime == time;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTime = time;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            Spacer(),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (selectedDate != null && selectedTime != null)
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChoosePetBookingScreen(
                          vetId: widget.vetId,
                          vetName: widget.vetName,
                          selectedDate: selectedDate!,
                          selectedTime: selectedTime!,
                          vetAvatar: widget.image,
                          vetSpeciality: widget.specialization,
                        ),
                      ),
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Đặt lịch",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
