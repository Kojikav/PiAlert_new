import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/pialert_app_bar.dart';
import '../../models/announcement_model.dart';
import '../../models/report_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/siaga_provider.dart';
import '../../providers/safety_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/bmkg_provider.dart';
import '../../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _safetyInitialized = false;
  bool _geofencingChecked = false;
  double? _userDistance;

  @override
  void initState() {
    super.initState();
    _checkGeofencing();
  }

  Future<void> _checkGeofencing() async {
    try {
      final hasPerm = await LocationService().requestPermission();
      if (!hasPerm) return;
      final pos = await LocationService().getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _userDistance = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          -7.5407, // Merapi Summit Lat
          110.4457, // Merapi Summit Lng
        ) / 1000.0; // in km
        _geofencingChecked = true;
      });
    } catch (e) {
      debugPrint('Error in home geofencing: $e');
    }
  }

  Widget _buildDangerWarningBanner(double distance, double radius) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.gpp_bad, color: Colors.red.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚨 ANDA DI ZONA BAHAYA!',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jarak Anda ke kawah Merapi hanya ${distance.toStringAsFixed(2)} km. '
                  'Radius bahaya aktif saat ini: ${radius.toStringAsFixed(1)} km. '
                  'Segera ikuti rute evakuasi menuju titik kumpul terdekat.',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSosDialog(BuildContext context, String uid, String name, int siagaLevel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Kirim Sinyal SOS?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Aksi ini akan merekam koordinat GPS Anda ke database sebagai sinyal darurat prioritas tinggi, '
          'dan membuka aplikasi telepon untuk menghubungi BPBD Sleman. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _sendSos(context, uid, name, siagaLevel);
            },
            child: const Text('Kirim', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSos(BuildContext context, String uid, String name, int siagaLevel) async {
    try {
      final pos = await LocationService().getCurrentLocation();

      if (context.mounted) {
        final reportsProv = context.read<ReportsProvider>();
        final reportId = const Uuid().v4();
        
        final res = await reportsProv.submitReport(
          reportId: reportId,
          authorUid: uid,
          authorName: name,
          category: 'lainnya',
          description: '🚨 SOS DARURAT! Warga memerlukan penyelamatan segera di posisi koordinat ini.',
          latitude: pos.latitude,
          longitude: pos.longitude,
          locationLabel: 'Sinyal Darurat SOS',
          siagaLevel: siagaLevel,
        );

        if (res.success) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sinyal SOS berhasil dikirim ke database!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal mengirim ke database: ${res.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }

      final phoneUri = Uri.parse('tel:0274-868225');
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        debugPrint('Could not launch phone call');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengirim SOS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 2:
        return AppColors.levelWaspada;
      case 3:
        return AppColors.levelSiaga;
      case 4:
        return AppColors.levelBahaya;
      default:
        return AppColors.levelNormal;
    }
  }

  IconData _getLevelIcon(int level) {
    switch (level) {
      case 2:
        return Icons.warning_amber_rounded;
      case 3:
        return Icons.warning_rounded;
      case 4:
        return Icons.dangerous;
      default:
        return Icons.check_circle;
    }
  }

  bool _shouldShowSafetyButton(int? siagaLevel) {
    return siagaLevel != null && siagaLevel >= 2;
  }

  static const _categoryLabels = {
    'hujan_abu': 'Hujan Abu',
    'bau_belerang': 'Bau Belerang',
    'suara_gemuruh': 'Suara Gemuruh',
    'jalan_terblokir': 'Jalan Terblokir',
    'pengungsian_darurat': 'Pengungsian Darurat',
    'lainnya': 'Lainnya',
  };

  static const _categoryColors = {
    'hujan_abu': Color(0xFF9E9E9E),
    'bau_belerang': Color(0xFF795548),
    'suara_gemuruh': Color(0xFFFF5722),
    'jalan_terblokir': Color(0xFFF44336),
    'pengungsian_darurat': Color(0xFFE91E63),
    'lainnya': Color(0xFF607D8B),
  };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final siaga = context.watch<SiagaProvider>();
    final safety = context.watch<SafetyProvider>();
    final announcementsProv = context.watch<AnnouncementProvider>();
    final reportsProv = context.watch<ReportsProvider>();
    final status = siaga.status;

    if (!_safetyInitialized && auth.user != null) {
      _safetyInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SafetyProvider>().listenToMyConfirmation(auth.user!.uid);
      });
    }

    final recentAnnouncements = announcementsProv.announcements.take(5).toList();
    final recentReports = reportsProv.reports.take(5).toList();

    return Scaffold(
      appBar: PiAlertAppBar(
        icon: Icons.volcano,
        title: AppStrings.appName,
        actions: [
          PiAlertProfileAction(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9), // light green tint
              Color(0xFFF0F2F5), // neutral grey
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.hello},',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            auth.user?.name ?? 'Pengguna',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.volcano, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Warning banner if inside danger zone
              if (_geofencingChecked &&
                  _userDistance != null &&
                  status != null &&
                  status.dangerRadius > 0 &&
                  _userDistance! < status.dangerRadius)
                _buildDangerWarningBanner(_userDistance!, status.dangerRadius),
              // Status Siaga section
              if (status != null)
                _buildSection(
                  context,
                  title: 'Status Siaga',
                  icon: Icons.monitor_heart_outlined,
                  child: Column(
                    children: [
                      _buildSiagaCard(context, status),
                      if (_shouldShowSafetyButton(status.level)) ...[
                        const SizedBox(height: 12),
                        _buildSafetyButton(context, safety, auth, status.level),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Laporan Terkini section
              _buildSection(
                context,
                title: 'Laporan Terkini',
                icon: Icons.article_outlined,
                child: recentAnnouncements.isEmpty && recentReports.isEmpty
                    ? _buildEmptyFeed(context)
                    : Column(
                        children: [
                          ...recentAnnouncements.map((ann) => _buildAnnouncementCard(context, ann)),
                          ...recentReports.map((report) => _buildReportCard(context, report)),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              // BMKG section
              _buildSection(
                context,
                title: 'Info Gempa BMKG',
                icon: Icons.public,
                onTitleTap: () => Navigator.pushNamed(context, AppRoutes.bmkg),
                child: _buildBmkgContent(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: auth.user != null
          ? FloatingActionButton.extended(
              heroTag: 'sos_home',
              onPressed: () => _showSosDialog(
                context,
                auth.user!.uid,
                auth.user!.name,
                status?.level ?? 1,
              ),
              backgroundColor: Colors.red.shade700,
              icon: const Icon(Icons.emergency, color: Colors.white),
              label: const Text(
                'SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    VoidCallback? onTitleTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (onTitleTap != null)
                GestureDetector(
                  onTap: onTitleTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Lihat Semua',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildBmkgContent(BuildContext context) {
    final bmkg = context.watch<BmkgProvider>();

    if (bmkg.isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    } else if (bmkg.errorMessage != null) {
      return GestureDetector(
        onTap: () => bmkg.fetchAll(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.wifi_off, size: 20, color: Colors.grey.shade400),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gagal memuat data BMKG',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              Icon(Icons.refresh, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      );
    } else if (bmkg.gempaTerbaru != null) {
      return _buildGempaPreview(context, bmkg);
    }
    return const SizedBox.shrink();
  }

  Widget _buildGempaPreview(BuildContext context, BmkgProvider bmkg) {
    final gempa = bmkg.gempaTerbaru!;
    final mag = gempa.magnitudeValue;
    final color = mag >= 7.0
        ? const Color(0xFF880E4F)
        : mag >= 5.0
            ? AppColors.danger
            : mag >= 3.0
                ? AppColors.warning
                : AppColors.levelNormal;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.bmkg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'M${gempa.magnitude}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gempa.wilayah,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gempa.tanggal}, ${gempa.jam}  •  ${gempa.kedalaman}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFeed(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Belum ada pengumuman atau laporan',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, AnnouncementModel ann) {
    Color accentColor;
    IconData icon;
    switch (ann.type) {
      case 'warning':
        accentColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case 'danger':
        accentColor = AppColors.danger;
        icon = Icons.dangerous;
        break;
      default:
        accentColor = AppColors.info;
        icon = Icons.info_outline;
    }

    return GestureDetector(
      onTap: () => _showAnnouncementDetail(context, ann, accentColor, icon),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  color: accentColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Pengumuman',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: accentColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormatter.timeAgo(ann.createdAt),
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ann.title,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ann.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportModel report) {
    final categoryColor = _categoryColors[report.category] ?? AppColors.textSecondary;
    final categoryLabel = _categoryLabels[report.category] ?? report.category;

    return GestureDetector(
      onTap: () => _showReportDetail(context, report, categoryColor, categoryLabel),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.description_outlined, color: categoryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          categoryLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: categoryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormatter.timeAgo(report.createdAt),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(report.authorName, style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report.locationLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementDetail(
    BuildContext context,
    AnnouncementModel ann,
    Color accentColor,
    IconData icon,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Pengumuman',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                ann.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    ann.createdByName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatDateTime(ann.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Divider(height: 32),
              Text(
                ann.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetail(
    BuildContext context,
    ReportModel report,
    Color categoryColor,
    String categoryLabel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      categoryLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (report.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            'Terverifikasi',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(report.authorName, style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatDateTime(report.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      report.locationLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                report.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
              if (report.photoUrl != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    report.photoUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.broken_image, color: AppColors.textSecondary, size: 40),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyButton(
    BuildContext context,
    SafetyProvider safety,
    AuthProvider auth,
    int siagaLevel,
  ) {
    final alreadyConfirmed = safety.myConfirmation?.siagaLevel == siagaLevel;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: alreadyConfirmed || safety.isLoading
            ? null
            : () {
                safety.confirm(
                  uid: auth.user!.uid,
                  name: auth.user!.name,
                  siagaLevel: siagaLevel,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Status aman Anda telah tercatat'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
        icon: Icon(
          alreadyConfirmed ? Icons.check_circle : Icons.shield_outlined,
        ),
        label: Text(
          alreadyConfirmed ? AppStrings.sudahDikonfirmasi : AppStrings.sayaAman,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: alreadyConfirmed ? Colors.grey : AppColors.success,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildSiagaCard(BuildContext context, dynamic status) {
    final color = _getLevelColor(status.level);
    final icon = _getLevelIcon(status.level);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                color: color,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: Colors.white, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              status.levelLabel.toUpperCase(),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (status.description.isNotEmpty) ...[
                        Text(
                          status.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        '${AppStrings.lastUpdated}: ${DateFormatter.timeAgo(status.updatedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
