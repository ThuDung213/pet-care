class Vet {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final String clinicAddress;
  final String role;
  final String? avatar;

  Vet({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.clinicAddress,
    this.role = 'vet', // Giá trị mặc định là 'vet'
    this.avatar = '',
  });

  // Chuyển đối tượng Vet thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'clinicAddress': clinicAddress,
      'role': role,
      'avatar': avatar,
    };
  }

  // Tạo Vet từ Map lấy từ Firestore
  factory Vet.fromMap(Map<String, dynamic> data, String id) {
    return Vet(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      specialization: data['specialization'] ?? '',
      clinicAddress: data['clinicAddress'] ?? '',
      role: data['role'] ?? 'vet',
      avatar: data['avatar'] ?? '',
    );
  }
}
