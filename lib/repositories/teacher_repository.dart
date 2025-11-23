import '../database/database_helper.dart';
import '../models/teacher.dart';

class TeacherRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(Teacher teacher) async {
    final db = await _dbHelper.database;
    return await db.insert('teachers', teacher.toMap());
  }

  Future<List<Teacher>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('teachers', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }

  Future<Teacher?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'teachers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Teacher.fromMap(maps.first);
    }
    return null;
  }

  Future<Teacher?> getByEmail(String email) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'teachers',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return Teacher.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Teacher teacher) async {
    final db = await _dbHelper.database;
    return await db.update(
      'teachers',
      teacher.toMap(),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'teachers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
