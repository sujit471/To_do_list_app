import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/task.dart';

class OverallTaskScreen extends StatelessWidget {
  final Task task;

  const OverallTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${task.title}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Description: ${task.description}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            const Text(
              'Selected Items:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...task.dropdownSelections.map((selection) => Text(
              '- $selection',
              style: TextStyle(fontSize: 16),
            )),
          ],
        ),
      ),
    );
  }
}
