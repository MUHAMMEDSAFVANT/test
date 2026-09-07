import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';

enum TaskStatus { initial, loading, loaded, error }

class TaskProvider extends ChangeNotifier {
  TaskProvider({required TaskRepository this._repository});

  final TaskRepository _repository;

  List<TaskModel> _tasks = [];
  TaskStatus _status = TaskStatus.initial;
  String? _errorMessage;
  StreamSubscription<List<TaskModel>>? _subscription;

  List<TaskModel> get tasks => _tasks;
  TaskStatus get status => _status;
  String? get errorMessage => _errorMessage;

  void startListening(String uid) {
    _subscription?.cancel();
    _status = TaskStatus.loading;
    notifyListeners();
    _subscription = _repository.streamTasks(uid).listen(
      (tasks) {
        _tasks = tasks;
        _status = TaskStatus.loaded;
        notifyListeners();
      },
      onError: (Object e) {
        _errorMessage = e.toString();
        _status = TaskStatus.error;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _tasks = [];
    _status = TaskStatus.initial;
    notifyListeners();
  }

  Future<void> addTask({
    required String uid,
    required String title,
    required String description,
  }) async {
    final task = TaskModel(
      id: '',
      uid: uid,
      title: title.trim(),
      description: description.trim(),
      createdAt: DateTime.now(),
    );
    await _repository.addTask(task);
  }

  Future<void> updateTask({
    required TaskModel task,
    required String title,
    required String description,
    bool? isDone,
  }) async {
    final updated = task.copyWith(
      title: title.trim(),
      description: description.trim(),
      isDone: isDone ?? task.isDone,
    );
    await _repository.updateTask(updated);
  }

  Future<void> toggleDone(TaskModel task) async {
    final updated = task.copyWith(isDone: !task.isDone);
    await _repository.updateTask(updated);
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
