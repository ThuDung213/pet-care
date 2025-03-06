import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_care/data/model/add_pet.dart';

class CompleteProfileRepository {
  /// Hoàn tất hồ sơ thú cưng: Upload ảnh và lưu dữ liệu
  Future<String?> completeProfile({
    required BuildContext context,
    required String petType,
    required String petBreed,
    required File image,
    required String petName,
    required String weight,
    required String size,
    required String gender,
    required List<String> characteristics,
    DateTime? birthDate,
    DateTime? adoptionDate,
    required String ownerName,
    required String ownerPhone,
    required String ownerAddress,
  }) async {
    // Lấy userId của người dùng đang đăng nhập
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa đăng nhập!")),
      );
      return null;
    }
    String userId = user.uid;

    // Upload ảnh lên Imgur
    String? imageUrl = await PetDataService.uploadImageToImgur(image);
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload ảnh thất bại!")),
      );
      return null;
    }

    // Lưu hồ sơ thú cưng và lấy về petId
    String? petId = await PetDataService.saveAndGetPetId(
      petType: petType,
      petBreed: petBreed,
      petName: petName,
      weight: weight,
      size: size,
      gender: gender,
      characteristics: characteristics,
      birthDate: birthDate,
      adoptionDate: adoptionDate,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      ownerAddress: ownerAddress,
      imageUrl: imageUrl,
      userId: userId,
    );

    if (petId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lưu hồ sơ thất bại!")),
      );
      return null;
    }
    return petId;
  }
}
