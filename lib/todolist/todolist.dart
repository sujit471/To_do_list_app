import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:to_do_list/model/task.dart';
import 'package:to_do_list/model/task_detail_screen.dart';
import 'package:to_do_list/bloc/bloc_export.dart';
import 'expanded list.dart';
import 'notification.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool _isTapped = false ;
  List<Task> _tasks = [];

  void _onTap() {
    setState(() {
      _isTapped = true;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isTapped = false;
      });
    });
  }
  @override
  void initState() {
    super.initState();
    _loadTasks();
    context.read<TaskBloc>().add(LoadTasks());
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
    NotificationService().showNotification(
      0,
      'Task Created',
      'The task "${task.title}" has been added.',
    );
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
      body: BlocBuilder<TaskBloc,TaskState>(
        builder: (context,state){
          if(state is TaskInitial){
            return const CircularProgressIndicator();
          }
           if(state  is TaskLoadSuccess){
             final tasks = state.tasks;
             final remainingTskCount = tasks.where((task)=> !task.isCompleted).length;
            return  SingleChildScrollView(
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
                    const SizedBox(height: 10),
                    Text(' $_remainingTasksCount Task are pending', style: const TextStyle(
                      fontSize: 18,
                    ),),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0), // Adjust the padding as needed
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(
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
                                const Text(
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
                                const SizedBox(
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
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Todays task",
                          style: TextStyle(fontSize: 20),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Expandedlist()),
                            );
                          },
                          child: const Text(
                            'See all',
                            style: TextStyle(
                                color: Color.fromRGBO(255, 116, 97, 1.0), fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // Added shrinkWrap and physics
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
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
                                  fontSize: 25,
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
                                       //
                                        // _updateTask(updatedTask, index);
                                        BlocProvider.of<TaskBloc>(context).add(UpdateTasks(index,updatedTask));
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.white),
                                    onPressed: () {
                                      _deleteTask(index);
                                      // //BlocProvider.of<TaskBloc>(context)
                                      //     .add(DeleteTask(index));
                                    },
                                  ),
                                  Checkbox(
                                    activeColor: Colors.purple,
                                    value: task.isCompleted,
                                    onChanged: (bool? value) {

                                      _toggleTaskCompletion(index);
                                      BlocProvider.of<TaskBloc>(context)
                                          .add(ToggleTaskCompletion(index));
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
                                 // _updateTask(updatedTask, index);
                                  BlocProvider.of<TaskBloc>(context)
                                      .add(UpdateTasks(index, updatedTask));
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
            );
          }
          else if(state is TaskLoadFailure){
            return Center(child:  Text(state.message),);
          }

return Container();
        },

      ),
      floatingActionButton: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20)
        ),
        child: Center(
          heightFactor: 1.0,
          child: FloatingActionButton.extended(
            backgroundColor: const Color.fromRGBO(255, 116, 97, 1.0),
            foregroundColor: Colors.white,
            elevation: 2,
            label: const Text('Add new task'),
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
        ),
      ),
    );
  }
}
