import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:to_do_list/model/sub_task_model.dart';
import '../model/task.dart';

class NewDatabase {
  static final NewDatabase _instance = NewDatabase._internal();
  factory NewDatabase() {
    return _instance;
  }
  NewDatabase._internal();
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = join(await getDatabasesPath(), 'all_tasks.db');
      return await openDatabase(
        dbPath,
        version: 4,
        onCreate: (db, version) async {
          await db.execute(
              '''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            isCompleted INTEGER,  
            dropdownSelections TEXT
          )
          '''
          );
          await db.execute(
              '''
          CREATE TABLE subTask(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mainItems TEXT,
            subItems TEXT,
            task_id INTEGER,
            FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
          )
          '''
          );

        },
        onUpgrade: (db, oldVersion, newVersion) async {

          if (oldVersion < 4) {
            await db.execute('ALTER TABLE tasks ADD COLUMN itemType TEXT');
            await db.execute('ALTER TABLE tasks ADD COLUMN subType TEXT');
            await db.execute('ALTER TABLE tasks ADD COLUMN dropdownSelections TEXT');
          }
        },
          //pragma  foreign keys on helps in connecting the task table and the subtask table
          // such that  when  the task are deleted all the related subtask are also automatically deleted

        onOpen: (db) async{
          await db.execute('PRAGMA foreign_keys = ON');
        }
      );
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }




  // CRUD operations for tasks
  Future<List<Task>> getTasks() async {
    final db = await database;
    final getTask = await db.query('tasks');
    return List.generate(getTask.length, (i) {
      return Task.fromMap(getTask[i]);
    });
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    final  id = await db.insert('tasks', task.toMap());
    print('Inserted task with id : $id');
    print('Inserting task: ${task.toMap()}');
    return id;
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

//   Future<Map<String,dynamic>> getLatestTask(int id) async {
//     final db = await database;
//     final  raw=
//       await db.rawQuery(
//       '''
//       select * from tasks order by rowid desc LIMIT 1
// '''
//     ) as Map<String,dynamic>;
//     return raw;
//   }

  //
  // Future<Map<String, dynamic>> getLatestTaskId() async {
  //   final db = await database;
  //
  //   final List<Map<String, dynamic>> result = await db.rawQuery(
  //       '''
  // SELECT * FROM tasks ORDER BY id DESC LIMIT 1
  // '''
  //   );
  //   if (result.isNotEmpty) {
  //     final task = result.first;
  //     final taskId = task['id'];
  //     // Print or log the taskId
  //     log('Latest taskId: $taskId');
  //
  //     return task;
  //   } else {
  //     log('No tasks found in the database.');
  //     return {}; // Return an empty map if no tasks are found
  //   }
  // }



  //CRUD operations for subTask (mainItems and subItems combined)
  Future<int> insertSubTaskForTask(int taskId, String mainItems, String subItems) async {
    final db = await database;
    return await db.insert('subTask', {
      'mainItems': mainItems,
      'subItems': subItems,
      'task_id': taskId,
    });
  }
  Future<int> updateSubTask(int subTaskId, String mainItems, String subItems) async {
    final db = await database;
    return await db.update(
      'subTask',
      {
        'mainItems': mainItems,
        'subItems': subItems,
      },
      where: 'id = ?',
      whereArgs: [subTaskId],
    );
  }

  Future<int> deleteSubTask(int subTaskId) async {
    final db = await database;
    return await db.delete(
      'subTask',
      where: 'id = ?',
      whereArgs: [subTaskId],
    );
  }
  Future<List<Map<String, dynamic>>> getSubTasksForTask(int taskId) async {
    final db = await database;
    return await db.query(
      'subTask',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }


  Future<List <SubTaskModel>> getSubTasks(int subTaskId) async {
    final db = await database;
    final List<Map<String,dynamic>> data=  await db.query(
      'subTask',
      where: 'task_id = ?',
      whereArgs:  [subTaskId],
    ) ;
    //return data.map((json) => SubTaskModel.fromJson(json)).toList();
    return data.map((e) =>SubTaskModel.fromMap(e)).toList();


  }

  Future<List<Map<String, dynamic>>> getSubTaskById(int id) async {
    final db = await database;
    return await db.query(
      'subTask',
      where: 'id = ?',
      whereArgs: [id],
    );

  }

//  dropdown selections
// Future<int> insertDropdownSelection(int taskId, int subTaskId) async {
//   final db = await database;
//   return await db.insert('tasks', {
//     'subTaskId': subTaskId,
//   });
// }
//
// Future<List<Map<String, dynamic>>> getDropdownSelections(int taskId) async {
//   final db = await database;
//   return await db.query(
//     'tasks',
//     where: 'id = ?',
//     whereArgs: [taskId],
//   );
// }
//
// Future<int> updateDropdownSelection(int taskId, int subTaskId) async {
//   final db = await database;
//   return await db.update(
//     'tasks',
//     {
//       'subTaskId': subTaskId,
//     },
//     where: 'id = ?',
//     whereArgs: [taskId],
//   );
// }
// // Future<void> addDropdownItemsForLatestTask(List<Map<String, String>> dropdownItems) async {
// //   // Get the latest task
// //   final latestTask = await getLatestTaskId();
// //   if (latestTask.isEmpty) {
// //     print('No latest task found.');
// //     return;
// //   }
// //
// //   int taskId = latestTask['id'];
// //   for (var item in dropdownItems) {
// //     await insertSubTaskForTask(taskId, item['mainItems']!, item['subItems']!);
// //   }
// // }
//
//
//
// Future<int> deleteDropdownSelection(int id) async {
//   final db = await database;
//   return await db.delete(
//     'tasks',
//     where: 'id = ?',
//     whereArgs: [id],
//   );
// }
}
