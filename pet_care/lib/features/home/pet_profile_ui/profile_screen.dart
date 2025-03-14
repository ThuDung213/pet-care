import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_care/data/model/pet_list.dart';
import 'package:pet_care/data/repositories/pet_repository.dart';
import 'package:pet_care/features/home/pet_profile_ui/PetDiagnosisList/PetDiagnosisListScreen.dart';
import 'package:pet_care/features/home/pet_profile_ui/add_pet_screen/add_pet_screen.dart';
import '../../../data/model/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../notification_ui/notification_screen.dart';
import 'PetDiagnosisList/PetDiagnosis/PetDiagnosisScreen.dart';
import 'add_pet_screen/PetBreedSelectionScreen/pet_name_screen/pet_weight_screen/SpecialCharacteristicsScreen/SpecialDayScreen/CaretakerScreen/CompleteProfileScreen/PetProfileScreen/PetProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final petRepo = PetRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    UserModel? user = await _userRepository.getUserInfo();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
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
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hello",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  _user?.name ?? "No Name",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications),
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<PetModel>>(
              stream: petRepo.getUserPets(user?.uid ?? ""),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final petList = snapshot.data ?? [];
                if (petList.isEmpty) {
                  return _buildNoPetUI();
                }
                return ListView.builder(
                  itemCount: petList.length,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, index) {
                    final pet = petList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PetProfileScreen(petId: pet.docId),
                          ),
                        );
                      },
                      child: _buildPetItem(context, pet),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddPetScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF254EDB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                ),
                child: const Text(
                  "+ Thêm hồ sơ",
                  style: TextStyle(color: Color(0xFF254EDB), fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPetUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/no_pet_profile.png', width: 300),
          const SizedBox(height: 20),
          const Text(
            "Chưa có hồ sơ thú cưng",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Bạn chưa tạo lập hồ sơ thú cưng.\nẤn Tiếp tục để cập nhật thông tin của con nhé!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildPetItem(BuildContext context, PetModel pet) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: pet.imageUrl.isNotEmpty
            ? NetworkImage(pet.imageUrl)
            : const AssetImage('assets/dog_avatar.png') as ImageProvider,
        radius: 25,
      ),
      title: Text(
        pet.petName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        pet.petBreed,
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.insert_drive_file, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PetDiagnosisListScreen(petId: pet.docId)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await petRepo.deletePet(pet.docId);
            },
          ),
        ],
      ),
    );
  }
}
