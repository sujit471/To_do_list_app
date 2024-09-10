import 'dart:async';
import 'package:to_do_list/database/new_database.dart';
import 'bloc_export.dart';
import '../model/task.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  //final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NewDatabase _databaseHelper = NewDatabase();


  TaskBloc() : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTasks>(_addTasks);
    on<UpdateTasks>(_updateTasks);
    on<DeleteTask>(_deleteTasks);
    on<ToggleTaskCompletion>(_toggleTaskCompletion);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
  //  try {
      final tasks = await _databaseHelper.getTasks();
      emit(TaskLoadSuccess(tasks));
    // } catch (e) {
    //   emit(TaskLoadFailure('Failed to load tasks'));
    // }
  }

  Future<void> _addTasks(AddTasks event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final updatedTasks = List<Task>.from((state as TaskLoadSuccess).tasks)
        ..add(event.task);
     var id = await _databaseHelper.insertTask(event.task);
     //await _databaseHelper.insertDropdownSelection(event.task as int,event.task as int);
      emit(TaskLoadSuccess(updatedTasks));
    }
  }

  Future<void> _updateTasks(UpdateTasks event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final updatedTasks = List<Task>.from((state as TaskLoadSuccess).tasks);
      updatedTasks[event.index] = event.task;
      await _databaseHelper.updateTask(event.task);
      emit(TaskLoadSuccess(updatedTasks));
    }
  }

  Future<void> _deleteTasks(DeleteTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final updatedTasks = List<Task>.from((state as TaskLoadSuccess).tasks);
      final taskToDelete = updatedTasks[event.index];
      final taskId = taskToDelete.id;
      if (taskId != null) {
        await _databaseHelper.deleteTask(taskId);
        updatedTasks.removeAt(event.index);
        emit(TaskLoadSuccess(updatedTasks));
      } else {
        emit(TaskLoadFailure('Failed to delete task: ID is null'));
      }
    }
  }

  Future<void> _toggleTaskCompletion(ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final updatedTasks = List<Task>.from((state as TaskLoadSuccess).tasks);
      final task = updatedTasks[event.index];
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      updatedTasks[event.index] = updatedTask;
      await _databaseHelper.updateTask(updatedTask);
      emit(TaskLoadSuccess(updatedTasks));
    }
  }
}
