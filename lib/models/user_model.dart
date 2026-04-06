class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'None',
      phone: json['phone'],
      address: json['address'],
      profileImage: json['profile_image'] != null ? json['profile_image']['url'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'profile_image': profileImage,
    };
  }
}
