import 'dart:convert';

class Task {
  String title;
  String description;
  bool isCompleted;
  int? id;
  // String itemType;  // New field for main item type
  // String subType;   // New field for sub item type
   List<Map<String,dynamic>>  dropdownSelections;

  Task({
   this.dropdownSelections = const [],
    required this.title,
    this.id,
    this.description = '',
    this.isCompleted = false,
    // this.itemType = '',  // Default value
    // this.subType = '',   // Default value
  });

  // Allow copying of Task objects with modifications
  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    int? id,
    String? itemType,  // Added to copyWith method
    String? subType,
    List<Map<String, dynamic>>? dropdownSelections,  // Added to copyWith method
  }) {
    return Task(
      dropdownSelections: dropdownSelections ?? this.dropdownSelections,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      id: id ?? this.id,
      // itemType: itemType ?? this.itemType,  // Handle itemType
      // subType: subType ?? this.subType,     // Handle subType

    );
  }

  // Convert Task object to Map for the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      // 'itemType': itemType,  // Include itemType in the map
      // 'subType': subType,
      'dropdownSelections': jsonEncode(dropdownSelections), // Convert to JSON string
      // Include subType in the map
    };
  }

  // Create Task object from a Map fetched from the database
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] == 1,
      // itemType: map['itemType'] ?? '',
      // subType: map['subType'] ?? '',
      // dropdownSelections: jsonDecode(map['dropdownSelections']), // Deserialize JSON to list,
      dropdownSelections: map['dropdownSelections'] != null
          ? List<Map<String, dynamic>>.from(
        jsonDecode(map['dropdownSelections']),
      )
          : [], // Default to an empty list if null
    );
  }

}
