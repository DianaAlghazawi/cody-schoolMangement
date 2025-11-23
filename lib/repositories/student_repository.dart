import '../database/database_helper.dart';
import '../models/student.dart';

class StudentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(Student student) async {
    final db = await _dbHelper.database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('students', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<List<Student>> getByClassId(int classId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'students',
      where: 'classId = ?',
      whereArgs: [classId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<Student?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Student student) async {
    final db = await _dbHelper.database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Student>> search(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'students',
      where: 'name LIKE ? OR studentId LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }
}
