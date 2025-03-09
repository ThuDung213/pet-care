import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VetRecordRepository {
  static const String clientId = "8914f132dd10f2d"; // Client ID của Imgur
  final CollectionReference vetRecordsCollection =
  FirebaseFirestore.instance.collection('vet_records');
  final ImagePicker picker = ImagePicker();

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

  /// Tạo một bản ghi PetRecord rỗng
  Future<void> createPetRecord({
    required String userId,
    required String vetId,
    required String petId,
    required String appointmentId,
    required DateTime appointmentDate,
  }) async {
    try {
      await vetRecordsCollection.add({
        'userId': userId,
        'vetId': vetId,
        'petId': petId,
        'appointmentId': appointmentId,
        'diagnosis': '', // Rỗng
        'treatment': '', // Rỗng
        'note': '', // Rỗng
        'recordImg': [], // Danh sách ảnh rỗng
        'appointmentDate': Timestamp.fromDate(appointmentDate),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Lỗi khi tạo PetRecord: $e");
      throw Exception("Failed to create PetRecord: $e");
    }
  }

  /// Cập nhật PetRecord với dữ liệu mới
  Future<void> updatePetRecord({
    required String recordId,
    String? diagnosis,
    String? treatment,
    String? note,
    List<String>? recordImg,
  }) async {
    try {
      await vetRecordsCollection.doc(recordId).update({
        if (diagnosis != null) 'diagnosis': diagnosis,
        if (treatment != null) 'treatment': treatment,
        if (note != null) 'note': note,
        if (recordImg != null) 'recordImg': recordImg,
      });
    } catch (e) {
      print("Lỗi khi cập nhật PetRecord: $e");
      throw Exception("Failed to update PetRecord: $e");
    }
  }

  /// Chọn nhiều ảnh từ thiết bị
  Future<List<XFile>> pickMultipleImages() async {
    final List<XFile>? images = await picker.pickMultiImage();
    return images ?? [];
  }

  /// Upload ảnh lên Imgur và trả về danh sách URL
  Future<List<String>> uploadImages(List<XFile> images) async {
    final List<String> imageUrls = [];

    for (var image in images) {
      final File imageFile = File(image.path);
      final String? imageUrl = await uploadImageToImgur(imageFile);
      if (imageUrl != null) {
        imageUrls.add(imageUrl);
      }
    }

    return imageUrls;
  }

  /// Lấy tất cả các bản ghi, lọc theo vetId và sắp xếp theo createdAt
  Stream<List<Map<String, dynamic>>> getRecordsByVetId(String vetId) {
    return vetRecordsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc['vetId'] == vetId) // Lọc theo vetId
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // Thêm ID của document vào dữ liệu
          ...data,
        };
      })
          .toList()
        ..sort((a, b) => (a['createdAt'] as Timestamp)
            .compareTo(b['createdAt'] as Timestamp)); // Sắp xếp tăng dần theo createdAt
    });
  }

  /// Lấy bản ghi hiện tại (nếu cần)
  Future<Map<String, dynamic>?> getCurrentRecord(String recordId) async {
    try {
      final recordDoc = await vetRecordsCollection.doc(recordId).get();
      if (recordDoc.exists) {
        final data = recordDoc.data() as Map<String, dynamic>;
        return {
          'id': recordDoc.id, // Thêm ID của document vào dữ liệu
          ...data,
        };
      }
      return null;
    } catch (e) {
      print("Lỗi khi lấy bản ghi hiện tại: $e");
      return null;
    }
  }
}