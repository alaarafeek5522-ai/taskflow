import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.background,
      appBar: AppBar(title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('assets/images/icon.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TaskFlow', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('تطوير: Alaa علاء', style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 2),
                Text('الإصدار 1.0.0', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ])),
              const Icon(Icons.verified_rounded, color: Colors.white70),
            ]),
          ),

          const SizedBox(height: 20),

          _section(isDark, 'المظهر', [
            _tile(icon: Icons.dark_mode_rounded, iconColor: const Color(0xFF7C4DFF),
              title: 'الوضع الليلي', subtitle: 'تبديل بين الليلي والنهاري',
              trailing: Switch.adaptive(
                value: isDark,
                onChanged: (_) => context.read<SettingsProvider>().toggleDarkMode(),
                activeColor: AppColors.primary,
              ), isDark: isDark),
          ]),

          const SizedBox(height: 12),

          _section(isDark, 'الأمان', [
            _tile(icon: Icons.lock_rounded, iconColor: AppColors.error,
              title: 'قفل التطبيق',
              subtitle: settings.isPinEnabled ? 'PIN مفعّل ✓' : 'غير مفعّل',
              onTap: () => _pinDialog(context, settings), isDark: isDark),
            _tile(icon: Icons.fingerprint_rounded, iconColor: AppColors.success,
              title: 'بصمة الإصبع', subtitle: 'تسجيل الدخول بالبصمة',
              trailing: Switch.adaptive(value: false, onChanged: (_) {},
                  activeColor: AppColors.primary), isDark: isDark),
          ]),

          const SizedBox(height: 12),

          _section(isDark, 'التطبيق', [
            _tile(icon: Icons.notifications_rounded, iconColor: AppColors.warning,
              title: 'الإشعارات', subtitle: 'إدارة التنبيهات والتذكيرات',
              onTap: () {}, isDark: isDark),
            _tile(icon: Icons.language_rounded, iconColor: AppColors.secondary,
              title: 'اللغة', subtitle: 'العربية', onTap: () {}, isDark: isDark),
            _tile(icon: Icons.backup_rounded, iconColor: AppColors.primary,
              title: 'النسخ الاحتياطي', subtitle: 'حفظ واستعادة البيانات',
              onTap: () {}, isDark: isDark),
          ]),

          const SizedBox(height: 12),

          _section(isDark, 'حول التطبيق', [
            _tile(icon: Icons.info_rounded, iconColor: AppColors.textSecondary,
              title: 'معلومات التطبيق', subtitle: 'TaskFlow v1.0.0 by Alaa',
              onTap: () => _aboutDialog(context), isDark: isDark),
            _tile(icon: Icons.privacy_tip_rounded, iconColor: AppColors.primaryDark,
              title: 'سياسة الخصوصية', subtitle: 'بياناتك محمية ومشفرة',
              onTap: () {}, isDark: isDark),
          ]),
        ]),
      ),
    );
  }

  Widget _section(bool isDark, String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(right: 4, bottom: 8),
        child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      ),
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Column(children: children),
      ),
    ],
  );

  Widget _tile({required IconData icon, required Color iconColor, required String title,
      required String subtitle, Widget? trailing, VoidCallback? onTap, required bool isDark}) =>
      ListTile(
        onTap: onTap,
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: trailing ?? (onTap != null
            ? const Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary)
            : null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  void _pinDialog(BuildContext context, SettingsProvider settings) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('تعيين PIN'),
      content: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        maxLength: 6,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'أدخل الـ PIN (4-6 أرقام)',
          prefixIcon: Icon(Icons.lock_rounded),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            if (ctrl.text.length >= 4) {
              settings.setPin(ctrl.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('تم تفعيل الـ PIN'), backgroundColor: AppColors.success));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('حفظ', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _aboutDialog(BuildContext context) => showAboutDialog(
    context: context,
    applicationName: 'TaskFlow',
    applicationVersion: '1.0.0',
    applicationIcon: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset('assets/images/icon.png', width: 60),
    ),
    children: const [
      Text('تطبيق متكامل لإدارة المهام اليومية وزيادة الإنتاجية.'),
      SizedBox(height: 8),
      Text('تطوير: Alaa علاء', style: TextStyle(fontWeight: FontWeight.bold)),
      Text('جميع الحقوق محفوظة © 2025'),
    ],
  );
}
