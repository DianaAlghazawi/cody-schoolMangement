import '../database/database_helper.dart';
import '../models/attendance_record.dart';
import 'package:sqflite/sqflite.dart';

class AttendanceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(AttendanceRecord record) async {
    final db = await _dbHelper.database;
    try {
      return await db.insert('attendance_records', record.toMap());
    } on DatabaseException {
      // If duplicate, update instead
      return await update(record);
    }
  }

  Future<int> update(AttendanceRecord record) async {
    final db = await _dbHelper.database;
    return await db.update(
      'attendance_records',
      record.toMap(),
      where: 'studentId = ? AND date = ?',
      whereArgs: [record.studentId, record.date.toIso8601String().split('T')[0]],
    );
  }

  Future<AttendanceRecord?> getByStudentAndDate(int studentId, DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final maps = await db.query(
      'attendance_records',
      where: 'studentId = ? AND date = ?',
      whereArgs: [studentId, dateStr],
    );
    if (maps.isNotEmpty) {
      return AttendanceRecord.fromMap(maps.first);
    }
    return null;
  }

  Future<List<AttendanceRecord>> getByStudentId(int studentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'attendance_records',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => AttendanceRecord.fromMap(maps[i]));
  }

  Future<List<AttendanceRecord>> getByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final dateStr = date.toIso8601String().split('T')[0];
    final maps = await db.query(
      'attendance_records',
      where: 'date = ?',
      whereArgs: [dateStr],
      orderBy: 'studentId ASC',
    );
    return List.generate(maps.length, (i) => AttendanceRecord.fromMap(maps[i]));
  }

  Future<List<AttendanceRecord>> getByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];
    final maps = await db.query(
      'attendance_records',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date DESC, studentId ASC',
    );
    return List.generate(maps.length, (i) => AttendanceRecord.fromMap(maps[i]));
  }

  Future<Map<String, dynamic>> getAttendanceStats(int studentId, DateTime startDate, DateTime endDate) async {
    final records = await getByDateRange(startDate, endDate);
    final studentRecords = records.where((r) => r.studentId == studentId).toList();
    
    final present = studentRecords.where((r) => r.status == 'present').length;
    final absent = studentRecords.where((r) => r.status == 'absent').length;
    final late = studentRecords.where((r) => r.status == 'late').length;
    final earlyLeave = studentRecords.where((r) => r.status == 'early_leave').length;
    final total = studentRecords.length;

    return {
      'total': total,
      'present': present,
      'absent': absent,
      'late': late,
      'earlyLeave': earlyLeave,
      'attendanceRate': total > 0 ? (present / total * 100) : 0.0,
    };
  }

  Future<List<AttendanceRecord>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('attendance_records', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => AttendanceRecord.fromMap(maps[i]));
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'attendance_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

