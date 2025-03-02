class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar = ''
  });

  // Phương thức để chuyển đổi đối tượng User thành Map (dùng để lưu vào Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar
    };
  }

  // Phương thức để chuyển đổi dữ liệu từ Firestore thành đối tượng User
  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      avatar: data['avatar'] ?? '',
    );
  }
}