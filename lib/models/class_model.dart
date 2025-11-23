class ClassModel {
  final int? id;
  final String name;
  final String? description;
  final int? teacherId;
  final DateTime createdAt;

  ClassModel({
    this.id,
    required this.name,
    this.description,
    this.teacherId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacherId': teacherId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      teacherId: map['teacherId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  ClassModel copyWith({
    int? id,
    String? name,
    String? description,
    int? teacherId,
    DateTime? createdAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

