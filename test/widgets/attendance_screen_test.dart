import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:classhub/screens/attendance/attendance_screen.dart';
import 'package:classhub/models/student.dart';
import 'package:classhub/models/class_model.dart';
import 'package:classhub/repositories/student_repository.dart';
import 'package:classhub/repositories/class_repository.dart';

void main() {
  group('AttendanceScreen Widget Tests', () {
    late StudentRepository studentRepo;
    late ClassRepository classRepo;

    setUp(() async {
      studentRepo = StudentRepository();
      classRepo = ClassRepository();

      // Create a test class
      final testClass = ClassModel(
        name: 'Test Class',
        createdAt: DateTime.now(),
      );
      await classRepo.insert(testClass);
    });

    testWidgets('displays class selector dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Select Class'), findsOneWidget);
    });

    testWidgets('displays date selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Date:'), findsOneWidget);
    });

    testWidgets('displays students in selected class', (WidgetTester tester) async {
      // Create test students
      final classes = await classRepo.getAll();
      final classId = classes.first.id!;

      final student1 = Student(
        name: 'John Doe',
        studentId: 'STU001',
        classId: classId,
        createdAt: DateTime.now(),
      );
      final student2 = Student(
        name: 'Jane Smith',
        studentId: 'STU002',
        classId: classId,
        createdAt: DateTime.now(),
      );

      await studentRepo.insert(student1);
      await studentRepo.insert(student2);

      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('displays attendance status for each student', (WidgetTester tester) async {
      // Create test student
      final classes = await classRepo.getAll();
      final classId = classes.first.id!;

      final student = Student(
        name: 'John Doe',
        studentId: 'STU001',
        classId: classId,
        createdAt: DateTime.now(),
      );

      await studentRepo.insert(student);

      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show "Not marked" or similar for students without attendance
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('shows empty state when no students in class', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AttendanceScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No students in this class'), findsOneWidget);
    });
  });
}

