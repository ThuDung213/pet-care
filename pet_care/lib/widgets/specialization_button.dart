import 'package:flutter/cupertino.dart';

class SpecializationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  SpecializationButton({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}