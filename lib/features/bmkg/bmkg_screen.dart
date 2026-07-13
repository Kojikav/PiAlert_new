import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/pialert_app_bar.dart';
import '../../models/gempa_model.dart';
import '../../providers/bmkg_provider.dart';

class BmkgScreen extends StatelessWidget {
  const BmkgScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PiAlertAppBar(
          icon: Icons.public,
          title: 'Data BMKG',
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            tabs: [
              Tab(text: 'Terbaru'),
              Tab(text: 'M > 5.0'),
              Tab(text: 'Dirasakan'),
            ],
          ),
        ),
        body: Consumer<BmkgProvider>(
          builder: (context, prov, _) {
            if (prov.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (prov.errorMessage != null) {
              return _buildError(context, prov);
            }
            return TabBarView(
              children: [
                _buildGempaTerbaruTab(context, prov.gempaTerbaru),
                _buildGempaListTab(context, prov.gempaTerkini, showPotensi: true),
                _buildGempaListTab(context, prov.gempaDirasakan, showDirasakan: true),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, BmkgProvider prov) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              prov.errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => prov.fetchAll(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGempaTerbaruTab(BuildContext context, GempaModel? gempa) {
    if (gempa == null) {
      return const Center(child: Text('Data tidak tersedia'));
    }

    final color = _getMagnitudeColor(gempa.magnitudeValue);

    return RefreshIndicator(
      onRefresh: () => context.read<BmkgProvider>().fetchAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Gempa Terbaru',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'M ${gempa.magnitude}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    gempa.wilayah,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _infoRow(context, Icons.calendar_today, '${gempa.tanggal}, ${gempa.jam}'),
                  const SizedBox(height: 8),
                  _infoRow(context, Icons.arrow_downward, 'Kedalaman: ${gempa.kedalaman}'),
                  const SizedBox(height: 8),
                  _infoRow(context, Icons.location_on_outlined, '${gempa.lintang}, ${gempa.bujur}'),
                  if (gempa.dirasakan != null && gempa.dirasakan!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _infoRow(context, Icons.vibration, 'Dirasakan: ${gempa.dirasakan}'),
                  ],
                  if (gempa.potensi != null && gempa.potensi!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: AppColors.info),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              gempa.potensi!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (gempa.shakemap != null) ...[
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://data.bmkg.go.id/DataMKG/TEWS/${gempa.shakemap}',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[100],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                  errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGempaListTab(
    BuildContext context,
    List<GempaModel> list, {
    bool showPotensi = false,
    bool showDirasakan = false,
  }) {
    if (list.isEmpty) {
      return const Center(child: Text('Data tidak tersedia'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BmkgProvider>().fetchAll(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final gempa = list[index];
          return _buildGempaCard(context, gempa, showPotensi: showPotensi, showDirasakan: showDirasakan);
        },
      ),
    );
  }

  Widget _buildGempaCard(
    BuildContext context,
    GempaModel gempa, {
    bool showPotensi = false,
    bool showDirasakan = false,
  }) {
    final color = _getMagnitudeColor(gempa.magnitudeValue);

    return GestureDetector(
      onTap: () => _showGempaDetail(context, gempa),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                  gempa.magnitude,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${gempa.tanggal}, ${gempa.jam}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.arrow_downward, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        gempa.kedalaman,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  if (showDirasakan && gempa.dirasakan != null && gempa.dirasakan!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        gempa.dirasakan!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                  if (showPotensi && gempa.potensi != null && gempa.potensi!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      gempa.potensi!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.info,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  void _showGempaDetail(BuildContext context, GempaModel gempa) {
    final color = _getMagnitudeColor(gempa.magnitudeValue);

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
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'M ${gempa.magnitude}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                gempa.wilayah,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(height: 24),
              _detailRow(context, 'Tanggal', '${gempa.tanggal}, ${gempa.jam}'),
              _detailRow(context, 'Koordinat', '${gempa.lintang}, ${gempa.bujur}'),
              _detailRow(context, 'Kedalaman', gempa.kedalaman),
              if (gempa.dirasakan != null && gempa.dirasakan!.isNotEmpty)
                _detailRow(context, 'Dirasakan', gempa.dirasakan!),
              if (gempa.potensi != null && gempa.potensi!.isNotEmpty)
                _detailRow(context, 'Potensi', gempa.potensi!),
              if (gempa.shakemap != null) ...[
                const SizedBox(height: 16),
                Text('Shakemap', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://data.bmkg.go.id/DataMKG/TEWS/${gempa.shakemap}',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(child: Text('Shakemap tidak tersedia')),
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

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ],
    );
  }

  Color _getMagnitudeColor(double mag) {
    if (mag >= 7.0) return const Color(0xFF880E4F);
    if (mag >= 5.0) return AppColors.danger;
    if (mag >= 3.0) return AppColors.warning;
    return AppColors.levelNormal;
  }
}
