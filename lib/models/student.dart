class Student {
  final int? id;
  final String name;
  final String studentId;
  final int classId;
  final String? parentName;
  final String? parentPhone;
  final String? photoPath;
  final DateTime createdAt;

  Student({
    this.id,
    required this.name,
    required this.studentId,
    required this.classId,
    this.parentName,
    this.parentPhone,
    this.photoPath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'studentId': studentId,
      'classId': classId,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'photoPath': photoPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      studentId: map['studentId'] as String,
      classId: map['classId'] as int,
      parentName: map['parentName'] as String?,
      parentPhone: map['parentPhone'] as String?,
      photoPath: map['photoPath'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Student copyWith({
    int? id,
    String? name,
    String? studentId,
    int? classId,
    String? parentName,
    String? parentPhone,
    String? photoPath,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

