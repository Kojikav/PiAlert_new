import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/siaga_provider.dart';

class SiagaSection extends StatefulWidget {
  const SiagaSection({super.key});

  @override
  State<SiagaSection> createState() => _SiagaSectionState();
}

class _SiagaSectionState extends State<SiagaSection> {
  int _selectedLevel = 1;
  final _descController = TextEditingController();
  final _radiusController = TextEditingController(text: '0.0');
  bool _isUpdating = false;

  @override
  void dispose() {
    _descController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Color _levelColor(int level) {
    switch (level) {
      case 2: return AppColors.levelWaspada;
      case 3: return AppColors.levelSiaga;
      case 4: return AppColors.levelBahaya;
      default: return AppColors.levelNormal;
    }
  }

  Future<void> _updateSiagaLevel() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan situasi tidak boleh kosong'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final radius = double.tryParse(_radiusController.text.trim());
    if (radius == null || radius < 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Radius bahaya harus berupa angka positif'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isUpdating = true);

    final siaga = context.read<SiagaProvider>();
    final auth = context.read<AuthProvider>();

    final labels = {1: 'Normal', 2: 'Waspada', 3: 'Siaga', 4: 'Bahaya'};

    await siaga.updateStatus(
      level: _selectedLevel,
      levelLabel: labels[_selectedLevel]!,
      description: _descController.text.trim(),
      updatedBy: auth.user?.uid ?? '',
      updatedByName: auth.user?.name ?? '',
      dangerRadius: radius,
    );

    setState(() => _isUpdating = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Level siaga berhasil diperbarui ke ${labels[_selectedLevel]}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final siaga = context.watch<SiagaProvider>();
    final currentStatus = siaga.status;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (currentStatus != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _levelColor(currentStatus.level).withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _levelColor(currentStatus.level).withAlpha(100),
                ),
              ),
              child: Column(
                children: [
                  Text('Level saat ini: ${currentStatus.levelLabel} (Radius Bahaya: ${currentStatus.dangerRadius} km)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _levelColor(currentStatus.level),
                      )),
                  if (currentStatus.description.isNotEmpty)
                    Text(currentStatus.description),
                  Text(
                    '${AppStrings.lastUpdated}: ${DateFormatter.timeAgo(currentStatus.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text('Pilih Level Baru:',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [1, 2, 3, 4].map((level) {
              final chipLabels = {1: 'Normal', 2: 'Waspada', 3: 'Siaga', 4: 'Bahaya'};
              final isSelected = _selectedLevel == level;
              return ChoiceChip(
                label: Text(chipLabels[level]!),
                selected: isSelected,
                selectedColor: _levelColor(level),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
                onSelected: (_) => setState(() {
                  _selectedLevel = level;
                  final defaults = {1: '0.0', 2: '3.0', 3: '5.0', 4: '10.0'};
                  _radiusController.text = defaults[level]!;
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _radiusController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Radius Bahaya (km)',
              hintText: 'Masukkan radius bahaya dalam kilometer...',
              prefixIcon: Icon(Icons.radar),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Catatan Situasi',
              hintText: 'Deskripsi kondisi terkini...',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isUpdating ? null : _updateSiagaLevel,
              child: _isUpdating
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white,
                      ),
                    )
                  : const Text('Perbarui Level Siaga'),
            ),
          ),
        ],
      ),
    );
  }
}
