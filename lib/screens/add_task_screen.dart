import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  const AddTaskScreen({super.key, this.task});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _subCtrl = TextEditingController();
  Priority _priority = Priority.medium;
  TaskCategory _category = TaskCategory.personal;
  DateTime? _dueDate;
  int? _dueHour;
  int? _dueMinute;
  List<SubTask> _subTasks = [];
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      final t = widget.task!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description ?? '';
      _notesCtrl.text = t.notes ?? '';
      _priority = t.priority;
      _category = t.category;
      _dueDate = t.dueDate;
      _dueHour = t.dueHour;
      _dueMinute = t.dueMinute;
      _subTasks = List.from(t.subTasks);
      _isRecurring = t.isRecurring;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _notesCtrl.dispose(); _subCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('أدخل عنوان المهمة'), backgroundColor: AppColors.error));
      return;
    }
    final provider = context.read<TaskProvider>();
    if (widget.task == null) {
      provider.addTask(Task(
        id: const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        dueDate: _dueDate,
        dueHour: _dueHour,
        dueMinute: _dueMinute,
        priority: _priority,
        category: _category,
        subTasks: _subTasks,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        isRecurring: _isRecurring,
      ));
    } else {
      provider.updateTask(widget.task!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        dueDate: _dueDate,
        dueHour: _dueHour,
        dueMinute: _dueMinute,
        priority: _priority,
        category: _category,
        subTasks: _subTasks,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        isRecurring: _isRecurring,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.background,
      appBar: AppBar(
        title: Text(widget.task == null ? 'مهمة جديدة' : 'تعديل المهمة',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: const Text('حفظ'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _input(_titleCtrl, 'عنوان المهمة *', Icons.title_rounded),
          const SizedBox(height: 12),
          _input(_descCtrl, 'الوصف (اختياري)', Icons.description_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _label('الأولوية'),
          _priorityRow(),
          const SizedBox(height: 16),
          _label('الفئة'),
          _categoryWrap(),
          const SizedBox(height: 16),
          _label('التاريخ والوقت'),
          Row(children: [
            Expanded(child: _dateBtn(isDark)),
            const SizedBox(width: 12),
            Expanded(child: _timeBtn(isDark)),
          ]),
          const SizedBox(height: 16),
          _label('المهام الفرعية'),
          _subTasksSection(isDark),
          const SizedBox(height: 16),
          _label('ملاحظات'),
          _input(_notesCtrl, 'أضف ملاحظات...', Icons.note_rounded, maxLines: 3),
          const SizedBox(height: 16),
          _recurringToggle(isDark),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(widget.task == null ? 'حفظ المهمة' : 'تحديث المهمة',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)));

  Widget _input(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _priorityRow() => Row(
    children: Priority.values.map((p) {
      final sel = _priority == p;
      final color = AppHelpers.priorityColor(p);
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => setState(() => _priority = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(AppHelpers.priorityName(p),
                  style: TextStyle(color: sel ? Colors.white : color,
                      fontWeight: FontWeight.bold, fontSize: 13))),
            ),
          ),
        ),
      );
    }).toList(),
  );

  Widget _categoryWrap() => Wrap(
    spacing: 8, runSpacing: 8,
    children: TaskCategory.values.map((c) {
      final sel = _category == c;
      final color = AppHelpers.categoryColor(c);
      return GestureDetector(
        onTap: () => setState(() => _category = c),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(AppHelpers.categoryIcon(c), size: 14, color: sel ? Colors.white : color),
            const SizedBox(width: 6),
            Text(AppHelpers.categoryName(c),
                style: TextStyle(color: sel ? Colors.white : color,
                    fontWeight: FontWeight.w600, fontSize: 12)),
          ]),
        ),
      );
    }).toList(),
  );

  Widget _dateBtn(bool isDark) => GestureDetector(
    onTap: () async {
      final d = await showDatePicker(context: context,
          initialDate: _dueDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)));
      if (d != null) setState(() => _dueDate = d);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(children: [
        const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(_dueDate != null ? AppHelpers.formatDate(_dueDate!) : 'التاريخ',
            style: TextStyle(fontSize: 13,
                color: _dueDate != null ? AppColors.textPrimary : AppColors.textSecondary)),
      ]),
    ),
  );

  Widget _timeBtn(bool isDark) => GestureDetector(
    onTap: () async {
      final t = await showTimePicker(context: context,
          initialTime: TimeOfDay(hour: _dueHour ?? 9, minute: _dueMinute ?? 0));
      if (t != null) setState(() { _dueHour = t.hour; _dueMinute = t.minute; });
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(children: [
        const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(_dueHour != null ? AppHelpers.formatTime(_dueHour!, _dueMinute ?? 0) : 'الوقت',
            style: TextStyle(fontSize: 13,
                color: _dueHour != null ? AppColors.textPrimary : AppColors.textSecondary)),
      ]),
    ),
  );

  Widget _subTasksSection(bool isDark) => Column(
    children: [
      ..._subTasks.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Checkbox(
            value: e.value.isDone,
            onChanged: (v) => setState(() => _subTasks[e.key].isDone = v ?? false),
            activeColor: AppColors.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(child: Text(e.value.title)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
            onPressed: () => setState(() => _subTasks.removeAt(e.key)),
          ),
        ]),
      )),
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _subCtrl,
              decoration: const InputDecoration(
                hintText: 'أضف مهمة فرعية...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.add_task_rounded, color: AppColors.primary, size: 20),
                contentPadding: EdgeInsets.all(14),
              ),
              onSubmitted: (_) => _addSub(),
            ),
          ),
          IconButton(icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary), onPressed: _addSub),
        ]),
      ),
    ],
  );

  void _addSub() {
    if (_subCtrl.text.trim().isNotEmpty) {
      setState(() {
        _subTasks.add(SubTask(id: const Uuid().v4(), title: _subCtrl.text.trim()));
        _subCtrl.clear();
      });
    }
  }

  Widget _recurringToggle(bool isDark) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
    ),
    child: Row(children: [
      const Icon(Icons.repeat_rounded, color: AppColors.primary),
      const SizedBox(width: 12),
      const Expanded(child: Text('مهمة متكررة', style: TextStyle(fontWeight: FontWeight.w600))),
      Switch.adaptive(
        value: _isRecurring,
        onChanged: (v) => setState(() => _isRecurring = v),
        activeColor: AppColors.primary,
      ),
    ]),
  );
}
