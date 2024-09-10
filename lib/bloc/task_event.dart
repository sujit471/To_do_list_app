import 'package:equatable/equatable.dart';
import '../model/task.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTasks extends TaskEvent {
  final Task task;
  final List<Map<String,dynamic>> dropDownSelection;

  AddTasks(this.task, this.dropDownSelection);

  @override
  List<Object?> get props => [task];
}
class TaskUpdated extends TaskEvent {
  final int taskId;

  TaskUpdated(this.taskId);

  @override
  List<Object> get props => [taskId];
}
class UpdateTasks extends TaskEvent {
  final int index;
  final Task task;

  UpdateTasks(this.index, this.task);

  @override
  List<Object?> get props => [index, task];
}

class DeleteTask extends TaskEvent {
  final int index;

  DeleteTask(this.index);

  @override
  List<Object?> get props => [index];
}


class ToggleTaskCompletion extends TaskEvent {
  final int index;

  ToggleTaskCompletion(this.index);

  @override
  List<Object?> get props => [index];
}
