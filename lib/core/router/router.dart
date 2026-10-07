import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:my_meds/core/widgets/bottom_nav_shell.dart';
import 'package:my_meds/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_meds/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:my_meds/features/auth/presentation/screens/login_screen.dart';
import 'package:my_meds/features/auth/presentation/screens/register_screen.dart';
import 'package:my_meds/features/auth/presentation/screens/splash_screen.dart';
import 'package:my_meds/features/cabinet/presentation/screens/cabinet_screen.dart';
import 'package:my_meds/features/dashboard/presentation/dashboard_screen.dart';
import 'package:my_meds/features/label_reader/presentation/screens/label_camera_screen.dart';
import 'package:my_meds/features/more/presentation/more_screen.dart';
import 'package:my_meds/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:my_meds/features/search/presentation/search_screen.dart';
import 'package:my_meds/features/settings/presentation/screens/settings_screen.dart';

/// Navigation route constants.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String cabinet = '/cabinet';
  static const String search = '/search';
  static const String reminders = '/reminders';
  static const String dashboard = '/dashboard';
  static const String more = '/more';
  static const String settings = '/settings';
  static const String scan = '/scan';
}

/// Navigator keys.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _cabinetNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cabinet');
final _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _remindersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'reminders');
final _dashboardNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _moreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'more');

/// Listenable adapter that triggers GoRouter redirect when a Riverpod stream changes.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Provider for the application [GoRouter] with authentication redirect guards.
final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: _GoRouterRefreshStream(authRepository.authStateChanges()),
    redirect: (context, state) {
      final user = authRepository.currentUser;
      final location = state.uri.path;

      final isAuthRoute = location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.forgotPassword ||
          location == AppRoutes.splash;

      // Unauthenticated users trying to access protected screens -> redirect to login
      if (user == null) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      // Authenticated users on splash or auth screens -> redirect to main cabinet
      if (isAuthRoute) {
        return AppRoutes.cabinet;
      }

      return null;
    },
    routes: [
      // ── Auth Routes ──
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.scan,
        builder: (context, state) => const LabelCameraScreen(),
      ),

      // ── Main Shell (Bottom Navigation) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _cabinetNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.cabinet,
                builder: (context, state) => const CabinetScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _remindersNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.reminders,
                builder: (context, state) => const RemindersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _moreNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
