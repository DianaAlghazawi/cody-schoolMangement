import '../database/database_helper.dart';
import '../models/class_model.dart';

class ClassRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(ClassModel classModel) async {
    final db = await _dbHelper.database;
    return await db.insert('classes', classModel.toMap());
  }

  Future<List<ClassModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('classes', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => ClassModel.fromMap(maps[i]));
  }

  Future<ClassModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'classes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ClassModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(ClassModel classModel) async {
    final db = await _dbHelper.database;
    return await db.update(
      'classes',
      classModel.toMap(),
      where: 'id = ?',
      whereArgs: [classModel.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'classes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
