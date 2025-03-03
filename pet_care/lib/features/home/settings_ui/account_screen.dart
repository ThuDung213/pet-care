import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/features/auth/login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String userName = "";
  String userEmail = "";
  String userPhone = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc["name"] ?? "No name";
          userEmail = userDoc["email"] ?? "No email";
          userPhone = userDoc["phone"] ?? "No phone";
        });
      }
    }
  }

  void _updateUserData(String newName, String newPhone) async {
    if (user != null) {
      await _firestore.collection("users").doc(user!.uid).update({
        "name": newName,
        "phone": newPhone,
      });
      setState(() {
        userName = newName;
        userPhone = newPhone;
      });
    }
  }

  void _showEditDialog() {
    TextEditingController nameController = TextEditingController(text: userName);
    TextEditingController phoneController = TextEditingController(text: userPhone);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Chỉnh sửa thông tin"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Tên"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Số điện thoại"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                _updateUserData(nameController.text.trim(), phoneController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận đăng xuất"),
          content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Tài khoản",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage("assets/profile.jpg"),
              ),
              const SizedBox(height: 15),
              Text(
                userName,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.black),
                      title: Text(userEmail),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.black),
                      title: Text(userPhone),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showSignOutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 25),
                  ),
                  child: const Text(
                    "Đăng xuất",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
