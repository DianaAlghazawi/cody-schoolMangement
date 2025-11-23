import '../database/database_helper.dart';
import '../models/announcement.dart';

class AnnouncementRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(Announcement announcement) async {
    final db = await _dbHelper.database;
    return await db.insert('announcements', announcement.toMap());
  }

  Future<List<Announcement>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('announcements', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Announcement.fromMap(maps[i]));
  }

  Future<List<Announcement>> getByClassId(int? classId) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> maps;
    if (classId == null) {
      maps = await db.query(
        'announcements',
        where: 'classId IS NULL',
        orderBy: 'date DESC',
      );
    } else {
      maps = await db.query(
        'announcements',
        where: 'classId = ? OR classId IS NULL',
        whereArgs: [classId],
        orderBy: 'date DESC',
      );
    }
    return List.generate(maps.length, (i) => Announcement.fromMap(maps[i]));
  }

  Future<Announcement?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'announcements',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Announcement.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Announcement announcement) async {
    final db = await _dbHelper.database;
    return await db.update(
      'announcements',
      announcement.toMap(),
      where: 'id = ?',
      whereArgs: [announcement.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'announcements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
