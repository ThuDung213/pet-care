import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class VetRepository {
  static const String clientId = "8914f132dd10f2d";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload ảnh [imageFile] lên Imgur và trả về URL của ảnh.
  static Future<String?> uploadImageToImgur(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final response = await http.post(
        Uri.parse("https://api.imgur.com/3/image"),
        headers: {
          "Authorization": "Client-ID $clientId",
        },
        body: {
          "image": base64Image,
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData["data"]["link"];
      } else {
        print("Imgur upload failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading image to Imgur: $e");
      return null;
    }
  }

  /// Tạo mới hoặc cập nhật thông tin bác sĩ thú y trong Firestore.
  static Future<void> saveOrUpdateVet({
    required String userId,
    required String name,
    required String phone,
    required String specialization,
    required String clinicAddress,
    required String avatarUrl,
  }) async {
    await FirebaseFirestore.instance.collection("vets").doc(userId).set({
      "name": name,
      "phone": phone,
      "specialization": specialization,
      "clinicAddress": clinicAddress,
      "avatar": avatarUrl,
    }, SetOptions(merge: true));
  }

  /// Lấy thông tin của bác sĩ thú y theo `vetId`.
  Future<Map<String, dynamic>?> getVetById(String vetId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("vets").doc(vetId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching vet data: $e");
    }
    return null;
  }

  /// Xóa tài khoản bác sĩ thú y khỏi Firestore.
  Future<void> deleteVet(String vetId) async {
    try {
      await _firestore.collection("vets").doc(vetId).delete();
    } catch (e) {
      print("Error deleting vet: $e");
    }
  }
}
