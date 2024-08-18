import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../model/task_detail_screen.dart';
import '../model/task.dart';
import 'expanded list.dart';

import 'notification.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
  }

  void _addTask(Task task) {
    context.read<TaskBloc>().add(AddTasks(task));
  }

  void _updateTask(Task task, int index) {
    context.read<TaskBloc>().add(UpdateTasks(index, task));
  }

  void _deleteTask(int index) {
    context.read<TaskBloc>().add(DeleteTask(index));
  }

  void _toggleTaskCompletion(int index) {
    context.read<TaskBloc>().add(ToggleTaskCompletion(index));
  }
  // Calculate the completion progress of tasks
  double calculateProgress(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;
    int completedTasks = tasks.where((task) => task.isCompleted).length;
    return (completedTasks / tasks.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 30),
          onPressed: () {
            print('Menu button pressed');
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, size: 30),
            onPressed: () {
              print('Search button pressed');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, size: 30),
            onPressed: () {
              print('Notification button pressed');
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoadSuccess) {
            final tasks = state.tasks;
            final remainingTaskCount = tasks.where((task) => !task.isCompleted).length;
            return SingleChildScrollView(
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
                    Text(
                      '$remainingTaskCount Task${remainingTaskCount > 1 ? 's' : ''} are pending',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
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
                              // Handle search query
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onChanged: (value) {
                          // Handle search query
                        },
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Ongoing Task",
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 35.0,
                                  lineWidth: 5.0,
                                  percent: calculateProgress(tasks) / 100,
                                  center: Text(
                                    "${calculateProgress(tasks).toStringAsFixed(0)}%",
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
                                const SizedBox(width: 12),
                                Transform.rotate(
                                  angle: -0.6,
                                  child: Image.asset(
                                    'images/rocket.jpg',
                                    width: 100,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        const Text(
                          "Today's task",
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
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                                          builder: (context) => TaskDetailScreen(task: task),
                                        ),
                                      );
                                      if (updatedTask != null) {
                                        _updateTask(updatedTask, index); // Correct method call
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
                                    builder: (context) => TaskDetailScreen(task: task),
                                  ),
                                );
                                if (updatedTask != null) {
                                  _updateTask(updatedTask, index); // Correct method call
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
          } else if (state is TaskLoadFailure) {
            return Center(child: Text(state.message));
          }

          return Container();
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskDetailScreen(task: Task(title: ''))),
          );
          if (newTask != null) {
            _addTask(newTask);
          }
        },
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

