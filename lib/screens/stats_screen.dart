import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = provider.tasks.length;
    final completed = provider.completedTasks.length;
    final pending = provider.pendingTasks.length;
    final rate = provider.completionRate;

    final last7 = List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      final done = provider.getTasksByDate(day)
          .where((t) => t.status == TaskStatus.completed).length;
      return FlSpot(i.toDouble(), done.toDouble());
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.background,
      appBar: AppBar(title: const Text('الإحصائيات', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Column(children: [
              const Text('نسبة الإنجاز الكلية',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 16),
              CircularPercentIndicator(
                radius: 80,
                lineWidth: 12,
                percent: rate,
                center: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${(rate * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text('إنجاز', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
                progressColor: Colors.white,
                backgroundColor: Colors.white24,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _stat(total.toString(), 'الكل', Colors.white),
                _stat(completed.toString(), 'مكتملة', AppColors.success),
                _stat(pending.toString(), 'قيد التنفيذ', AppColors.warning),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          _card(isDark, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('الإنجاز خلال 7 أيام',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: LineChart(LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
                  getDrawingVerticalLine: (_) => const FlLine(color: Colors.transparent),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final day = DateTime.now().subtract(Duration(days: 6 - v.toInt()));
                      const days = ['إث','ثل','أر','خم','جم','سب','أح'];
                      return Text(days[day.weekday - 1],
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary));
                    },
                  )),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [LineChartBarData(
                  spots: last7,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  belowBarData: BarAreaData(show: true,
                      color: AppColors.primary.withOpacity(0.1)),
                  dotData: FlDotData(getDotPainter: (_, __, ___, ____) =>
                      FlDotCirclePainter(radius: 4, color: AppColors.primary,
                          strokeWidth: 2, strokeColor: Colors.white)),
                )],
              )),
            ),
          ])),

          const SizedBox(height: 16),

          _card(isDark, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('المهام حسب الفئة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 16),
            ...TaskCategory.values.map((cat) {
              final catTasks = provider.getTasksByCategory(cat);
              if (catTasks.isEmpty) return const SizedBox.shrink();
              final done = catTasks.where((t) => t.status == TaskStatus.completed).length;
              final catRate = done / catTasks.length;
              final color = AppHelpers.categoryColor(cat);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(AppHelpers.categoryIcon(cat), size: 14, color: color),
                    const SizedBox(width: 6),
                    Text(AppHelpers.categoryName(cat),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                    const Spacer(),
                    Text('$done/${catTasks.length}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: catRate,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 6,
                  ),
                ]),
              );
            }),
          ])),
        ]),
      ),
    );
  }

  Widget _stat(String v, String l, Color c) => Column(children: [
    Text(v, style: TextStyle(color: c, fontSize: 22, fontWeight: FontWeight.bold)),
    Text(l, style: const TextStyle(color: Colors.white60, fontSize: 11)),
  ]);

  Widget _card(bool isDark, Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
    ),
    child: child,
  );
}
