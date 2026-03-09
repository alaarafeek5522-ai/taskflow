import 'dart:convert';
import 'package:flutter/material.dart';

enum Priority { high, medium, low }
enum TaskCategory { work, study, sport, personal, projects, other }
enum TaskStatus { pending, completed, overdue }

class SubTask {
  String id;
  String title;
  bool isDone;
  SubTask({required this.id, required this.title, this.isDone = false});
  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'isDone': isDone ? 1 : 0};
  factory SubTask.fromMap(Map<String, dynamic> m) =>
      SubTask(id: m['id'], title: m['title'], isDone: m['isDone'] == 1);
}

class Task {
  String id;
  String title;
  String? description;
  DateTime? dueDate;
  int? dueHour;
  int? dueMinute;
  Priority priority;
  TaskCategory category;
  TaskStatus status;
  bool isRecurring;
  String? recurringPattern;
  List<SubTask> subTasks;
  String? notes;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.dueHour,
    this.dueMinute,
    this.priority = Priority.medium,
    this.category = TaskCategory.personal,
    this.status = TaskStatus.pending,
    this.isRecurring = false,
    this.recurringPattern,
    List<SubTask>? subTasks,
    this.notes,
    DateTime? createdAt,
  })  : subTasks = subTasks ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'dueHour': dueHour,
        'dueMinute': dueMinute,
        'priority': priority.index,
        'category': category.index,
        'status': status.index,
        'isRecurring': isRecurring ? 1 : 0,
        'recurringPattern': recurringPattern,
        'subTasks': jsonEncode(subTasks.map((s) => s.toMap()).toList()),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromMap(Map<String, dynamic> m) {
    List<SubTask> subs = [];
    if (m['subTasks'] != null) {
      final decoded = jsonDecode(m['subTasks']) as List;
      subs = decoded.map((e) => SubTask.fromMap(e as Map<String, dynamic>)).toList();
    }
    return Task(
      id: m['id'],
      title: m['title'],
      description: m['description'],
      dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate']) : null,
      dueHour: m['dueHour'],
      dueMinute: m['dueMinute'],
      priority: Priority.values[m['priority'] ?? 1],
      category: TaskCategory.values[m['category'] ?? 3],
      status: TaskStatus.values[m['status'] ?? 0],
      isRecurring: m['isRecurring'] == 1,
      recurringPattern: m['recurringPattern'],
      subTasks: subs,
      notes: m['notes'],
      createdAt: DateTime.parse(m['createdAt']),
    );
  }

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    int? dueHour,
    int? dueMinute,
    Priority? priority,
    TaskCategory? category,
    TaskStatus? status,
    bool? isRecurring,
    String? recurringPattern,
    List<SubTask>? subTasks,
    String? notes,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        dueHour: dueHour ?? this.dueHour,
        dueMinute: dueMinute ?? this.dueMinute,
        priority: priority ?? this.priority,
        category: category ?? this.category,
        status: status ?? this.status,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringPattern: recurringPattern ?? this.recurringPattern,
        subTasks: subTasks ?? List.from(this.subTasks),
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );
}
