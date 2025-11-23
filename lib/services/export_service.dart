import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../repositories/student_repository.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/class_repository.dart';
import '../repositories/announcement_repository.dart';
import '../repositories/teacher_repository.dart';
import '../models/class_model.dart';
import '../models/teacher.dart';
import '../models/student.dart';
import '../models/attendance_record.dart';
import '../models/announcement.dart';

class ExportService {
  final StudentRepository _studentRepo = StudentRepository();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final ClassRepository _classRepo = ClassRepository();
  final AnnouncementRepository _announcementRepo = AnnouncementRepository();
  final TeacherRepository _teacherRepo = TeacherRepository();

  /// Export all data to JSON file using SAF
  Future<String?> exportAllData() async {
    try {
      final students = await _studentRepo.getAll();
      final classes = await _classRepo.getAll();
      final teachers = await _teacherRepo.getAll();
      final attendance = await _attendanceRepo.getAll();
      final announcements = await _announcementRepo.getAll();

      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'students': students.map((s) => s.toMap()).toList(),
        'classes': classes.map((c) => c.toMap()).toList(),
        'teachers': teachers.map((t) => t.toMap()).toList(),
        'attendance': attendance.map((a) => a.toMap()).toList(),
        'announcements': announcements.map((a) => a.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Save to temporary file first
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'classhub_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsString(jsonString);

      // Use share_plus to save via SAF (more reliable on Android)
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'ClassHub Data Export',
        subject: 'ClassHub Export',
      );

      // Clean up temp file after a delay
      Future.delayed(const Duration(seconds: 2), () {
        try {
          if (tempFile.existsSync()) {
            tempFile.deleteSync();
          }
        } catch (e) {
          // Ignore cleanup errors
        }
      });

      return tempFile.path;
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }

  /// Import data from JSON file
  /// Strategy: Match by unique identifiers (name for classes, studentId for students, email for teachers)
  /// If match found, update; otherwise, insert as new record
  Future<Map<String, int>> importData(String filePath,
      {bool mergeMode = true}) async {
    final stats = {
      'classes': 0,
      'teachers': 0,
      'students': 0,
      'attendance': 0,
      'announcements': 0,
      'skipped': 0,
    };

    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Create ID mapping for imported entities (old ID -> new ID)
      final classIdMap = <int, int>{};
      final teacherIdMap = <int, int>{};
      final studentIdMap = <int, int>{};

      // Step 1: Import classes first (they're referenced by students)
      if (data.containsKey('classes')) {
        final classes = data['classes'] as List;
        for (var classData in classes) {
          try {
            final importedClass =
                ClassModel.fromMap(classData as Map<String, dynamic>);
            final oldId = importedClass.id;

            // Check if class with same name exists
            final existingClasses = await _classRepo.getAll();
            final existing = existingClasses.firstWhere(
              (c) => c.name == importedClass.name,
              orElse: () => ClassModel(name: '', createdAt: DateTime.now()),
            );

            int newId;
            if (existing.name == importedClass.name && mergeMode) {
              // Update existing class
              await _classRepo.update(importedClass.copyWith(id: existing.id));
              newId = existing.id!;
              stats['skipped'] = stats['skipped']! + 1;
            } else {
              // Insert new class (ID will be auto-generated)
              newId = await _classRepo.insert(importedClass.copyWith(id: null));
              stats['classes'] = stats['classes']! + 1;
            }

            if (oldId != null) {
              classIdMap[oldId] = newId;
            }
          } catch (e) {
            // Skip invalid class data
            continue;
          }
        }
      }

      // Step 2: Import teachers (referenced by classes and announcements)
      if (data.containsKey('teachers')) {
        final teachers = data['teachers'] as List;
        for (var teacherData in teachers) {
          try {
            final importedTeacher =
                Teacher.fromMap(teacherData as Map<String, dynamic>);
            final oldId = importedTeacher.id;

            // Check if teacher with same email exists
            final existing =
                await _teacherRepo.getByEmail(importedTeacher.email);

            int newId;
            if (existing != null && mergeMode) {
              // Update existing teacher
              await _teacherRepo
                  .update(importedTeacher.copyWith(id: existing.id));
              newId = existing.id!;
              stats['skipped'] = stats['skipped']! + 1;
            } else {
              // Insert new teacher
              newId =
                  await _teacherRepo.insert(importedTeacher.copyWith(id: null));
              stats['teachers'] = stats['teachers']! + 1;
            }

            if (oldId != null) {
              teacherIdMap[oldId] = newId;
            }
          } catch (e) {
            continue;
          }
        }
      }

      // Step 3: Import students (reference classes)
      if (data.containsKey('students')) {
        final students = data['students'] as List;
        for (var studentData in students) {
          try {
            final importedStudent =
                Student.fromMap(studentData as Map<String, dynamic>);
            final oldId = importedStudent.id;

            // Map class ID
            final oldClassId = importedStudent.classId;
            final newClassId = classIdMap[oldClassId] ?? oldClassId;

            // Check if student with same studentId exists
            final allStudents = await _studentRepo.getAll();
            final existingByStudentId = allStudents.firstWhere(
              (s) => s.studentId == importedStudent.studentId,
              orElse: () => Student(
                name: '',
                studentId: '',
                classId: 0,
                createdAt: DateTime.now(),
              ),
            );

            int newId;
            if (existingByStudentId.studentId == importedStudent.studentId &&
                mergeMode) {
              // Update existing student
              await _studentRepo.update(
                importedStudent.copyWith(
                    id: existingByStudentId.id, classId: newClassId),
              );
              newId = existingByStudentId.id!;
              stats['skipped'] = stats['skipped']! + 1;
            } else {
              // Insert new student
              newId = await _studentRepo.insert(
                importedStudent.copyWith(id: null, classId: newClassId),
              );
              stats['students'] = stats['students']! + 1;
            }

            if (oldId != null) {
              studentIdMap[oldId] = newId;
            }
          } catch (e) {
            continue;
          }
        }
      }

      // Step 4: Import attendance records (reference students)
      if (data.containsKey('attendance')) {
        final attendanceRecords = data['attendance'] as List;
        for (var attendanceData in attendanceRecords) {
          try {
            final importedRecord = AttendanceRecord.fromMap(
                attendanceData as Map<String, dynamic>);

            // Map student ID
            final oldStudentId = importedRecord.studentId;
            final newStudentId = studentIdMap[oldStudentId] ?? oldStudentId;

            // Check if record already exists for this student and date
            final existing = await _attendanceRepo.getByStudentAndDate(
              newStudentId,
              importedRecord.date,
            );

            if (existing == null || !mergeMode) {
              // Insert new record
              await _attendanceRepo.insert(
                importedRecord.copyWith(id: null, studentId: newStudentId),
              );
              stats['attendance'] = stats['attendance']! + 1;
            } else {
              // Update existing record
              await _attendanceRepo.update(
                importedRecord.copyWith(
                    id: existing.id, studentId: newStudentId),
              );
              stats['skipped'] = stats['skipped']! + 1;
            }
          } catch (e) {
            continue;
          }
        }
      }

      // Step 5: Import announcements (reference classes and teachers)
      if (data.containsKey('announcements')) {
        final announcements = data['announcements'] as List;
        for (var announcementData in announcements) {
          try {
            final importedAnnouncement =
                Announcement.fromMap(announcementData as Map<String, dynamic>);

            // Map class ID and teacher ID
            final oldClassId = importedAnnouncement.classId;
            final newClassId = oldClassId != null
                ? (classIdMap[oldClassId] ?? oldClassId)
                : null;
            final oldTeacherId = importedAnnouncement.teacherId;
            final newTeacherId = teacherIdMap[oldTeacherId] ?? oldTeacherId;

            // Insert new announcement (announcements are typically not merged)
            await _announcementRepo.insert(
              importedAnnouncement.copyWith(
                id: null,
                classId: newClassId,
                teacherId: newTeacherId,
              ),
            );
            stats['announcements'] = stats['announcements']! + 1;
          } catch (e) {
            continue;
          }
        }
      }

      return stats;
    } catch (e) {
      throw Exception('Import failed: $e');
    }
  }

  /// Export attendance report for a date range
  Future<String?> exportAttendanceReport(
      DateTime startDate, DateTime endDate) async {
    try {
      final records = await _attendanceRepo.getByDateRange(startDate, endDate);

      final reportData = {
        'reportType': 'attendance',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'records': records.map((r) => r.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(reportData);

      // Save to temporary file first
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'attendance_report_${startDate.toIso8601String().split('T')[0]}_to_${endDate.toIso8601String().split('T')[0]}.json';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsString(jsonString);

      // Use share_plus to save via SAF (more reliable on Android)
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Attendance Report',
        subject: 'ClassHub Attendance Report',
      );

      // Clean up temp file after a delay
      Future.delayed(const Duration(seconds: 2), () {
        try {
          if (tempFile.existsSync()) {
            tempFile.deleteSync();
          }
        } catch (e) {
          // Ignore cleanup errors
        }
      });

      return tempFile.path;
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }
}
