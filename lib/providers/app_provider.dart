import 'package:flutter/foundation.dart';
import '../models/teacher.dart';
import '../models/class_model.dart';
import '../repositories/teacher_repository.dart';
import '../repositories/class_repository.dart';

class AppProvider with ChangeNotifier {
  final TeacherRepository _teacherRepo = TeacherRepository();
  final ClassRepository _classRepo = ClassRepository();
  Teacher? _currentUser;
  bool _isInitialized = false;

  Teacher? get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isTeacher => _currentUser?.isTeacher ?? false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // For demo mode, create a default admin user if none exists
      final teachers = await _teacherRepo.getAll();
      if (teachers.isEmpty) {
        final defaultAdmin = Teacher(
          name: 'Admin User',
          email: 'admin@classhub.app',
          role: 'admin',
          createdAt: DateTime.now(),
        );
        await _teacherRepo.insert(defaultAdmin);
        _currentUser = defaultAdmin;
      } else {
        _currentUser = teachers.first;
      }

      // Create classes 1-10 if none exist
      final classes = await _classRepo.getAll();
      if (classes.isEmpty) {
        for (int i = 1; i <= 10; i++) {
          final classModel = ClassModel(
            name: 'Class $i',
            description: 'Class $i',
            createdAt: DateTime.now(),
          );
          await _classRepo.insert(classModel);
        }
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Even if initialization fails, mark as initialized to show the app
      // This prevents the app from being stuck on the splash screen
      debugPrint('Error during initialization: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setCurrentUser(Teacher teacher) async {
    _currentUser = teacher;
    notifyListeners();
  }

  Future<void> switchUser(String email) async {
    final teacher = await _teacherRepo.getByEmail(email);
    if (teacher != null) {
      _currentUser = teacher;
      notifyListeners();
    }
  }
}
