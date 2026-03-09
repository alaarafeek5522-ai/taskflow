import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  const TaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = AppHelpers.categoryColor(task.category);
    final isDone = task.status == TaskStatus.completed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => context.read<TaskProvider>().deleteTask(task.id),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'حذف',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => context.read<TaskProvider>().toggleTask(task.id),
              backgroundColor: isDone ? AppColors.warning : AppColors.success,
              foregroundColor: Colors.white,
              icon: isDone ? Icons.refresh_rounded : Icons.check_rounded,
              label: isDone ? 'إلغاء' : 'إنجاز',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDone ? AppColors.success.withOpacity(0.3) : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.read<TaskProvider>().toggleTask(task.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? AppColors.success : Colors.transparent,
                        border: Border.all(
                          color: isDone ? AppColors.success : AppColors.textSecondary,
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDone ? AppColors.textSecondary
                                : (isDark ? Colors.white : AppColors.textPrimary),
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (task.description != null && task.description!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(task.description!,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                        const SizedBox(height: 8),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: catColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(AppHelpers.categoryIcon(task.category), size: 11, color: catColor),
                              const SizedBox(width: 4),
                              Text(AppHelpers.categoryName(task.category),
                                  style: TextStyle(fontSize: 11, color: catColor, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppHelpers.priorityColor(task.priority),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(AppHelpers.priorityName(task.priority),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppHelpers.priorityColor(task.priority),
                                  fontWeight: FontWeight.w500)),
                          const Spacer(),
                          if (task.dueHour != null)
                            Text(AppHelpers.formatTime(task.dueHour!, task.dueMinute ?? 0),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ]),
                        if (task.subTasks.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: task.subTasks.where((s) => s.isDone).length / task.subTasks.length,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                            borderRadius: BorderRadius.circular(10),
                            minHeight: 3,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
