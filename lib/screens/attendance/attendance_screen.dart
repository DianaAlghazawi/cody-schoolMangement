import 'package:classhub/models/class_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/student.dart';
import '../../models/attendance_record.dart';
import '../../repositories/student_repository.dart';
import '../../repositories/class_repository.dart';
import '../../repositories/attendance_repository.dart';
import '../../services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final StudentRepository _studentRepo = StudentRepository();
  final ClassRepository _classRepo = ClassRepository();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();
  final AttendanceService _attendanceService = AttendanceService();

  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  List<Student> _students = [];
  DateTime _selectedDate = DateTime.now();
  Map<int, AttendanceRecord?> _attendanceMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final classes = await _classRepo.getAll();
    setState(() {
      _classes = classes;
      if (classes.isNotEmpty) {
        _selectedClass = classes.first;
      }
    });
    await _loadStudents();
    await _loadAttendance();
    setState(() => _isLoading = false);
  }

  Future<void> _loadStudents() async {
    if (_selectedClass == null) {
      setState(() => _students = []);
      return;
    }
    final students = await _studentRepo.getByClassId(_selectedClass!.id!);
    setState(() => _students = students);
  }

  Future<void> _loadAttendance() async {
    final records = await _attendanceRepo.getByDate(_selectedDate);
    final map = <int, AttendanceRecord?>{};
    for (var student in _students) {
      map[student.id!] = records.firstWhere(
        (r) => r.studentId == student.id,
        orElse: () => AttendanceRecord(
          studentId: student.id!,
          date: _selectedDate,
          status: 'absent',
          createdAt: DateTime.now(),
        ),
      );
    }
    setState(() => _attendanceMap = map);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _loadAttendance();
    }
  }

  Future<void> _markAttendance(int studentId, String action) async {
    try {
      if (action == 'checkIn') {
        await _attendanceService.checkIn(studentId);
      } else if (action == 'checkOut') {
        await _attendanceService.checkOut(studentId);
      } else if (action == 'absent') {
        await _attendanceService.markAbsent(studentId);
      } else if (action == 'late') {
        await _attendanceService.markLate(studentId);
      }
      await _loadAttendance();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance marked successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _getStatusText(AttendanceRecord? record) {
    if (record == null) return 'Not marked';
    if (record.checkInTime != null && record.checkOutTime != null) {
      return '${record.checkInTime} - ${record.checkOutTime}';
    }
    if (record.checkInTime != null) {
      return 'Checked in: ${record.checkInTime}';
    }
    return record.status.toUpperCase();
  }

  Color _getStatusColor(AttendanceRecord? record) {
    if (record == null) return Colors.grey;
    switch (record.status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'early_leave':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<ClassModel>(
                  initialValue: _selectedClass,
                  decoration: const InputDecoration(
                    labelText: 'Select Class',
                    border: OutlineInputBorder(),
                  ),
                  items: _classes.map((classModel) {
                    return DropdownMenuItem(
                      value: classModel,
                      child: Text(classModel.name),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    setState(() => _selectedClass = value);
                    await _loadStudents();
                    await _loadAttendance();
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _students.isEmpty
                    ? const Center(child: Text('No students in this class'))
                    : ListView.builder(
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          final record = _attendanceMap[student.id];
                          final statusColor = _getStatusColor(record);

                          return Semantics(
                            label:
                                'Student ${student.name}, ${_getStatusText(record)}',
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(student.name[0].toUpperCase()),
                                ),
                                title: Text(
                                  student.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(_getStatusText(record)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      onSelected: (value) =>
                                          _markAttendance(student.id!, value),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'checkIn',
                                          child: Text('Check In'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'checkOut',
                                          child: Text('Check Out'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'late',
                                          child: Text('Mark Late'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'absent',
                                          child: Text('Mark Absent'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
