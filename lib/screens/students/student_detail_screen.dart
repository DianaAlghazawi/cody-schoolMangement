import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/student.dart';
import '../../repositories/student_repository.dart';
import '../../repositories/class_repository.dart';
import '../../repositories/attendance_repository.dart';
import 'add_edit_student_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final int studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final StudentRepository _studentRepo = StudentRepository();
  final ClassRepository _classRepo = ClassRepository();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  
  Student? _student;
  String? _className;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    final student = await _studentRepo.getById(widget.studentId);
    if (student != null) {
      final classModel = await _classRepo.getById(student.classId);
      setState(() {
        _student = student;
        _className = classModel?.name;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_student == null) {
      return const Scaffold(
        body: Center(child: Text('Student not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_student!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditStudentScreen(student: _student),
                ),
              );
              _loadStudent();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _student!.photoPath != null
                    ? FileImage(File(_student!.photoPath!)) as ImageProvider
                    : null,
                child: _student!.photoPath == null
                    ? Text(
                        _student!.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 40),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard('Student ID', _student!.studentId),
            if (_className != null) _buildInfoCard('Class', _className!),
            if (_student!.parentName != null)
              _buildInfoCard('Parent Name', _student!.parentName!),
            if (_student!.parentPhone != null)
              _buildInfoCard('Parent Phone', _student!.parentPhone!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

