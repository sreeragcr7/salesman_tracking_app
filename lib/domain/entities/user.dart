import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? profileImage;

  const User({required this.uid, required this.name, required this.email, required this.role, this.profileImage});

  @override
  List<Object?> get props => [uid, name, email, role, profileImage];
}
