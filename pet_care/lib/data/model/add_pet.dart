import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class PetDataService {
  static const String clientId = "8914f132dd10f2d";

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
        final imageUrl = jsonData["data"]["link"];
        return imageUrl;
      } else {
        print("Imgur upload failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading image to Imgur: $e");
      return null;
    }
  }

  /// Lưu thông tin thú cưng lên Firebase (collection 'pets') với trường id được lưu
  /// và trả về id của document vừa tạo.
  static Future<String?> saveAndGetPetId({
    required String petType,
    required String petBreed,
    required String petName,
    required String weight,
    required String size,
    required String gender,
    required List<String> characteristics,
    required DateTime? birthDate,
    required DateTime? adoptionDate,
    required String ownerName,
    required String ownerPhone,
    required String ownerAddress,
    required String imageUrl,
  }) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection("pets").doc();
      await docRef.set({
        "id": docRef.id,
        "petType": petType,
        "petBreed": petBreed,
        "petName": petName,
        "weight": weight,
        "size": size,
        "gender": gender,
        "characteristics": characteristics,
        "birthDate": birthDate?.toIso8601String(),
        "adoptionDate": adoptionDate?.toIso8601String(),
        "ownerName": ownerName,
        "ownerPhone": ownerPhone,
        "ownerAddress": ownerAddress,
        "imageUrl": imageUrl,
        "createdAt": DateTime.now().toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      print("Error saving pet data: $e");
      return null;
    }
  }
}
