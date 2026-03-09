import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6)));
    _controller.forward();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      context.read<TaskProvider>().loadTasks(),
      context.read<SettingsProvider>().loadSettings(),
    ]);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      Navigator.pushReplacement(context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ));
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF42A5F5)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset('assets/images/icon.png', fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('TaskFlow',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text('نظّم يومك، حقق أهدافك',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('by Alaa علاء',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 60),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.7)),
                strokeWidth: 2,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
