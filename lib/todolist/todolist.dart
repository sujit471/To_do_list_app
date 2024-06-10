import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:to_do_list/model/task.dart';
import 'package:to_do_list/model/task_detail_screen.dart';
import 'expanded list.dart';
import 'notification.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
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

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
      _saveTasks();
    });
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

  void _updateTask(Task task, int index) {
    setState(() {
      _tasks[index] = task;
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

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveTasks();
    });
  }

  double calculateProgress() {
    if (_tasks.isEmpty) return 0.0;
    int completedTasks = _tasks.where((task) => task.isCompleted).length;
    return (completedTasks / _tasks.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            size: 30,
          ),
          onPressed: () {
            // Handle menu button press
            print('Menu button pressed');
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              size: 30,
            ),
            onPressed: () {
              // Handle search button press
              print('Search button pressed');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications,
              size: 30,
            ),
            onPressed: () {
              // Handle notification button press
              print('Notification button pressed');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Hello Mohin',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(' ${_remainingTasksCount} Task are pending', style: TextStyle(
                fontSize: 18,
              ),),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0), // Adjust the padding as needed
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.stacked_line_chart_outlined,
                        color: Color.fromRGBO(255, 116, 97, 1.0),
                      ),
                      onPressed: () {
                        // Clear the search query
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  onChanged: (value) {
                    // Handle the search query change
                  },
                  maxLines: 1, // Ensure the TextField remains single-line
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Ongoing Task",
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 35.0,
                            lineWidth: 5.0,
                            percent: calculateProgress() / 100,
                            center: Text(
                              "${calculateProgress().toStringAsFixed(0)}%",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            progressColor: Colors.green,
                          ),
                          const Spacer(),
                          Text(
                            '6 days left ',
                            style: TextStyle(
                                color: Color.fromRGBO(255, 116, 97, 1.0),
                                fontSize: 22),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Space app design",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Transform.rotate(
                              angle: -0.6,
                              child: Image.asset(
                                'images/rocket.jpg',
                                width: 100,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Text(
                    "Todays task",
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Expandedlist()),
                      );
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(
                          color: Color.fromRGBO(255, 116, 97, 1.0), fontSize: 20),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // Added shrinkWrap and physics
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
                        leading: CircleAvatar(
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
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: Task(title: '')),
            ),
          );
          if (newTask != null) {
            _addTask(newTask);
          }
        },
      ),
    );
  }
}
