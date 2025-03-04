import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_care/data/model/pet_list.dart';

class PetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy tất cả hồ sơ thú cưng
  Stream<List<PetModel>> getAllPets() {
    return _firestore.collection('pets').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PetModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Thêm hồ sơ thú cưng
  Future<void> addPet(PetModel pet) async {
    await _firestore.collection('pets').add(pet.toMap());
  }

  // Xóa hồ sơ thú cưng
  Future<void> deletePet(String petId) async {
    await _firestore.collection('pets').doc(petId).delete();
  }
}
