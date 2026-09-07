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

  // ── Local storage (JSON) ───────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'uid': uid,
        'title': title,
        'description': description,
        'isDone': isDone,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isDone: json['isDone'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
    );
  }
}
