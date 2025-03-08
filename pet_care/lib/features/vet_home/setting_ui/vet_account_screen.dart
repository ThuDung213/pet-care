import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care/features/auth/login_screen.dart';

import '../../../data/repositories/vet_repository.dart';

class VetAccountScreen extends StatefulWidget {
  const VetAccountScreen({super.key});

  @override
  State<VetAccountScreen> createState() => _VetAccountScreenState();
}

class _VetAccountScreenState extends State<VetAccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String vetName = "";
  String vetEmail = "";
  String vetPhone = "";
  String specialization = "";
  String clinicAddress = "";
  String avatar = "";


  @override
  void initState() {
    super.initState();
    _loadVetData();
  }

  void _loadVetData() async {
    user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot vetDoc = await _firestore.collection("vets").doc(user!.uid).get();
      if (vetDoc.exists) {
        setState(() {
          vetName = vetDoc["name"] ?? "No name";
          vetEmail = vetDoc["email"] ?? "No email";
          vetPhone = vetDoc["phone"] ?? "No phone";
          specialization = vetDoc["specialization"] ?? "No specialty";
          clinicAddress = vetDoc["clinicAddress"] ?? "No address";
          avatar = vetDoc["avatar"] ?? "";
        });
      }
    }
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận đăng xuất"),
          content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Không"),
            ),
            TextButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text("Có"),
            ),
          ],
        );
      },
    );
  }

  void _editProfile() async {
    TextEditingController nameController = TextEditingController(text: vetName);
    TextEditingController phoneController = TextEditingController(text: vetPhone);
    TextEditingController specializationController = TextEditingController(text: specialization);
    TextEditingController clinicAddressController = TextEditingController(text: clinicAddress);
    File? newAvatar;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Chỉnh sửa thông tin"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên")),
                    TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Số điện thoại")),
                    TextField(controller: specializationController, decoration: const InputDecoration(labelText: "Chuyên khoa")),
                    TextField(controller: clinicAddressController, decoration: const InputDecoration(labelText: "Địa chỉ phòng khám")),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text("Chọn ảnh đại diện"),
                      onPressed: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            newAvatar = File(pickedFile.path);
                          });
                        }
                      },
                    ),
                    if (isUploading) const CircularProgressIndicator(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Hủy"),
                ),
                TextButton(
                  onPressed: () async {
                    String? avatarUrl = avatar;

                    if (newAvatar != null) {
                      setState(() {
                        isUploading = true;
                      });

                      avatarUrl = await VetRepository.uploadImageToImgur(newAvatar!);

                      setState(() {
                        isUploading = false;
                      });

                      if (avatarUrl == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Tải ảnh lên thất bại. Vui lòng thử lại!")),
                        );
                        return;
                      }
                    }

                    await VetRepository.saveOrUpdateVet(
                      userId: user!.uid,
                      name: nameController.text,
                      phone: phoneController.text,
                      specialization: specializationController.text,
                      clinicAddress: clinicAddressController.text,
                      avatarUrl: avatarUrl ?? avatar,
                    );

                    _loadVetData();
                    Navigator.of(context).pop();
                  },
                  child: isUploading ? const Text("Đang tải...") : const Text("Lưu"),
                ),
              ],
            );
          },
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
          "Tài khoản Bác sĩ Thú y",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: _editProfile,
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
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey.shade300,
                  child: avatar.isNotEmpty
                      ? ClipOval(
                    child: Image.network(
                      avatar,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 100, color: Colors.grey);
                      },
                    ),
                  )
                      : const Icon(Icons.person, size: 100, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                Text(
                  vetName,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                      ListTile(leading: const Icon(Icons.email), title: Text(vetEmail)),
                      const Divider(),
                      ListTile(leading: const Icon(Icons.phone), title: Text(vetPhone)),
                      const Divider(),
                      ListTile(leading: const Icon(Icons.medical_services), title: Text("Chuyên khoa: $specialization")),
                      const Divider(),
                      ListTile(leading: const Icon(Icons.location_on), title: Text("Địa chỉ phòng khám: $clinicAddress")),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmSignOut,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Đăng xuất", style: TextStyle(color: Colors.white)),
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
