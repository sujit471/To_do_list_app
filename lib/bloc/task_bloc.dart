import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_list/bloc/task_event.dart';
import 'package:to_do_list/bloc/task_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/task.dart';

class TaskBloc extends Bloc<TaskEvent,TaskState>{
TaskBloc(): super(TaskInitial()){
on<LoadTasks>(_onLoadTasks);
on<AddTasks>(_addTasks);
on<UpdateTasks>(_updateTasks);
on<DeleteTask>(_deleteTasks);
on<ToggleTaskCompletion>(_ontoggleTaskCompletion);
}
Future <void> _onLoadTasks(LoadTasks event, Emitter<TaskState>emit)async{
SharedPreferences prefs = await SharedPreferences.getInstance();
String? taskJson = prefs.getString('tasks');
if(taskJson!=null){
  Iterable decoded = jsonDecode(taskJson);
  List<Task> tasks = decoded.map((task)=> Task.fromMap(task)).toList();
  emit(TaskLoadSuccess(tasks));

}
else {
  emit(TaskLoadFailure('Failed to load tasks'));
}
}
Future<void> _addTasks(AddTasks event , Emitter<TaskState>emit)async {
  if(state is TaskLoadSuccess){
    final List<Task>updatedTasks = List.from((state as TaskLoadSuccess).tasks)..add(event.task);
    await _saveTasks(updatedTasks);
    emit(TaskLoadSuccess(updatedTasks));
  }
}
Future <void> _saveTasks(List<Task>tasks)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String tasksJson = jsonEncode(tasks.map((task) => task.toMap()).toList());
  await prefs.setString('tasks', tasksJson);
}
Future<void> _updateTasks(UpdateTasks event, Emitter<TaskState> emit) async {

  if (state is TaskLoadSuccess) {

    final List<Task> updatedTasks = List.from((state as TaskLoadSuccess).tasks);
    updatedTasks[event.index] = event.task;
    await _saveTasks(updatedTasks);
    emit(TaskLoadSuccess(updatedTasks));
  }
}

Future<void> _deleteTasks(DeleteTask event, Emitter<TaskState> emit) async {
  if (state is TaskLoadSuccess) {
    final List<Task> updatedTasks = List.from((state as TaskLoadSuccess).tasks)
      ..removeAt(event.index);
    await _saveTasks(updatedTasks);
    emit(TaskLoadSuccess(updatedTasks));
  }
}

Future<void> _ontoggleTaskCompletion(ToggleTaskCompletion event, Emitter<TaskState> emit) async {
  if (state is TaskLoadSuccess) {
    final List<Task> updatedTasks = List.from((state as TaskLoadSuccess).tasks);
    final Task task = updatedTasks[event.index];
    updatedTasks[event.index] = task.copyWith(isCompleted: !task.isCompleted);
    await _saveTasks(updatedTasks);
    emit(TaskLoadSuccess(updatedTasks));
  }
}
}