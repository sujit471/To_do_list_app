import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../widgets/dropdown_item.dart'; // Import your dropdown items
import 'task.dart';
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
  List<Map<String, dynamic>> dropdownSelections = [
    {"mainItem": null, "subItem": null}
  ]; // To store the state of dynamically added dropdowns

    @override
  void initState() {
    super.initState();

    _title = widget.task.title;
    _description = widget.task.description;
    dropdownSelections = widget.task.dropdownSelections.isNotEmpty
        ? widget.task.dropdownSelections
        : [{"mainItem": null, "subItem": null}];
    // Initialize dropdown selections if task has itemType and subType
    if (widget.task.itemType != null && widget.task.subType != null) {
      dropdownSelections[0]["mainItem"] = widget.task.itemType;
      dropdownSelections[0]["subItem"] = widget.task.subType;
    }
  }
  // void _deleteTask(int index) {
  //   context.read<TaskBloc>().add(DeleteTask(index));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
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
                  height: 200,
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
              // Dynamic Dropdowns
              Expanded(
                child: ListView.builder(
                  itemCount: dropdownSelections.length,
                  itemBuilder: (context, index) {
                    final mainItem = dropdownSelections[index]["mainItem"];
                    final subItem = dropdownSelections[index]["subItem"];
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
                                      dropdownSelections[index]["mainItem"] = newValue;
                                      dropdownSelections[index]["subItem"] = null;
                                    });
                                  },
                                  hint: const Text('Select Main Item'),
                                  value: TypeItems.contains(mainItem) ? mainItem : null,
                                ),
                                const SizedBox(height: 20),
                                if (mainItem != null)
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    hint: const Text('Select Sub Item'),
                                    value: subItem,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropdownSelections[index]["subItem"] = newValue;
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
                            onPressed: () {
                              setState(() {
                                dropdownSelections.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    dropdownSelections.add({"mainItem": null, "subItem": null});
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Dropdown'),
              ),

              const SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Check if any dropdown selection is incomplete
                    for (var selection in dropdownSelections) {
                      if (selection["mainItem"] == null || selection["subItem"] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select both main item and sub item')),
                        );
                        return;
                      }
                    }

                    // Save the task and pass it back
                    Navigator.pop(
                      context,
                      Task(
                        title: _title,
                        description: _description,
                        isCompleted: widget.task.isCompleted,
                        dropdownSelections: dropdownSelections, // Save all dropdown selections

                      ),
                    );
                  }
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
