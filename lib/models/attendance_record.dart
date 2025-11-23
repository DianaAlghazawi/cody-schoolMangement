class AttendanceRecord {
  final int? id;
  final int studentId;
  final DateTime date;
  final String? checkInTime;
  final String? checkOutTime;
  final String status; // 'present', 'absent', 'late', 'early_leave'
  final String? notes;
  final DateTime createdAt;

  AttendanceRecord({
    this.id,
    required this.studentId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.toIso8601String().split('T')[0], // Store date only
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as int?,
      studentId: map['studentId'] as int,
      date: DateTime.parse(map['date'] as String),
      checkInTime: map['checkInTime'] as String?,
      checkOutTime: map['checkOutTime'] as String?,
      status: map['status'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  bool get isPresent => status == 'present';
  bool get isCheckedIn => checkInTime != null;
  bool get isCheckedOut => checkOutTime != null;

  AttendanceRecord copyWith({
    int? id,
    int? studentId,
    DateTime? date,
    String? checkInTime,
    String? checkOutTime,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

