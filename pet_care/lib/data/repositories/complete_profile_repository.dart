import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pet_care/data/model/add_pet.dart';

class CompleteProfileRepository {
  /// Hàm thực hiện quá trình hoàn tất hồ sơ: upload ảnh và lưu dữ liệu
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
    // Upload ảnh lên Imgur
    String? imageUrl = await PetDataService.uploadImageToImgur(image);
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload ảnh thất bại!")),
      );
      return null;
    }

    // Lưu hồ sơ và lấy về petId
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
