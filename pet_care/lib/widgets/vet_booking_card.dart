import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VetBookingCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final String image;
  final String petType;

  VetBookingCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.image,
    required this.petType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(image),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    specialty,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: petType == 'Chó' ? Colors.blue[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      petType,
                      style: TextStyle(
                        fontSize: 12,
                        color: petType == 'Chó' ? Colors.blue : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.star, color: Colors.amber),
            Text(rating.toString()),
          ],
        ),
      ),
    );
  }
}