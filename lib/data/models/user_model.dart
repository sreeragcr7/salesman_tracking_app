class UserModel {
  const UserModel({required this.uid, required this.name, required this.email, required this.role, this.profileImage});
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? profileImage;

  factory UserModel.fromJson(String uid, Map<String, dynamic> json) {
    return UserModel(
      uid: uid,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'salesman',
      profileImage: json['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'role': role, 'profile_image': profileImage};
  }
}
