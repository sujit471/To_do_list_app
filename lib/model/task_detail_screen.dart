import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_list/bloc/bloc_export.dart';
import 'package:to_do_list/database/new_database.dart';
import 'package:to_do_list/model/sub_task_model.dart';
import '../widgets/dropdown_item.dart';
import 'task.dart';
import 'dart:developer';
class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;

  List<SubTaskModel> dropdownSelections = [
    SubTaskModel(id: 0, task_id: 0, subItems: '', mainItems: '')
  ];

  @override
  void initState() {
    super.initState();
    _title = widget.task.title;
    _description = widget.task.description;
    getSubTask();
  }

  void getSubTask() async {
    if (widget.task.id != null) {
      dropdownSelections = await NewDatabase().getSubTasks(widget.task.id!);
      log('$dropdownSelections');
      setState(() {});
    }
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
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoadSuccess) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Title TextFormField
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(155, 134, 250, 1.0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        initialValue: _title,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.book, color: Colors.white),
                          labelText: 'Title',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _title = value!;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Description TextFormField
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(155, 134, 250, 1.0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SizedBox(
                        height: 150,
                        child: TextFormField(
                          initialValue: _description,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                            labelStyle: TextStyle(color: Colors.white),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.book, color: Colors.white),
                          ),
                          onSaved: (value) {
                            _description = value!;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: ListView.builder(
                        itemCount: dropdownSelections.length,
                        itemBuilder: (context, index) {
                          final mainItem = dropdownSelections[index].mainItems;
                          final subItem = dropdownSelections[index].subItems;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            padding: const EdgeInsets.all(16.0),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        items: TypeItems.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            dropdownSelections[index].mainItems = newValue!;
                                            dropdownSelections[index].subItems = '';
                                          });
                                        },
                                        hint: const Text('Select Main Item'),
                                        value: mainItem.isNotEmpty && TypeItems.contains(mainItem) ? mainItem : null,
                                      ),
                                      const SizedBox(height: 20),
                                      if (mainItem.isNotEmpty)
                                        DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.blue, width: 2),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          hint: const Text('Select Sub Item'),
                                          value: subItem.isNotEmpty && (subItems[mainItem]?.contains(subItem) ?? false) ? subItem : null,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              dropdownSelections[index].subItems = newValue!;
                                            });
                                          },
                                          items: (subItems[mainItem] ?? []).map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final subtaskId = dropdownSelections[index].id;
                                    if (subtaskId != 0) {
                                      await NewDatabase().deleteSubTask(subtaskId);
                                    }
                                    setState(() {
                                      dropdownSelections.removeAt(index);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Subtask deleted successfully!')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Add New Subtask Button
                    ElevatedButton(
                      child: const Text('+', style: TextStyle(fontSize: 30)),
                      onPressed: () {
                        setState(() {
                          dropdownSelections.add(SubTaskModel(id: 0, task_id: 0, subItems: '', mainItems: ''));
                        });
                      },
                    ),
                    // Save Button
                    Center(
                      child: ElevatedButton(
                        child: const Text('Save'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            for (var selection in dropdownSelections) {
                              if (selection.mainItems.isEmpty || selection.subItems.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select both main item and sub item')),
                                );
                                return;
                              }
                            }
                            // Updating the task table from the input
                            int? taskId = widget.task.id;
                            if (widget.task.id == null) {
                              taskId = await NewDatabase().insertTask(Task(
                                title: _title,
                                description: _description,
                              ));
                            } else {
                              await NewDatabase().updateTask(Task(
                                id: taskId,
                                title: _title,
                                description: _description,
                              ));
                            }
                            // Inserting and updating the subtask in the subtask table
                            for (var subtask in dropdownSelections) {
                              if (subtask.id == 0) {
                                await NewDatabase().insertSubTaskForTask(
                                  taskId!,
                                  subtask.mainItems,
                                  subtask.subItems,
                                );
                              } else {
                                await NewDatabase().updateSubTask(
                                  subtask.id,
                                  subtask.mainItems,
                                  subtask.subItems,
                                );
                              }
                            }
                            // this is the state  where the changes have been made are directly added to the bloc to pass the state
                            context.read<TaskBloc>().add(TaskUpdated(taskId!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Task and Subtasks saved successfully!')),
                            );
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is TaskLoadFailure) {
            return Center(
              child: Text('Failed to load task details: ${state.message}'),
            );
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}
