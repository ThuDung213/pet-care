import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../data/model/user_model.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthRepository authRepository = AuthRepository();

  void _signup() async {
    try {
      final newUser = User(
        id: '', // Firebase sẽ tự tạo ID khi đăng ký
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        avatar: '',
      );

      await authRepository.signUp(
        newUser.email,
        passwordController.text.trim(),
        newUser.name,
        newUser.phone,
      );

      // Điều hướng sau khi đăng ký thành công
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Họ và tên')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Số điện thoại')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signup, child: Text('Đăng ký')),
          ],
        ),
      ),
    );
  }
}