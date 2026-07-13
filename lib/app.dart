import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/siaga_provider.dart';
import 'providers/reports_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/safety_provider.dart';
import 'providers/bmkg_provider.dart';
import 'services/notification_service.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/main/main_screen.dart';
import 'features/reports/create_report_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/bmkg/bmkg_screen.dart';

class PiAlertApp extends StatelessWidget {
  const PiAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SiagaProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => SafetyProvider()),
        ChangeNotifierProvider(create: (_) => BmkgProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.main: (_) => const MainScreen(),
          AppRoutes.createReport: (_) => const CreateReportScreen(),
          AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
          AppRoutes.bmkg: (_) => const BmkgScreen(),
        },
      ),
    );
  }
}
