import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/announcement_provider.dart';

class AnnouncementSection extends StatefulWidget {
  const AnnouncementSection({super.key});

  @override
  State<AnnouncementSection> createState() => _AnnouncementSectionState();
}

class _AnnouncementSectionState extends State<AnnouncementSection> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _annType = 'info';
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createAnnouncement() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan konten harus diisi'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isCreating = true);

    final auth = context.read<AuthProvider>();
    final ann = context.read<AnnouncementProvider>();

    await ann.createAnnouncement(
      title: title,
      content: content,
      type: _annType,
      createdBy: auth.user!.uid,
      createdByName: auth.user!.name,
    );

    _titleController.clear();
    _contentController.clear();
    setState(() => _isCreating = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengumuman berhasil dikirim'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final announcementsProv = context.watch<AnnouncementProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Judul Pengumuman'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Isi Pengumuman'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['info', 'warning', 'danger'].map((t) {
              final labels = {'info': 'Info', 'warning': 'Peringatan', 'danger': 'Darurat'};
              final typeColors = {'info': AppColors.info, 'warning': AppColors.warning, 'danger': AppColors.danger};
              final isSelected = _annType == t;
              return ChoiceChip(
                label: Text(labels[t]!),
                selected: isSelected,
                selectedColor: typeColors[t],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
                onSelected: (_) => setState(() => _annType = t),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isCreating ? null : _createAnnouncement,
              child: _isCreating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Kirim Pengumuman'),
            ),
          ),
          const SizedBox(height: 24),
          if (announcementsProv.announcements.isNotEmpty) ...[
            Text('Pengumuman Aktif:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            ...announcementsProv.announcements.map((ann) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(ann.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(ann.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => announcementsProv.deactivateAnnouncement(ann.id),
                    ),
                  ),
                )),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text('Belum ada pengumuman aktif',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        )),
              ),
            ),
        ],
      ),
    );
  }
}
