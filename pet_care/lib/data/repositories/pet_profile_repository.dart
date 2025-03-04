import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care/data/model/add_pet.dart';

class PetProfileRepository {
  /// Cho phép chọn ảnh từ thư viện và upload lên Imgur để lấy URL
  Future<String?> pickPetImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        String? newUrl = await PetDataService.uploadImageToImgur(file);
        return newUrl;
      }
    } catch (e) {
      debugPrint("Error picking pet image: $e");
    }
    return null;
  }

  /// Cập nhật dữ liệu của thú cưng lên Firestore
  Future<bool> updatePetData({
    required String petId,
    required String petName,
    required String petBreed,
    required String weight,
    required String selectedSize,
    required String selectedGender,
    required List<String> selectedCharacteristics,
    required DateTime? birthDate,
    required DateTime? adoptionDate,
    required String ownerName,
    required String ownerPhone,
    required String ownerAddress,
    required String imageUrl,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('pets').doc(petId).update({
        'petName': petName,
        'petBreed': petBreed,
        'weight': weight,
        'size': selectedSize,
        'gender': selectedGender,
        'characteristics': selectedCharacteristics,
        'birthDate': birthDate?.toIso8601String(),
        'adoptionDate': adoptionDate?.toIso8601String(),
        'ownerName': ownerName,
        'ownerPhone': ownerPhone,
        'ownerAddress': ownerAddress,
        'imageUrl': imageUrl,
      });
      return true;
    } catch (e) {
      debugPrint("Error updating pet data: $e");
      return false;
    }
  }
}
