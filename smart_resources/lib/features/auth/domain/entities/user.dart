class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String status;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.status,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
}
