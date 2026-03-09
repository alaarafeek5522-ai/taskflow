import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../utils/database_helper.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final _uuid = const Uuid();

  List<Task> get tasks => _tasks;

  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((t) =>
      t.dueDate != null &&
      t.dueDate!.year == now.year &&
      t.dueDate!.month == now.month &&
      t.dueDate!.day == now.day
    ).toList();
  }

  List<Task> get completedTasks =>
      _tasks.where((t) => t.status == TaskStatus.completed).toList();
  List<Task> get pendingTasks =>
      _tasks.where((t) => t.status == TaskStatus.pending).toList();

  double get completionRate {
    if (_tasks.isEmpty) return 0;
    return completedTasks.length / _tasks.length;
  }

  List<Task> getTasksByCategory(TaskCategory cat) =>
      _tasks.where((t) => t.category == cat).toList();

  List<Task> getTasksByDate(DateTime date) => _tasks.where((t) =>
      t.dueDate != null &&
      t.dueDate!.year == date.year &&
      t.dueDate!.month == date.month &&
      t.dueDate!.day == date.day).toList();

  List<Task> searchTasks(String query) => _tasks.where((t) =>
      t.title.toLowerCase().contains(query.toLowerCase()) ||
      (t.description?.toLowerCase().contains(query.toLowerCase()) ?? false)).toList();

  Future<void> loadTasks() async {
    _tasks = await DatabaseHelper.instance.getAllTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await DatabaseHelper.instance.insertTask(task);
    _tasks.insert(0, task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await DatabaseHelper.instance.updateTask(task);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final task = _tasks[idx];
    final updated = task.copyWith(
        status: task.status == TaskStatus.completed
            ? TaskStatus.pending
            : TaskStatus.completed);
    await updateTask(updated);
  }

  String generateId() => _uuid.v4();
}
