import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/reports_provider.dart';

class ReportsSection extends StatelessWidget {
  const ReportsSection({super.key});

  static const _categoryIcons = {
    'hujan_abu': Icons.grain,
    'bau_belerang': Icons.air,
    'suara_gemuruh': Icons.hearing,
    'jalan_terblokir': Icons.block,
    'pengungsian_darurat': Icons.run_circle,
    'lainnya': Icons.report_problem,
  };

  void _confirmDeleteReport(BuildContext context, String reportId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Laporan'),
        content: const Text('Yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ReportsProvider>().deleteReport(reportId);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsProv = context.watch<ReportsProvider>();

    if (reportsProv.reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text('Belum ada laporan',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    )),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reportsProv.reports.length,
      itemBuilder: (context, index) {
        final r = reportsProv.reports[index];
        final iconData = _categoryIcons[r.category] ?? Icons.report_problem;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(iconData, color: AppColors.primary, size: 32),
            title: Text(r.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(r.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDeleteReport(context, r.id),
            ),
          ),
        );
      },
    );
  }
}
