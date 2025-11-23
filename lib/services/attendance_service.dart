import '../models/attendance_record.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/student_repository.dart';

class AttendanceService {
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final StudentRepository _studentRepo = StudentRepository();

  /// Mark check-in for a student
  Future<AttendanceRecord> checkIn(int studentId, {String? notes}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final existing = await _attendanceRepo.getByStudentAndDate(studentId, today);
    
    if (existing != null && existing.checkInTime != null) {
      throw Exception('Student already checked in today');
    }

    final record = AttendanceRecord(
      studentId: studentId,
      date: today,
      checkInTime: timeStr,
      status: 'present',
      notes: notes,
      createdAt: now,
    );

    await _attendanceRepo.insert(record);
    return record;
  }

  /// Mark check-out for a student
  Future<AttendanceRecord> checkOut(int studentId, {String? notes, String? status}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final existing = await _attendanceRepo.getByStudentAndDate(studentId, today);
    
    if (existing == null) {
      throw Exception('Student must check in before checking out');
    }

    if (existing.checkOutTime != null) {
      throw Exception('Student already checked out today');
    }

    final updatedRecord = existing.copyWith(
      checkOutTime: timeStr,
      status: status ?? existing.status,
      notes: notes ?? existing.notes,
    );

    await _attendanceRepo.update(updatedRecord);
    return updatedRecord;
  }

  /// Mark student as absent
  Future<AttendanceRecord> markAbsent(int studentId, {String? notes}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final record = AttendanceRecord(
      studentId: studentId,
      date: today,
      status: 'absent',
      notes: notes,
      createdAt: now,
    );

    await _attendanceRepo.insert(record);
    return record;
  }

  /// Mark student as late
  Future<AttendanceRecord> markLate(int studentId, {String? notes}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final record = AttendanceRecord(
      studentId: studentId,
      date: today,
      checkInTime: timeStr,
      status: 'late',
      notes: notes,
      createdAt: now,
    );

    await _attendanceRepo.insert(record);
    return record;
  }

  /// Get attendance for today
  Future<List<AttendanceRecord>> getTodayAttendance() async {
    final today = DateTime.now();
    return await _attendanceRepo.getByDate(today);
  }

  /// Get attendance statistics for a student
  Future<Map<String, dynamic>> getStudentStats(int studentId, {DateTime? startDate, DateTime? endDate}) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    return await _attendanceRepo.getAttendanceStats(studentId, start, end);
  }
}

