import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTasks = provider.getTasksByDate(_selectedDay);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.background,
      appBar: AppBar(
        title: const Text('التقويم', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          ),
        ],
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _format,
            onFormatChanged: (f) => setState(() => _format = f),
            onDaySelected: (selected, focused) =>
                setState(() { _selectedDay = selected; _focusedDay = focused; }),
            eventLoader: (day) => provider.getTasksByDate(day),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
              weekendTextStyle: const TextStyle(color: AppColors.error),
            ),
            headerStyle: HeaderStyle(
              formatButtonDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              formatButtonTextStyle: const TextStyle(color: AppColors.primary),
              titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
              formatButtonShowsNext: false,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(children: [
            Text(AppHelpers.formatDate(_selectedDay),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Spacer(),
            Text('${selectedTasks.length} مهمة',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ]),
        ),
        Expanded(
          child: selectedTasks.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.event_available_rounded, size: 60,
                      color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  const Text('لا توجد مهام في هذا اليوم',
                      style: TextStyle(color: AppColors.textSecondary)),
                ]))
              : ListView.builder(
                  itemCount: selectedTasks.length,
                  itemBuilder: (ctx, i) => TaskCard(
                    task: selectedTasks[i],
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => AddTaskScreen(task: selectedTasks[i]))),
                  ),
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
