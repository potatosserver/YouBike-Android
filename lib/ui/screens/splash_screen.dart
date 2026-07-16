import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _firstLaunchKey = 'is_first_launch';
  static const _skipKey = 'skip_location_permission';

  @override
  void initState() {
    super.initState();
    _decideRoute();
  }

  Future<void> _decideRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool(_firstLaunchKey) ?? true;

    if (isFirst) {
      await prefs.setBool(_firstLaunchKey, false);
      if (mounted) context.go('/welcome');
      return;
    }

    // 非首次：檢查權限是否已處理（授權 或 略過）
    final skip = prefs.getBool(_skipKey) ?? false;
    final status = await Permission.location.status;
    final granted = status.isGranted || status.isLimited;

    if (mounted) {
      if (granted || skip) {
        context.go('/');
      } else {
        context.go('/permission');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}