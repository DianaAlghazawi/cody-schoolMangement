import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/student.dart';
import '../../models/class_model.dart';
import '../../repositories/student_repository.dart';
import '../../repositories/class_repository.dart';

class AddEditStudentScreen extends StatefulWidget {
  final Student? student;

  const AddEditStudentScreen({super.key, this.student});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final StudentRepository _studentRepo = StudentRepository();
  final ClassRepository _classRepo = ClassRepository();

  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    if (widget.student != null) {
      _nameController.text = widget.student!.name;
      _studentIdController.text = widget.student!.studentId;
      _parentNameController.text = widget.student!.parentName ?? '';
      _parentPhoneController.text = widget.student!.parentPhone ?? '';
      _photoPath = widget.student!.photoPath;
    }
  }

  Future<void> _loadClasses() async {
    final classes = await _classRepo.getAll();
    setState(() {
      _classes = classes;
      if (widget.student != null) {
        _selectedClass = classes.firstWhere(
          (c) => c.id == widget.student!.classId,
          orElse: () => classes.first,
        );
      } else if (classes.isNotEmpty) {
        _selectedClass = classes.first;
      }
    });
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate() || _selectedClass == null) {
      return;
    }

    try {
      final student = Student(
        id: widget.student?.id,
        name: _nameController.text.trim(),
        studentId: _studentIdController.text.trim(),
        classId: _selectedClass!.id!,
        parentName: _parentNameController.text.trim().isEmpty
            ? null
            : _parentNameController.text.trim(),
        parentPhone: _parentPhoneController.text.trim().isEmpty
            ? null
            : _parentPhoneController.text.trim(),
        photoPath: _photoPath ?? widget.student?.photoPath,
        createdAt: widget.student?.createdAt ?? DateTime.now(),
      );

      if (widget.student == null) {
        await _studentRepo.insert(student);
      } else {
        await _studentRepo.update(student);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving student: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _photoPath != null &&
                                  File(_photoPath!).existsSync()
                              ? FileImage(File(_photoPath!)) as ImageProvider
                              : null,
                          child: _photoPath == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                        if (_photoPath != null)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.red,
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    size: 18, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _photoPath = null;
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter student ID';
                  }
                  return null;
                },
                enabled: widget.student == null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ClassModel>(
                initialValue: _selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Class *',
                  border: OutlineInputBorder(),
                ),
                items: _classes.map((classModel) {
                  return DropdownMenuItem(
                    value: classModel,
                    child: Text(classModel.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a class';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _parentNameController,
                decoration: const InputDecoration(
                  labelText: 'Parent Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _parentPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Parent Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveStudent,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Save Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }
}
