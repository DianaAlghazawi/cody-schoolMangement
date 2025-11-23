import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('classhub.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Students table
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        studentId TEXT NOT NULL UNIQUE,
        classId INTEGER NOT NULL,
        parentName TEXT,
        parentPhone TEXT,
        photoPath TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Classes table
    await db.execute('''
      CREATE TABLE classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        teacherId INTEGER,
        createdAt TEXT NOT NULL
      )
    ''');

    // Teachers table
    await db.execute('''
      CREATE TABLE teachers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT,
        role TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Attendance records table
    await db.execute('''
      CREATE TABLE attendance_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        date TEXT NOT NULL,
        checkInTime TEXT,
        checkOutTime TEXT,
        status TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        UNIQUE(studentId, date)
      )
    ''');

    // Announcements table
    await db.execute('''
      CREATE TABLE announcements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        classId INTEGER,
        teacherId INTEGER NOT NULL,
        date TEXT NOT NULL,
        attachmentPaths TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        senderName TEXT NOT NULL,
        content TEXT NOT NULL,
        attachmentPath TEXT,
        date TEXT NOT NULL,
        isFromParent INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_students_classId ON students(classId)');
    await db.execute('CREATE INDEX idx_attendance_studentId ON attendance_records(studentId)');
    await db.execute('CREATE INDEX idx_attendance_date ON attendance_records(date)');
    await db.execute('CREATE INDEX idx_messages_studentId ON messages(studentId)');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

