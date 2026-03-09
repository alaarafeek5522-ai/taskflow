import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final todayTasks = provider.todayTasks;
    final pending = todayTasks.where((t) => t.status != TaskStatus.completed).toList();
    final completed = todayTasks.where((t) => t.status == TaskStatus.completed).toList();
    final allPending = provider.pendingTasks;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppHelpers.getDayGreeting(),
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('مرحباً، علاء 👋',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    )),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Text('ع',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text('${AppHelpers.getDayName(now)}، ${AppHelpers.formatDate(now)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 20),
                  Row(children: [
                    _statChip('${todayTasks.length}', 'مهام اليوم', Icons.today_rounded),
                    const SizedBox(width: 12),
                    _statChip('${completed.length}', 'مكتملة', Icons.check_circle_rounded),
                    const SizedBox(width: 12),
                    _statChip('${allPending.length}', 'قيد التنفيذ', Icons.pending_rounded),
                  ]),
                ],
              ),
            ),
          ),

          if (pending.isNotEmpty) ...[
            SliverToBoxAdapter(child: _sectionHeader('مهام اليوم 📋', '${pending.length} مهمة')),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50,
                    child: FadeInAnimation(
                      child: TaskCard(
                        task: pending[i],
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => AddTaskScreen(task: pending[i]))),
                      ),
                    ),
                  ),
                ),
                childCount: pending.length,
              ),
            ),
          ],

          if (completed.isNotEmpty) ...[
            SliverToBoxAdapter(child: _sectionHeader('مكتملة اليوم ✅', '${completed.length}')),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => TaskCard(task: completed[i]),
                childCount: completed.length,
              ),
            ),
          ],

          if (todayTasks.isEmpty && allPending.isNotEmpty) ...[
            SliverToBoxAdapter(child: _sectionHeader('المهام القادمة 📌', '${allPending.length} مهمة')),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50,
                    child: FadeInAnimation(
                      child: TaskCard(
                        task: allPending[i],
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => AddTaskScreen(task: allPending[i]))),
                      ),
                    ),
                  ),
                ),
                childCount: allPending.length > 5 ? 5 : allPending.length,
              ),
            ),
          ],

          if (provider.tasks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.task_alt_rounded, size: 80,
                      color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('لا توجد مهام بعد',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text('اضغط + لإضافة مهمتك الأولى',
                      style: TextStyle(color: AppColors.textSecondary)),
                ]),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('مهمة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _statChip(String value, String label, IconData icon) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ]),
        ),
      );

  Widget _sectionHeader(String title, String subtitle) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
    child: Row(children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const Spacer(),
      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]),
  );
}
