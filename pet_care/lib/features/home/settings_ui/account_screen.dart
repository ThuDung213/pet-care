import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pet_care/features/auth/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  User? user;
  String userName = "";
  String userEmail = "";
  String userPhone = "";
  String avatarUrl = "";

  static const String clientId = "8914f132dd10f2d"; // Imgur Client ID

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
          avatarUrl = userDoc["avatar"] ?? "";
        });
      }
    }
  }

  Future<void> _updateUserData(String newName, String newPhone) async {
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

  Future<void> _updateAvatar(File imageFile) async {
    String? uploadedUrl = await _uploadImageToImgur(imageFile);
    if (uploadedUrl != null && user != null) {
      await _firestore.collection("users").doc(user!.uid).update({
        "avatar": uploadedUrl,
      });
      setState(() {
        avatarUrl = uploadedUrl;
      });
    }
  }

  Future<String?> _uploadImageToImgur(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final response = await http.post(
        Uri.parse("https://api.imgur.com/3/image"),
        headers: {"Authorization": "Client-ID $clientId"},
        body: {"image": base64Image},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData["data"]["link"];
      } else {
        print("Imgur upload failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading image to Imgur: $e");
      return null;
    }
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _updateAvatar(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Tài khoản", style: TextStyle(fontWeight: FontWeight.bold)),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Ảnh đại diện có icon chỉnh sửa
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : const AssetImage("assets/profile.jpg") as ImageProvider,
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                Text(userName, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Thông tin người dùng
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
                      ListTile(leading: const Icon(Icons.email), title: Text(userEmail)),
                      const Divider(),
                      ListTile(leading: const Icon(Icons.phone), title: Text(userPhone)),
                    ],
                  ),
                ),

                const SizedBox(height: 80),

                // Nút đăng xuất
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text("Đăng xuất", style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
