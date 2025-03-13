import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart'; // Import your UserModel
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserInfo() async {
    // Correct return type
    User? user = _auth.currentUser;
    if (user == null) {
      print("User is not logged in.");
      return null;
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        return UserModel.fromMap(userDoc.data()!, user.uid);
      } else {
        print("User document does not exist in Firestore.");
        return null;
      }
    } catch (e) {
      print("Error fetching user info: $e");
      return null;
    }
  }
}
