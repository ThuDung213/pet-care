class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'user',
    this.avatar = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar': avatar,
    };
  }

  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'user',
      avatar: data['avatar'] ?? '',
    );
  }
}
