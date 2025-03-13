import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_care/data/model/message_model.dart';
import 'package:pet_care/widgets/message.dart';
import '../../../data/model/vet_model.dart';

class VetChatScreen extends StatefulWidget {
  const VetChatScreen({super.key});

  @override
  State<VetChatScreen> createState() => _VetChatScreenState();
}

class _VetChatScreenState extends State<VetChatScreen> {
  TextEditingController _userInput = TextEditingController();
  static const apiKey = "AIzaSyBIiyjHQkav93Zt2GXe6qVedp0TjUsP-rM";
  final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  final List<Message> _messages = [];
  final _auth = FirebaseAuth.instance;
  User? user;
  Vet? vetModel;

  @override
  void initState() {
    super.initState();
    _fetchVetData();
  }

  /// **Lấy dữ liệu bác sĩ thú y từ Firestore**
  void _fetchVetData() async {
    user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot vetDoc = await FirebaseFirestore.instance.collection('vets').doc(user!.uid).get();
      if (vetDoc.exists) {
        setState(() {
          vetModel = Vet.fromMap(vetDoc.data() as Map<String, dynamic>, vetDoc.id);
        });
      }
    }
  }

  Future<void> sendMessage() async {
    final message = _userInput.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _messages.add(Message(
          isUser: false,
          message: response.text ?? "No response",
          date: DateTime.now()));
    });

    _userInput.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: vetModel?.avatar != null && vetModel!.avatar!.isNotEmpty
                  ? NetworkImage(vetModel!.avatar!)
                  : AssetImage("assets/avatar_default.png") as ImageProvider,
              radius: 20,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello,", style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  vetModel?.name ?? "Veterinarian",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
              image: NetworkImage(
                  'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEigDbiBM6I5Fx1Jbz-hj_mqL_KtAPlv9UsQwpthZIfFLjL-hvCmst09I-RbQsbVt5Z0QzYI_Xj1l8vkS8JrP6eUlgK89GJzbb_P-BwLhVP13PalBm8ga1hbW5pVx8bswNWCjqZj2XxTFvwQ__u4ytDKvfFi5I2W9MDtH3wFXxww19EVYkN8IzIDJLh_aw/s1920/space-soldier-ai-wallpaper-4k.webp'),
              fit: BoxFit.cover),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return MessageWidget(message: _messages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      controller: _userInput,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        labelText: 'Enter Your Message',
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    iconSize: 30,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(const CircleBorder()),
                    ),
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
