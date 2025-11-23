class Announcement {
  final int? id;
  final String title;
  final String content;
  final int? classId; // null means all classes
  final int teacherId;
  final DateTime date;
  final List<String>? attachmentPaths;
  final DateTime createdAt;

  Announcement({
    this.id,
    required this.title,
    required this.content,
    this.classId,
    required this.teacherId,
    required this.date,
    this.attachmentPaths,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'classId': classId,
      'teacherId': teacherId,
      'date': date.toIso8601String(),
      'attachmentPaths': attachmentPaths?.join(','),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      classId: map['classId'] as int?,
      teacherId: map['teacherId'] as int,
      date: DateTime.parse(map['date'] as String),
      attachmentPaths: map['attachmentPaths'] != null
          ? (map['attachmentPaths'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Announcement copyWith({
    int? id,
    String? title,
    String? content,
    int? classId,
    int? teacherId,
    DateTime? date,
    List<String>? attachmentPaths,
    DateTime? createdAt,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      date: date ?? this.date,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

