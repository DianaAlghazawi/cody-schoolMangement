import 'package:flutter_test/flutter_test.dart';
import 'package:classhub/services/attendance_service.dart';
import 'package:classhub/repositories/attendance_repository.dart';
import 'package:classhub/repositories/student_repository.dart';
import 'package:classhub/models/student.dart';
import 'package:classhub/database/database_helper.dart';
import 'package:classhub/repositories/class_repository.dart';
import 'package:classhub/models/class_model.dart';

void main() {
  late AttendanceService attendanceService;
  late StudentRepository studentRepo;
  late AttendanceRepository attendanceRepo;
  late DatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    attendanceService = AttendanceService();
    studentRepo = StudentRepository();
    attendanceRepo = AttendanceRepository();

    // Create a test class
    final classRepo = ClassRepository();
    final testClass = ClassModel(
      name: 'Test Class',
      createdAt: DateTime.now(),
    );
    await classRepo.insert(testClass);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('AttendanceService', () {
    test('checkIn creates attendance record with present status', () async {
      // Get test class
      final classRepo = ClassRepository();
      final classes = await classRepo.getAll();
      final classId = classes.first.id!;

      // Create a test student
      final student = Student(
        name: 'Test Student',
        studentId: 'TEST001',
        classId: classId,
        createdAt: DateTime.now(),
      );
      final studentId = await studentRepo.insert(student);

      // Check in
      final record = await attendanceService.checkIn(studentId);

      expect(record.status, 'present');
      expect(record.checkInTime, isNotNull);
      expect(record.studentId, studentId);
    });

    test('checkIn throws exception if already checked in', () async {
      // Get test class
      final classRepo = ClassRepository();
      final classes = await classRepo.getAll();
      final classId = classes.first.id!;

      // Create a test student
      final student = Student(
        name: 'Test Student 2',
        studentId: 'TEST002',
        classId: classId,
        createdAt: DateTime.now(),
      );
      final studentId = await studentRepo.insert(student);

      // First check in
      await attendanceService.checkIn(studentId);

      // Second check in should throw
      expect(
        () => attendanceService.checkIn(studentId),
        throwsException,
      );
    });

    test('checkOut updates existing record with check out time', () async {
      // Get test class
      final classRepo = ClassRepository();
      final classes = await classRepo.getAll();
      final classId = classes.first.id!;

      // Create a test student
      final student = Student(
        name: 'Test Student 3',
        studentId: 'TEST003',
        classId: classId,
        createdAt: DateTime.now(),
      );
      final studentId = await studentRepo.insert(student);

      // Check in first
      await attendanceService.checkIn(studentId);

      // Check out
      final record = await attendanceService.checkOut(studentId);

      expect(record.checkInTime, isNotNull);
      expect(record.checkOutTime, isNotNull);
      expect(record.status, 'present');
    });

    test('checkOut throws exception if not checked in', () async {
      // Get test class
      final classRepo = ClassRepository();
      final classes = await classRepo.getAll();
      final classId = classes.first.id!;

      // Create a test student
      final student = Student(
        name: 'Test Student 4',
        studentId: 'TEST004',
        classId: classId,
        createdAt: DateTime.now(),
      );
      final studentId = await studentRepo.insert(student);

      // Try to check out without checking in
      expect(
        () => attendanceService.checkOut(studentId),
        throwsException,
      );
    });

    test('markAbsent creates record with absent status', () async {
      // Get test class
      final classRepo = ClassRepository();
      final classes = await classRepo.getAll();
      final classId = classes.first.id!;

      // Create a test student
      final student = Student(
        name: 'Test Student 5',
        studentId: 'TEST005',
        classId: classId,
        createdAt: DateTime.now(),
      );
      final studentId = await studentRepo.insert(student);

      // Mark absent
      final record = await attendanceService.markAbsent(studentId);

      expect(record.status, 'absent');
      expect(record.checkInTime, isNull);
      expect(record.checkOutTime, isNull);
    });

    test('markLate creates record with late status', () async {
      // Get test class
      final classRepo = ClassRepository();
      final classes = await classRepo.getAll();
      final classId = classes.first.id!;

      // Create a test student
      final student = Student(
        name: 'Test Student 6',
        studentId: 'TEST006',
        classId: classId,
        createdAt: DateTime.now(),
      );
      final studentId = await studentRepo.insert(student);

      // Mark late
      final record = await attendanceService.markLate(studentId);

      expect(record.status, 'late');
      expect(record.checkInTime, isNotNull);
    });

    test('getTodayAttendance returns records for today', () async {
      // Get test class
      final classRepo = ClassRepository();
      final classes = await classRepo.getAll();
      final classId = classes.first.id!;

      // Create a test student
      final student = Student(
        name: 'Test Student 7',
        studentId: 'TEST007',
        classId: classId,
        createdAt: DateTime.now(),
      );
      final studentId = await studentRepo.insert(student);

      // Check in
      await attendanceService.checkIn(studentId);

      // Get today's attendance
      final records = await attendanceService.getTodayAttendance();

      expect(records.length, greaterThan(0));
      expect(records.any((r) => r.studentId == studentId), isTrue);
    });

    test('getStudentStats calculates correct statistics', () async {
      // Get test class
      final classRepo = ClassRepository();
      final classes = await classRepo.getAll();
      final classId = classes.first.id!;

      // Create a test student
      final student = Student(
        name: 'Test Student 8',
        studentId: 'TEST008',
        classId: classId,
        createdAt: DateTime.now(),
      );
      final studentId = await studentRepo.insert(student);

      // Mark present for 3 days
      for (int i = 0; i < 3; i++) {
        await attendanceService.checkIn(studentId);
      }

      // Mark absent for 1 day
      await attendanceService.markAbsent(studentId);

      // Get stats
      final stats = await attendanceService.getStudentStats(
        studentId,
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      );

      expect(stats['total'], greaterThan(0));
      expect(stats['present'], greaterThanOrEqualTo(3));
      expect(stats['absent'], greaterThanOrEqualTo(1));
    });
  });
}
