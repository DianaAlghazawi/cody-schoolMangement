import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:classhub/screens/students/students_list_screen.dart';
import 'package:classhub/models/student.dart';
import 'package:classhub/repositories/student_repository.dart';
import 'package:classhub/repositories/class_repository.dart';
import 'package:classhub/models/class_model.dart';

void main() {
  group('StudentsListScreen Widget Tests', () {
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

    testWidgets('displays empty state when no students', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentsListScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No students yet'), findsOneWidget);
      expect(find.text('Tap the + button to add a student'), findsOneWidget);
    });

    testWidgets('displays list of students', (WidgetTester tester) async {
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
          home: StudentsListScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('STU001'), findsOneWidget);
      expect(find.text('STU002'), findsOneWidget);
    });

    testWidgets('search filters students by name', (WidgetTester tester) async {
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
          home: StudentsListScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'John');
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsNothing);
    });

    testWidgets('search filters students by student ID', (WidgetTester tester) async {
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
          home: StudentsListScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'STU002');
      await tester.pumpAndSettle();

      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('John Doe'), findsNothing);
    });

    testWidgets('floating action button is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentsListScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}

