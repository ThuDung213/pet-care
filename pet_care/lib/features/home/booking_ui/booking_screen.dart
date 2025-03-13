import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pet_care/features/home/booking_ui/set_booking_date_screen/set_booking_date_screen.dart';
import '../../../data/model/user_model.dart';
import '../../../data/repositories/vet_repository.dart';
import '../../../widgets/vet_booking_card.dart';
import 'all_vets_screen/all_vets_screen.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final VetRepository _vetRepository = VetRepository();
  List<Map<String, dynamic>> _vets = [];
  List<Map<String, dynamic>> _filteredVets = [];
  bool _isLoading = true;
  String? _selectedSpecialization;
  TextEditingController _searchController = TextEditingController();
  UserModel? userModel;
  User? user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchVets();
    _searchController.addListener(_filterVets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// **Lấy danh sách bác sĩ thú y từ Firestore**
  void _fetchVets() async {
    List<Map<String, dynamic>> vets = await _vetRepository.getAllVets();
    setState(() {
      _vets = vets;
      _filteredVets = vets;
      _isLoading = false;
    });
  }

  /// **Lọc danh sách theo từ khóa tìm kiếm và chuyên môn**
  void _filterVets() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVets = _vets.where((vet) {
        String name = (vet['name'] ?? "").toLowerCase();
        String specialization = (vet['specialization'] ?? "").toLowerCase();

        bool matchesSearch = name.contains(query) || specialization.contains(query);
        bool matchesSpecialization = _selectedSpecialization == null ||
            specialization.contains(_selectedSpecialization!.toLowerCase());

        return matchesSearch && matchesSpecialization;
      }).toList();
    });
  }

  void _fetchUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: userModel?.avatar != null && userModel!.avatar!.isNotEmpty
                  ? NetworkImage(userModel!.avatar!)
                  : AssetImage("assets/avatar_default.png") as ImageProvider,
              radius: 20,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(userModel?.name ?? "User", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
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
                controller: _searchController,
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
                  SpecializationButton(
                    icon: Icons.pets,
                    label: 'Chó',
                    color: _selectedSpecialization == 'Chó' ? Colors.blue[700]! : Colors.blue,
                    onPressed: () {
                      setState(() {
                        _selectedSpecialization = _selectedSpecialization == 'Chó' ? null : 'Chó';
                      });
                      _filterVets();
                    },
                  ),
                  SpecializationButton(
                    icon: Icons.pets,
                    label: 'Mèo',
                    color: _selectedSpecialization == 'Mèo' ? Colors.orange[700]! : Colors.orange,
                    onPressed: () {
                      setState(() {
                        _selectedSpecialization = _selectedSpecialization == 'Mèo' ? null : 'Mèo';
                      });
                      _filterVets();
                    },
                  ),
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
                          child: AllVetsScreen(vets: _filteredVets),
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
              _filteredVets.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Không tìm thấy bác sĩ phù hợp.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                ),
              )
                  : Column(
                children: _filteredVets.take(3).map((vet) {
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

class SpecializationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  SpecializationButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
