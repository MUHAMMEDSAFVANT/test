import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String uid;
  final String title;
  final String description;
  final bool isDone;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    this.isDone = false,
    required this.createdAt,
  });

  TaskModel copyWith({
    String? id,
    String? uid,
    String? title,
    String? description,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'title': title,
        'description': description,
        'isDone': isDone,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id: docId,
      uid: map['uid'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      isDone: map['isDone'] as bool? ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
