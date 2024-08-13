import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'task.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  TaskDetailScreen({required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  @override
  void initState() {
    super.initState();
    _title = widget.task.title;
    _description = widget.task.description;

    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                decoration:  BoxDecoration(
              color: Color.fromRGBO(155, 134, 250, 1.0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                    prefixIcon: Icon(Icons.book,color: Colors.white,),
                      labelText: 'Title',labelStyle: TextStyle(color: Colors.white)),
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
              const SizedBox(height:30 ,),
              Container(
                decoration:  BoxDecoration(
                  color: Color.fromRGBO(155, 134, 250, 1.0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.book,color: Colors.white,),

                  ),
                  onSaved: (value) {
                    _description = value!;
                  },
                ),
              ),
              Spacer(),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(
                      context,
                      Task(
                        title: _title,
                        description: _description,
                        isCompleted: widget.task.isCompleted,
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
