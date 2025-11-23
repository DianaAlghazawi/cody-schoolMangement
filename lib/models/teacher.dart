class Teacher {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String role; // 'teacher' or 'admin'
  final DateTime createdAt;

  Teacher({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      role: map['role'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher' || role == 'admin';

  Teacher copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

