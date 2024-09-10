import 'dart:async';
import 'package:to_do_list/database/new_database.dart';
import 'bloc_export.dart';
import '../model/task.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final NewDatabase _databaseHelper = NewDatabase();

  TaskBloc() : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTasks>(_addTasks);
    on<UpdateTasks>(_updateTasks);
    on<DeleteTask>(_deleteTasks);
    on<ToggleTaskCompletion>(_toggleTaskCompletion);
    on<TaskUpdated>((event, emit) async {
      try {
        final tasks = await NewDatabase().getTasks(); // Assuming this fetches updated tasks
        emit(TaskLoadSuccess(tasks));
      } catch (e) {
        emit(TaskLoadFailure(e.toString()));
      }
    });

  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    final tasks = await _databaseHelper.getTasks();
    emit(TaskLoadSuccess(tasks));
  }

  Future<void> _addTasks(AddTasks event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      // Insert the new task into the database
      await _databaseHelper.insertTask(event.task);

      // Re-fetch the updated list of tasks and emit it
      final tasks = await _databaseHelper.getTasks();
      emit(TaskLoadSuccess(tasks));
    }
  }

  Future<void> _updateTasks(UpdateTasks event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      // Update the task in the database
      await _databaseHelper.updateTask(event.task);

      // Re-fetch the updated list of tasks and emit it
      final tasks = await _databaseHelper.getTasks();
      emit(TaskLoadSuccess(tasks));
    }
  }

  Future<void> _deleteTasks(DeleteTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final taskToDelete = (state as TaskLoadSuccess).tasks[event.index];
      final taskId = taskToDelete.id;

      if (taskId != null) {
        await _databaseHelper.deleteTask(taskId);

        // Re-fetch the updated list of tasks and emit it
        final tasks = await _databaseHelper.getTasks();
        emit(TaskLoadSuccess(tasks));
      } else {
        emit(TaskLoadFailure('Failed to delete task: ID is null'));
      }
    }
  }

  Future<void> _toggleTaskCompletion(ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final task = (state as TaskLoadSuccess).tasks[event.index];
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

      // Update the task completion status in the database
      await _databaseHelper.updateTask(updatedTask);
      // Re-fetch the updated list of tasks and emit it
      final tasks = await _databaseHelper.getTasks();
      emit(TaskLoadSuccess(tasks));
    }
  }
}
