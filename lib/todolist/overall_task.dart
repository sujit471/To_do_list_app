import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../model/task.dart';
class OverallTaskScreen extends StatefulWidget {
  final Task task;
  const OverallTaskScreen({Key? key, required this.task}) : super(key: key);
  @override
  _OverallTaskScreenState createState() => _OverallTaskScreenState();
}

class _OverallTaskScreenState extends State<OverallTaskScreen> {
  late List<Map<String, dynamic>> dropdownSelections;

  @override
  void initState() {
    super.initState();
    // Initialize the dropdownSelections list from the task
    dropdownSelections = List<Map<String, dynamic>>.from(widget.task.dropdownSelections);
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
        title: const Text('Task Details'),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is TaskLoadSuccess) {
            final tasks = state.tasks;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(155, 134, 250, 1.0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        'Title: ${widget.task.title}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(155, 134, 250, 1.0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        'Description: ${widget.task.description}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Selected Items:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: dropdownSelections.length,
                      itemBuilder: (context, index) {
                        // Ensure we only access the existing indices of the tasks list
                        if (index >= tasks.length) {
                          return SizedBox.shrink(); // Skip invalid entries
                        }

                        final task = tasks[index];
                        final selection = dropdownSelections[index];
                        final mainItem = selection["mainItem"] as String?;
                        final subItem = selection["subItem"] as String?;
                        final mainItemText = mainItem != null ? 'Task: $mainItem' : 'Task: Not selected';
                        final subItemText = subItem != null ? 'Subtask: $subItem' : 'Subtask: Not selected';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0), // Space between items
                          child: Container(
                            height: 90,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mainItemText,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        subItemText,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
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
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is TaskLoadFailure) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
      ),
    );
  }
}
