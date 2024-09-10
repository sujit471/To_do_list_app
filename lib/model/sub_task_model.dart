class SubTaskModel{
  int id;
  int task_id;
  String mainItems;
  String subItems;

   SubTaskModel({
    required this.id,
    required this.task_id,
   required this.subItems,
     required this.mainItems,
});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': task_id,
      'mainItems': mainItems,
      'subItems' : subItems,

    };
  }
  factory SubTaskModel.fromMap(Map<String, dynamic> map) {
    return SubTaskModel(
      id : map['id'],
      task_id: map['task_id'],
      subItems: map['subItems'],
      mainItems:map['mainItems'],
    );
  }

}