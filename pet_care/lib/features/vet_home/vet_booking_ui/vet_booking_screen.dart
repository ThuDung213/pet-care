import 'package:flutter/material.dart';

import '../vet_booking_ui/vet_edit_schedule_screen/vet_edit_schedule_screen.dart';



class VetBookingScreen extends StatelessWidget {
  const VetBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: const Center(
        child: Text("Danh sách lịch hẹn sẽ hiển thị ở đây"),
      ),
    );
  }
}