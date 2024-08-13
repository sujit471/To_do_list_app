import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
 // Import the notification service

import '../model/task.dart';
import '../model/task_detail_screen.dart';
import 'notification.dart';

class Expandedlist extends StatefulWidget {
  Expandedlist({Key? key}) : super(key: key);

  @override
  State<Expandedlist> createState() => _ExpandedlistState();
}

class _ExpandedlistState extends State<Expandedlist> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      Iterable decoded = jsonDecode(tasksJson);
      setState(() {
        _tasks = decoded.map((task) => Task.fromMap(task)).toList();
      });
      _showRemainingTasksNotification();
    }
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tasksJson = jsonEncode(_tasks.map((task) => task.toMap()).toList());
    await prefs.setString('tasks', tasksJson);
    _showRemainingTasksNotification();
  }

  void _updateTask(Task task, int index) {
    setState(() {
      _tasks[index] = task;
      _saveTasks();
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveTasks();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
  }

  int get _remainingTasksCount {
    return _tasks.where((task) => !task.isCompleted).length;
  }

  void _showRemainingTasksNotification() {
    int remainingTasks = _remainingTasksCount;
    String taskText = remainingTasks == 1 ? 'task' : 'tasks';
    NotificationService().showNotification(
      0,
      'Task Reminder',
      'You have $remainingTasks $taskText left to complete.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List ($_remainingTasksCount left)'),
        automaticallyImplyLeading: false, // This removes the back button
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(155, 134, 250, 1.0),
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
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
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
                            icon: Icon(Icons.delete, color: Colors.white),
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
                            builder: (context) => TaskDetailScreen(task: task),
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
      ),
    );
  }
}
