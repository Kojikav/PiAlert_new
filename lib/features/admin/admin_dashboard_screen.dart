import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_routes.dart';
import '../../core/widgets/pialert_app_bar.dart';
import '../../providers/auth_provider.dart';
import 'sections/siaga_section.dart';
import 'sections/announcement_section.dart';
import 'sections/reports_section.dart';
import 'sections/safety_section.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  static const _titles = [
    AppStrings.kelolaLevel,
    AppStrings.buatPengumuman,
    AppStrings.kelolaLaporan,
    AppStrings.monitoringAman,
  ];

  static const _icons = [
    Icons.monitor_heart_outlined,
    Icons.campaign_outlined,
    Icons.assignment_outlined,
    Icons.shield_outlined,
  ];

  static const _selectedIcons = [
    Icons.monitor_heart,
    Icons.campaign,
    Icons.assignment,
    Icons.shield,
  ];

  final List<Widget> _sections = const [
    SiagaSection(),
    AnnouncementSection(),
    ReportsSection(),
    SafetySection(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      });
      return const Scaffold(body: Center(child: Text('Akses ditolak')));
    }

    return Scaffold(
      appBar: PiAlertAppBar(
        icon: Icons.dashboard,
        title: _titles[_currentIndex],
        actions: [
          PiAlertProfileAction(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: _sections,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        height: 68,
        elevation: 8,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        destinations: List.generate(4, (i) => NavigationDestination(
          icon: Icon(_icons[i]),
          selectedIcon: Icon(_selectedIcons[i]),
          label: _titles[i].split(' ').last,
        )),
      ),
    );
  }
}
