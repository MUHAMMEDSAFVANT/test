import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../../services/local_task_storage.dart';
import '../../../../services/notification_service.dart';

enum TaskStatus { initial, loading, loaded, error }

class TaskProvider extends ChangeNotifier {
  TaskProvider({required TaskRepository repository})
      : _repository = repository;

  final TaskRepository _repository;

  List<TaskModel> _tasks = [];
  TaskStatus _status = TaskStatus.initial;
  String? _errorMessage;
  StreamSubscription<List<TaskModel>>? _subscription;
  String? _activeUid;

  List<TaskModel> get tasks => _tasks;
  TaskStatus get status => _status;
  String? get errorMessage => _errorMessage;

  // ── Start: load cache first, then stream from Firestore ───────────────────

  Future<void> startListening(String uid) async {
    if (_activeUid == uid && _subscription != null) return;
    await _subscription?.cancel();
    _activeUid = uid;

    // 1. Show cached tasks immediately so the list is visible on restart
    final cached = await LocalTaskStorage.load(uid);
    if (cached.isNotEmpty) {
      _tasks = cached;
      _status = TaskStatus.loaded;
      notifyListeners();
    } else {
      _status = TaskStatus.loading;
      notifyListeners();
    }

    // 2. Stream live updates from Firestore and keep cache in sync
    _subscription = _repository.streamTasks(uid).listen(
      (tasks) {
        _tasks = tasks;
        _status = TaskStatus.loaded;
        LocalTaskStorage.save(uid, tasks); // persist fresh data
        notifyListeners();
      },
      onError: (Object e) {
        _errorMessage = e.toString();
        // Keep showing cached tasks even when offline
        if (_tasks.isEmpty) _status = TaskStatus.error;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _activeUid = null;
    _tasks = [];
    _status = TaskStatus.initial;
    notifyListeners();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

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
    // Firestore stream will update _tasks; fire notification independently
    await NotificationService.instance.showTaskAdded(title.trim());
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
    // Capture the title before deletion for the notification
    final title = _tasks.firstWhere(
      (t) => t.id == id,
      orElse: () => TaskModel(
        id: id,
        uid: '',
        title: 'Task',
        description: '',
        createdAt: DateTime.now(),
      ),
    ).title;

    await _repository.deleteTask(id);
    await NotificationService.instance.showTaskDeleted(title);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
