import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.password,
    required super.role,
    required super.status,
  });

  factory UserModel.fromMap(Map<String, Object?> map) {
    return UserModel(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? 'Unknown User',
      email: (map['email'] as String?) ?? '',
      password: (map['password'] as String?) ?? '',
      role: (map['role'] as String?) ?? 'User',
      status: (map['status'] as String?) ?? 'active',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'status': status,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
