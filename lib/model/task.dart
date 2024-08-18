class Task {
  String title;
  String description;
  bool isCompleted;
  int? id; // id field for database identification

  Task({
    required this.title,
    this.id,
    this.description = '',
    this.isCompleted = false,
  });

  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    int? id, // Added id to copyWith method
  }) {
    return Task(
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      id: id ?? this.id, // Include id in the copied object
    );
  }

  // Convert Task object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include id in the map
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0, // Convert boolean to integer
    };
  }

  // Create Task object from Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'], // Map the id field
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1, // Convert integer back to boolean
    );
  }
}
