class User {
  final int id;
  final String username;
  final String passwordHash;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      role: map['role'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}