class Task {
  String title;
  String description;
  bool isCompleted;

  Task({required this.title, this.description = '', this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'],
    );
  }
}
