import 'package:equatable/equatable.dart';
import '../model/task.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoadSuccess extends TaskState {
  final List<Task> tasks;

  TaskLoadSuccess(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskLoadFailure extends TaskState {
  final String message;

  TaskLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
