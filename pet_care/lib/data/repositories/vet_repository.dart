import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../model/vet_model.dart';

class VetRepository {
  static const String clientId = "8914f132dd10f2d";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Upload ảnh lên Imgur và trả về URL**
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

  /// **Thêm hoặc cập nhật bác sĩ thú y**
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
      "isAvailable": true, // Mặc định bác sĩ có sẵn
      "rating": 0.0, // Mặc định rating là 0
    }, SetOptions(merge: true));
  }

  /// **Lấy thông tin bác sĩ thú y theo `vetId`**
  Future<Map<String, dynamic>?> getVetById(String vetId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("vets").doc(vetId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching vet data: $e");
    }
    return null;
  }

  Future<Vet?> getVetByIdFromModel(String vetId) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection("vets").doc(vetId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Vet.fromMap(data,doc.id); // Chuyển đổi Map thành Vet
      }
    } catch (e) {
      print("Error fetching vet data: $e");
    }
    return null;
  }


  /// **Xóa bác sĩ thú y khỏi Firestore**
  Future<void> deleteVet(String vetId) async {
    try {
      await _firestore.collection("vets").doc(vetId).delete();
    } catch (e) {
      print("Error deleting vet: $e");
    }
  }

  /// **Lấy tất cả bác sĩ thú y**
  Future<List<Map<String, dynamic>>> getAllVets() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("vets").get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          "id": doc.id,
          "name": data["name"] ?? "Không có tên",
          "phone": data["phone"] ?? "Không có số",
          "specialization": data["specialization"] ?? "Không có chuyên môn",
          "clinicAddress": data["clinicAddress"] ?? "Không có địa chỉ",
          "avatar": data["avatar"] ?? "https://via.placeholder.com/150",
          "isAvailable": data["isAvailable"] ?? true,
          "rating": (data["rating"] ?? 0).toDouble(),
        };
      }).toList();
    } catch (e) {
      print("Error fetching vets: $e");
      return [];
    }
  }
}
