import 'package:equatable/equatable.dart';

import '../model/task.dart';

abstract class TaskEvent extends Equatable{
  @override
  List<Object?> get props =>[];
}
class LoadTasks extends TaskEvent{}
class AddTasks extends TaskEvent{
  final Task task;
  AddTasks(this.task);
  @override
  List<Object?> get props => [task];
}
class UpdateTasks extends TaskEvent{
  final int index;
  final Task task;
  @override
  UpdateTasks(this.index,this.task);
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