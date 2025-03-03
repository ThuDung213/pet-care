import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/widgets/pet_profile_card.dart';
import 'package:pet_care/widgets/vet_card.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key});

  @override
  State<HomeMainScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeMainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/profile.jpg"),
            ),
            SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello", style: TextStyle(color: Colors.grey, fontSize: 14),),
                Text(user?.displayName ?? "No name", style: TextStyle(fontWeight: FontWeight.bold),)
              ],
            ),
            Spacer(),
            Badge(
              child: Icon(
                  Icons.notifications_none
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hồ sơ thú cưng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            SizedBox(height: 16,),
            PetProfileCard(),
            SizedBox(height: 50,),
            Text("Bác sĩ thú y", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            SizedBox(height: 25,),
            VetCard()
          ],
        ),
      ),
    );
  }
}