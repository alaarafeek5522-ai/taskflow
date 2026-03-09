import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('taskflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT,
        dueHour INTEGER,
        dueMinute INTEGER,
        priority INTEGER NOT NULL DEFAULT 1,
        category INTEGER NOT NULL DEFAULT 3,
        status INTEGER NOT NULL DEFAULT 0,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurringPattern TEXT,
        subTasks TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().substring(0, 10);
    final maps = await db.query('tasks', where: "dueDate LIKE ?", whereArgs: ['$dateStr%']);
    return maps.map((m) => Task.fromMap(m)).toList();
  }
}
