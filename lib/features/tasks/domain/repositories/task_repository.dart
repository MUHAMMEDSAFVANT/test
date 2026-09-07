import '../models/task_model.dart';

abstract class TaskRepository {
  Stream<List<TaskModel>> streamTasks(String uid);

  Future<void> addTask(TaskModel task);

  Future<void> updateTask(TaskModel task);

  Future<void> deleteTask(String id);
}
