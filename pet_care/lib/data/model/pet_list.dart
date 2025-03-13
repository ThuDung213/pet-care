class PetModel {
  final String docId;
  final String petName;
  final String petBreed;
  final String imageUrl;
  final String ownerName;
  final String gender;
  final String petType;


  PetModel({
    required this.docId,
    required this.petName,
    required this.petBreed,
    required this.imageUrl,
    required this.ownerName,
    required this.gender,
    required this.petType,

  });


  factory PetModel.fromMap(String id, Map<String, dynamic> data) {
    return PetModel(
      docId: id,
      petName: data['petName'] ?? '',
      petBreed: data['petBreed'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ownerName: data['ownerName'] ?? '',
      gender: data['gender'] ?? '',
      petType: data['petType'] ?? '',

    );
  }






  // Chuyển đổi từ Object sang Map (để lưu vào Firestore)
  Map<String, dynamic> toMap() {
    return {
      'petName': petName,
      'petBreed': petBreed,
      'imageUrl': imageUrl,
      'ownerName': ownerName,
      'gender' : gender,
      'petType' : petType,
    };
  }
}
