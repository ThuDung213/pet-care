
import 'package:flutter/material.dart';

class PetProfileCard extends StatelessWidget {
  const PetProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 150,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[300]!]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 5,
              offset: Offset(0, 5)
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Text("Miu", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),),
              Text("Meo | Meo ta", style: TextStyle(color: Colors.white70, fontSize: 18),)
            ],
          ),
          SizedBox(width: 16,),
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage("assets/profile.jpg"),
          ),
        ],
      ),
    );
  }
}