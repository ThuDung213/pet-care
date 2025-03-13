import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/vet_model.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String clientId = "8914f132dd10f2d";

  // Đăng ký người dùng
  Future<void> signUp(String email, String password, String name, String phone) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Lưu thông tin người dùng vào Firestore
    final newUser = User(
      id: userCredential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      role: 'user',
    );

    await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());
  }

  // Đăng ký bác sĩ thú y
  Future<void> signUpVet(String email, String password, String name, String phone, String specialization, String clinicAddress) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Lưu thông tin bác sĩ vào Firestore
    final newVet = Vet(
      id: userCredential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      specialization: specialization,
      clinicAddress: clinicAddress,
      role: 'vet',
    );

    await _firestore.collection('vets').doc(newVet.id).set(newVet.toMap());
  }

  // Đăng nhập
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Lấy thông tin người dùng hiện tại
  Future<User?> getCurrentUser() async {
    try {
      final firebase_auth.User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        // Lấy thông tin từ collection 'users'
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (userDoc.exists) {
          return User.fromMap(userDoc.data()!, firebaseUser.uid); // Truyền cả data và id
        }

        // Lấy thông tin từ collection 'vets' nếu không tìm thấy trong 'users'
        final vetDoc = await _firestore.collection('vets').doc(firebaseUser.uid).get();
        if (vetDoc.exists) {
          return User.fromMap(vetDoc.data()!, firebaseUser.uid); // Truyền cả data và id
        }
      }
      return null;
    } catch (e) {
      print("Lỗi khi lấy thông tin người dùng: $e");
      return null;
    }
  }

  Future<String?> _uploadImageToImgur(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final response = await http.post(
        Uri.parse("https://api.imgur.com/3/image"),
        headers: {
          "Authorization": "Client-ID $clientId",
        },
        body: {
          "image": base64Image,
        },
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
}