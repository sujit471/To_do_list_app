import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/task.dart';

class DatabaseHelper {
  // Singleton instance means the variable is initialized only once in the whole process
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Factory constructor that returns the same instance every time
  factory DatabaseHelper() {
    return _instance;
  }

  // Private constructor that  can  be only be called from within the class  where internal is used
  // to  used as a naming convention to indicate the internal use
  DatabaseHelper._internal();

  static Database? _database;
  // indicates that _database is of type Database which is of type provided
  // by the sqflite package to represent an open connection to the SQlite database
  // (_ ) indicates that database is a private variable and will hold the actial connection
  // to the SQlite database once initialized

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Define the path to the database
    final dbPath = join(await getDatabasesPath(), 'tasks.db');

    // Open the database
    return await openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) {
        // Create the task table
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, isCompleted INTEGER,itemType TEXT,subType TEXT,dropdownSelections TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE tasks ADD COLUMN itemType TEXT');
          await db.execute('ALTER TABLE tasks ADD COLUMN subType TEXT');
        }
      },
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final gettask = await db.query('tasks');
    return List.generate(gettask.length, (i) {
      return Task.fromMap(gettask[i]);
    });
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
