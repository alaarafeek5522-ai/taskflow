import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class AppHelpers {
  static String priorityName(Priority p) {
    switch (p) {
      case Priority.high: return 'عالية';
      case Priority.medium: return 'متوسطة';
      case Priority.low: return 'منخفضة';
    }
  }

  static Color priorityColor(Priority p) {
    switch (p) {
      case Priority.high: return AppColors.highPriority;
      case Priority.medium: return AppColors.mediumPriority;
      case Priority.low: return AppColors.lowPriority;
    }
  }

  static String categoryName(TaskCategory c) {
    switch (c) {
      case TaskCategory.work: return 'العمل';
      case TaskCategory.study: return 'الدراسة';
      case TaskCategory.sport: return 'الرياضة';
      case TaskCategory.personal: return 'الحياة الشخصية';
      case TaskCategory.projects: return 'المشاريع';
      case TaskCategory.other: return 'أخرى';
    }
  }

  static IconData categoryIcon(TaskCategory c) {
    switch (c) {
      case TaskCategory.work: return Icons.work_rounded;
      case TaskCategory.study: return Icons.school_rounded;
      case TaskCategory.sport: return Icons.fitness_center_rounded;
      case TaskCategory.personal: return Icons.home_rounded;
      case TaskCategory.projects: return Icons.folder_rounded;
      case TaskCategory.other: return Icons.category_rounded;
    }
  }

  static Color categoryColor(TaskCategory c) => AppColors.categoryColors[c.index];

  static String formatDate(DateTime d) {
    final months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو',
        'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String formatTime(int hour, int minute) {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    return '$h:$m $period';
  }

  static String getDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير ☀️';
    if (hour < 17) return 'مساء النور 🌤️';
    return 'مساء الخير 🌙';
  }

  static String getDayName(DateTime d) {
    const days = ['الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت','الأحد'];
    return days[d.weekday - 1];
  }
}
