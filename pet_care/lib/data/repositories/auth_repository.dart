import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/vet_model.dart';

class AuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}
