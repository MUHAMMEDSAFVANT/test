import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/tasks/domain/models/task_model.dart';

class LocalTaskStorage {
  static const _prefix = 'tasks_';

  static String _key(String uid) => '$_prefix$uid';

  static Future<List<TaskModel>> load(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(uid));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(String uid, List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_key(uid), encoded);
  }

  static Future<void> clear(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(uid));
  }
}
