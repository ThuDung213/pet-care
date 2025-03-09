import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pet_care/features/home/booking_ui/set_booking_date_screen/set_booking_date_screen.dart';
import '../../../data/repositories/vet_repository.dart';
import '../../../widgets/specialization_button.dart';
import '../../../widgets/vet_booking_card.dart';
import 'all_vets_screen/all_vets_screen.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final VetRepository _vetRepository = VetRepository();
  List<Map<String, dynamic>> _vets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVets();
  }

  /// **Lấy danh sách bác sĩ thú y từ Firestore**
  void _fetchVets() async {
    List<Map<String, dynamic>> vets = await _vetRepository.getAllVets();
    setState(() {
      _vets = vets;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              radius: 20,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  'Programmer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Xử lý khi nhấn vào thông báo
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bác sĩ thú y...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Chuyên môn của bác sĩ thú y',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SpecializationButton(icon: Icons.pets, label: 'Chó', color: Colors.blue),
                  SpecializationButton(icon: Icons.pets, label: 'Mèo', color: Colors.orange),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bác sĩ thú y nổi bật',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: AllVetsScreen(vets: _vets),
                        ),
                      );
                    },
                    child: Text(
                      'Tất cả bác sĩ thú y',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                children: _vets.take(2).map((vet) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SetBookingDateScreen(
                            vetId: vet['id'] ?? "",
                            vetName: "BS. ${vet['name'] ?? "Không có tên"}",
                            address: vet['clinicAddress'] ?? "Không có địa chỉ",
                            rating: vet['rating'] ?? 0.0,
                            image: vet['avatar'] ?? "https://via.placeholder.com/150",
                            specialization: vet['specialization'] ?? "",
                          ),
                        ),
                      );
                    },
                    child: VetBookingCard(
                      name: "BS. ${vet['name'] ?? "Không có tên"}",
                      specialty: vet['specialization'] ?? "Không xác định",
                      rating: vet['rating'] ?? 0.0,
                      image: vet['avatar'] ?? "https://via.placeholder.com/150",
                      petType: (vet['specialization']?.contains('chó') ?? false) ? 'Chó' : 'Mèo',
                      isAvailable: vet['isAvailable'] ?? true,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
