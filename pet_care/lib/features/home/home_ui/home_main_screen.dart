import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/data/model/pet_list.dart';
import 'package:pet_care/data/model/user_model.dart';
import 'package:pet_care/data/model/vet_model.dart';
import 'package:pet_care/data/repositories/pet_repository.dart';
import 'package:pet_care/data/repositories/user_repository.dart';
import 'package:pet_care/data/repositories/vet_repository.dart';
import 'package:pet_care/widgets/pet_profile_card.dart';
import 'package:pet_care/widgets/vet_card.dart';

import '../notification_ui/notification_screen.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key});

  @override
  State<HomeMainScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeMainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();
  final VetRepository _vetRepository = VetRepository();
  final PetRepository _petRepository = PetRepository();
  UserModel? _user;
  List<Map<String, dynamic>>? _vets;
  List<PetModel>? _mypets;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchVetList();
  }

  Future<void> _fetchUserInfo() async {
    UserModel? user = await _userRepository.getUserInfo();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  Future<void> _fetchVetList() async {
    List<Map<String, dynamic>>? vets = await _vetRepository.getAllVets();
    if (mounted) {
      setState(() {
        _vets = vets;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: _user?.avatar != null && _user!.avatar!.isNotEmpty
                  ? NetworkImage(_user!.avatar!)
                  : AssetImage("avata_normal/profile.jpg") as ImageProvider,
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  _user?.name ?? "No Name",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Pets
            Text(
              "Hồ sơ thú cưng",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 16,
            ),
            StreamBuilder<List<PetModel>>(
              stream: _petRepository.getUserPets(_user?.id ?? ""),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("Không có thú cưng nào."));
                } else {
                  return PetProfileCard(petData: snapshot.data);
                }
              },
            ),
            SizedBox(
              height: 50,
            ),

            // Vet List
            Text(
              "Bác sĩ thú y",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 25,
            ),
            VetCard(vetData: _vets ?? [])
          ],
        ),
      ),
    );
  }
}
