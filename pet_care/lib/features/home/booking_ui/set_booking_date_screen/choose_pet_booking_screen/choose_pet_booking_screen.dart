import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_care/data/model/pet_list.dart';
import 'package:pet_care/data/repositories/pet_repository.dart';
import 'package:pet_care/data/repositories/appointment_repository.dart';
import 'package:intl/intl.dart';

class ChoosePetBookingScreen extends StatefulWidget {
  final String vetName;
  final String vetAvatar;
  final String vetSpeciality;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String vetId;

  const ChoosePetBookingScreen({
    Key? key,
    required this.vetName,
    required this.vetAvatar,
    required this.vetSpeciality,
    required this.selectedDate,
    required this.selectedTime,
    required this.vetId,
  }) : super(key: key);

  @override
  _ChoosePetBookingScreenState createState() => _ChoosePetBookingScreenState();
}

class _ChoosePetBookingScreenState extends State<ChoosePetBookingScreen> {
  final PetRepository petRepo = PetRepository();
  final AppointmentRepository appointmentRepo = AppointmentRepository();
  final User? user = FirebaseAuth.instance.currentUser;

  PetModel? selectedPet;
  bool isLoading = false;

  /// Chọn thú cưng từ danh sách
  void _selectPet() async {
    final selected = await showModalBottomSheet<PetModel>(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<PetModel>>(
          future: petRepo.getUserPets(user?.uid ?? "").first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Bạn chưa có thú cưng nào."));
            }
            final pets = snapshot.data!;
            return ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: pet.imageUrl.isNotEmpty
                        ? NetworkImage(pet.imageUrl)
                        : const AssetImage('assets/dog_avatar.png')
                    as ImageProvider,
                  ),
                  title: Text(pet.petName),
                  subtitle: Text(pet.petBreed),
                  onTap: () => Navigator.pop(context, pet),
                );
              },
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedPet = selected;
      });
    }
  }

  /// Xác nhận đặt lịch hẹn
  Future<void> _confirmAppointment() async {
    if (selectedPet == null || user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      await appointmentRepo.bookAppointment(
        userId: user!.uid,
        petId: selectedPet!.docId,
        vetId: widget.vetId,
        date: widget.selectedDate,
        time: widget.selectedTime,
        vetName: widget.vetName,

      );

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đặt lịch thành công!")),
      );

      // Quay lại màn hình chính hoặc danh sách lịch hẹn
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${error.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
    DateFormat('dd/MM/yyyy').format(widget.selectedDate);
    String formattedTime =
        "${widget.selectedTime.hour}:${widget.selectedTime.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(title: const Text("Chọn thú cưng")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hiển thị thông tin bác sĩ thú y
            Container(
              padding: const EdgeInsets.all(10),
              decoration: _boxDecoration(),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.vetAvatar),
                    radius: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vetName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.vetSpeciality,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Ngày: $formattedDate - Giờ: $formattedTime",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _selectPet,
                    child: const Text("Chọn thú cưng"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Hiển thị thông tin pet đã chọn
            if (selectedPet != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: _boxDecoration(),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: selectedPet!.imageUrl.isNotEmpty
                          ? NetworkImage(selectedPet!.imageUrl)
                          : const AssetImage('assets/dog_avatar.png')
                      as ImageProvider,
                      radius: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedPet!.petName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            selectedPet!.petBreed,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Spacer(),

            // Nút xác nhận
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedPet != null && !isLoading
                    ? _confirmAppointment
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Xác nhận",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tạo Box Decoration chung cho UI
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
        ),
      ],
    );
  }
}
