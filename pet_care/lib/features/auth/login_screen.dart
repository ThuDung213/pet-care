import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../routes/app_router.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthRepository authRepository = AuthRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  bool isVet = false; // Checkbox để chọn vai trò

  void _login() async {
    try {
      await authRepository.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Lấy user hiện tại
      final user = _auth.currentUser;
      if (user == null) throw Exception("Không tìm thấy người dùng.");

      // Kiểm tra role từ Firestore
      final userCollection = isVet ? 'vets' : 'users';
      final userDoc = await _firestore.collection(userCollection).doc(user.uid).get();

      if (userDoc.exists) {
        // Điều hướng theo vai trò
        if (isVet) {
          Navigator.pushReplacementNamed(context, AppRoutes.vetHome);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        throw Exception("Tài khoản không hợp lệ.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/petbuddy.png',
                height: 200,
              ),
              const SizedBox(height: 10),

              // Email TextField
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Password TextField
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Role Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isVet,
                    onChanged: (bool? value) {
                      setState(() {
                        isVet = value ?? false;
                      });
                    },
                  ),
                  const Text('Đăng nhập với tư cách Bác sĩ')
                ],
              ),
              const SizedBox(height: 10),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Quên mật khẩu', style: TextStyle(color: Colors.blue)),
                ),
              ),
              const SizedBox(height: 10),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Đăng nhập', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              // Social Media Sign In
              Text(
                'or connect with',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 15),

              // Google Sign-In
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
                  label: const Text('Đăng nhập với Google', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),

              // Sign Up
              TextButton(
                onPressed: () => Navigator.pushNamed(
                    context, isVet ? AppRoutes.signupVet : AppRoutes.signup),
                child: const Text(
                  'Đăng ký tài khoản mới',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.signupVet),
                child: const Text(
                  'Bạn là bác sĩ? Đăng ký tại đây',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

