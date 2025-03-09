import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_care/data/model/pet_list.dart';

class PetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔥 Lấy danh sách thú cưng của user hiện tại
  Stream<List<PetModel>> getUserPets(String userId) {
    return _firestore
        .collection('pets')
        .where('userId', isEqualTo: userId) // Lọc theo userId
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PetModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Lấy tất cả hồ sơ thú cưng
  Stream<List<PetModel>> getAllPets() {
    return _firestore.collection('pets').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PetModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Thêm thú cưng với userId
  Future<void> addPet(PetModel pet) async {
    await _firestore.collection('pets').add(pet.toMap());
  }

  // Xóa hồ sơ thú cưng
  Future<void> deletePet(String petId) async {
    await _firestore.collection('pets').doc(petId).delete();
  }

  Future<PetModel?> getPetById(String petId) async {
    try {
      final doc = await _firestore.collection('pets').doc(petId).get();
      if (doc.exists) {
        return PetModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print("Lỗi khi lấy thông tin thú cưng: $e");
      return null;
    }
  }

}
