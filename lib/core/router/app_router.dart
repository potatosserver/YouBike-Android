import 'package:go_router/go_router.dart';
import 'package:youbike_android/ui/widgets/app_wrapper.dart';
import 'package:youbike_android/ui/screens/home_screen.dart';
import 'package:youbike_android/ui/screens/settings_screen.dart';
import 'package:youbike_android/ui/screens/theme_selection_screen.dart';
import 'package:youbike_android/ui/screens/region_selection_screen.dart';
import 'package:youbike_android/ui/screens/language_selection_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AppWrapper(),
      ),

      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/theme-selection',
        builder: (context, state) => const ThemeSelectionScreen(),
      ),
      GoRoute(
        path: '/region-selection',
        builder: (context, state) => const RegionSelectionScreen(),
      ),
      GoRoute(
        path: '/language-selection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
    ],
    // 錯誤處理：如果跳轉到不存在的路徑，則返回首頁
    errorBuilder: (context, state) => const HomeScreen(),
  );
}
