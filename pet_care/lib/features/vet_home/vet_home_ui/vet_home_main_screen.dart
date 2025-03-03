import 'package:flutter/material.dart';

class VetHomeMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trang chủ bác sĩ')),
      body: Center(
        child: Text(
          'Chào mừng bạn đến với trang dành cho bác sĩ thú y!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
