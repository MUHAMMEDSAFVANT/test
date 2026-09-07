import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';

class FirestoreTaskRepository implements TaskRepository {
  FirestoreTaskRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _db.collection('tasks');

  @override
  Stream<List<TaskModel>> streamTasks(String uid) {
    return _tasks
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map(
          (snap) {
            final list = snap.docs
                .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
                .toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          },
        );
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await _tasks.add(task.toMap());
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _tasks.doc(task.id).update(task.toMap());
  }

  @override
  Future<void> deleteTask(String id) async {
    await _tasks.doc(id).delete();
  }
}
