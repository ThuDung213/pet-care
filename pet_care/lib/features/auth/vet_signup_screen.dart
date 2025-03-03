import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../routes/app_router.dart';

class SignupVetScreen extends StatefulWidget {
  @override
  _SignupVetScreenState createState() => _SignupVetScreenState();
}

class _SignupVetScreenState extends State<SignupVetScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController clinicAddressController = TextEditingController();
  final AuthRepository authRepository = AuthRepository();

  void _signupVet() async {
    try {
      await authRepository.signUpVet(
        emailController.text.trim(),
        passwordController.text.trim(),
        nameController.text.trim(),
        phoneController.text.trim(),
        specializationController.text.trim(),
        clinicAddressController.text.trim(),
      );

      // Chuyển đến trang home sau khi đăng ký thành công
      Navigator.pushReplacementNamed(context, AppRoutes.vetHome);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng ký Bác sĩ Thú y')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Họ và tên')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Số điện thoại')),
            TextField(controller: specializationController, decoration: InputDecoration(labelText: 'Chuyên môn')),
            TextField(controller: clinicAddressController, decoration: InputDecoration(labelText: 'Địa chỉ phòng khám')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Mật khẩu'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signupVet, child: Text('Đăng ký')),
          ],
        ),
      ),
    );
  }
}
