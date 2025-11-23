import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../repositories/announcement_repository.dart';
import '../../repositories/attendance_repository.dart';
import '../../models/announcement.dart';
import '../../models/attendance_record.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final AnnouncementRepository _announcementRepo = AnnouncementRepository();
  final AttendanceRepository _attendanceRepo = AttendanceRepository();

  DateTime _selectedDate = DateTime.now();
  List<Announcement> _announcements = [];
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final announcements = await _announcementRepo.getAll();
    final attendance = await _attendanceRepo.getByDate(_selectedDate);

    setState(() {
      _announcements = announcements;
      _attendanceRecords = attendance;
      _isLoading = false;
    });
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
      await _loadData();
    }
  }

  List<Announcement> _getAnnouncementsForDate(DateTime date) {
    return _announcements.where((a) {
      return a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dayAnnouncements = _getAnnouncementsForDate(_selectedDate);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_attendanceRecords.isNotEmpty) ...[
                          Text(
                            'Attendance (${_attendanceRecords.length})',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildStatRow(
                                    'Present',
                                    _attendanceRecords
                                        .where((r) => r.status == 'present')
                                        .length,
                                    Colors.green,
                                  ),
                                  _buildStatRow(
                                    'Absent',
                                    _attendanceRecords
                                        .where((r) => r.status == 'absent')
                                        .length,
                                    Colors.red,
                                  ),
                                  _buildStatRow(
                                    'Late',
                                    _attendanceRecords
                                        .where((r) => r.status == 'late')
                                        .length,
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        const Text(
                          'Announcements',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (dayAnnouncements.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No announcements for this date'),
                            ),
                          )
                        else
                          ...dayAnnouncements.map((announcement) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(announcement.title),
                                  subtitle: Text(announcement.content),
                                ),
                              )),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
