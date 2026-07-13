import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/pialert_app_bar.dart';
import '../../providers/reports_provider.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  static const _categoryColors = {
    'hujan_abu': Color(0xFF9E9E9E),
    'bau_belerang': Color(0xFF795548),
    'suara_gemuruh': Color(0xFFFF5722),
    'jalan_terblokir': Color(0xFFF44336),
    'pengungsian_darurat': Color(0xFFE91E63),
    'lainnya': Color(0xFF607D8B),
  };

  static const _categoryLabels = {
    'hujan_abu': 'Hujan Abu',
    'bau_belerang': 'Bau Belerang',
    'suara_gemuruh': 'Suara Gemuruh',
    'jalan_terblokir': 'Jalan Terblokir',
    'pengungsian_darurat': 'Pengungsian Darurat',
    'lainnya': 'Lainnya',
  };

  @override
  Widget build(BuildContext context) {
    final reportsProv = context.watch<ReportsProvider>();
    final reports = reportsProv.reports;

    return Scaffold(
      appBar: const PiAlertAppBar(
        icon: Icons.list_alt,
        title: 'Laporan Warga',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: reports.isEmpty
            ? _buildEmptyState(context)
            : RefreshIndicator(
                onRefresh: () => reportsProv.refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (ctx, i) => _buildReportCard(context, reports[i]),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createReport),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text('Belum ada laporan', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => context.read<ReportsProvider>().refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, dynamic report) {
    final categoryColor = _categoryColors[report.category] ?? AppColors.textSecondary;
    final categoryLabel = _categoryLabels[report.category] ?? report.category;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Icon + Category Info + Time)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      const SizedBox(height: 2),
                      Text(
                        'Dilaporkan oleh ${report.authorName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description Text
            Text(
              report.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
            ),
            // Photo if exists
            if (report.photoUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: report.photoUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 180,
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180,
                    color: Colors.grey[100],
                    child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 10),
            // Footer Location Info
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: categoryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    report.locationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
