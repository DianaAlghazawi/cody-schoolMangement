import 'package:flutter/material.dart';
import '../../models/announcement.dart';
import '../../models/class_model.dart';
import '../../repositories/announcement_repository.dart';
import '../../repositories/class_repository.dart';
import '../../providers/app_provider.dart';
import 'package:provider/provider.dart';

class AddEditAnnouncementScreen extends StatefulWidget {
  final Announcement? announcement;

  const AddEditAnnouncementScreen({super.key, this.announcement});

  @override
  State<AddEditAnnouncementScreen> createState() =>
      _AddEditAnnouncementScreenState();
}

class _AddEditAnnouncementScreenState extends State<AddEditAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final AnnouncementRepository _announcementRepo = AnnouncementRepository();
  final ClassRepository _classRepo = ClassRepository();

  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  List<String> _attachmentPaths = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
    if (widget.announcement != null) {
      _titleController.text = widget.announcement!.title;
      _contentController.text = widget.announcement!.content;
      _attachmentPaths =
          List<String>.from(widget.announcement!.attachmentPaths ?? []);
    }
  }

  Future<void> _loadClasses() async {
    final classes = await _classRepo.getAll();
    setState(() {
      _classes = classes;
    });
  }

  Future<void> _saveAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final teacherId = appProvider.currentUser?.id ?? 1;

      final announcement = Announcement(
        id: widget.announcement?.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        classId: _selectedClass?.id,
        teacherId: teacherId,
        date: widget.announcement?.date ?? DateTime.now(),
        attachmentPaths: _attachmentPaths.isNotEmpty ? _attachmentPaths : null,
        createdAt: widget.announcement?.createdAt ?? DateTime.now(),
      );

      if (widget.announcement == null) {
        await _announcementRepo.insert(announcement);
      } else {
        await _announcementRepo.update(announcement);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving announcement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.announcement == null
            ? 'New Announcement'
            : 'Edit Announcement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ClassModel>(
                initialValue: _selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Class (leave empty for all classes)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<ClassModel>(
                    value: null,
                    child: Text('All Classes'),
                  ),
                  ..._classes.map((classModel) {
                    return DropdownMenuItem(
                      value: classModel,
                      child: Text(classModel.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedClass = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Photo Attachments Section
              if (_attachmentPaths.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attachments:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _attachmentPaths.map((path) {
                        return Chip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.attachment, size: 16),
                              const SizedBox(width: 4),
                              const Text('Photo'),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _attachmentPaths.remove(path);
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAnnouncement,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Save Announcement'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
