import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../model/task.dart';
import '../model/task_detail_screen.dart';
import 'notification.dart';

class Expandedlist extends StatefulWidget {
  Expandedlist({super.key});

  @override
  State<Expandedlist> createState() => _ExpandedlistState();
}

class _ExpandedlistState extends State<Expandedlist> {
  @override
  void initState() {
    super.initState();

    context.read<TaskBloc>().add(LoadTasks());
  }

  // void _addTask(Task task) {
  //   context.read<TaskBloc>().add(AddTasks(task));
  // }

  void _updateTask(Task task, int index) {
    context.read<TaskBloc>().add(UpdateTasks(index, task));
  }

  void _deleteTask(int index) {
    context.read<TaskBloc>().add(DeleteTask(index));
  }

  void _toggleTaskCompletion(int index) {
    context.read<TaskBloc>().add(ToggleTaskCompletion(index));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            int remainingTasks = state is TaskLoadSuccess
                ? state.tasks.where((task) => !task.isCompleted).length
                : 0;
            return Text('Task List ($remainingTasks left)');
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoadFailure) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is TaskLoadSuccess) {
            // Use the tasks from the state
            final tasks = state.tasks;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(155, 134, 250, 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.black,
                              radius: 4,
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                color: Colors.white,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(
                              task.description,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () async {
                                    final updatedTask = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TaskDetailScreen(task: task),
                                      ),
                                    );
                                    if (updatedTask != null) {
                                      _updateTask(updatedTask, index);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: () {
                                    _deleteTask(index);
                                  },
                                ),
                                Checkbox(
                                  activeColor: Colors.purple,
                                  value: task.isCompleted,
                                  onChanged: (bool? value) {
                                    _toggleTaskCompletion(index);
                                  },
                                ),
                              ],
                            ),
                            onTap: () async {
                              final updatedTask = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TaskDetailScreen(task: task),
                                ),
                              );
                              if (updatedTask != null) {
                                _updateTask(updatedTask, index);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No tasks found.'));
          }
        },
      ),
    );
  }
}
