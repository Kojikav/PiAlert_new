import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/pialert_app_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/siaga_provider.dart';
import '../../services/location_service.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _locationService = LocationService();
  final _picker = ImagePicker();

  String? _selectedCategory;
  File? _photoFile;
  double? _latitude;
  double? _longitude;
  String _locationLabel = 'Mendeteksi lokasi...';
  bool _isSubmitting = false;
  bool _locationLoaded = false;

  static const _categories = [
    'hujan_abu',
    'bau_belerang',
    'suara_gemuruh',
    'jalan_terblokir',
    'pengungsian_darurat',
    'lainnya',
  ];

  static const _categoryLabels = {
    'hujan_abu': 'Hujan Abu',
    'bau_belerang': 'Bau Belerang',
    'suara_gemuruh': 'Suara Gemuruh',
    'jalan_terblokir': 'Jalan Terblokir',
    'pengungsian_darurat': 'Pengungsian Darurat',
    'lainnya': 'Lainnya',
  };

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    try {
      final hasPermission = await _locationService.requestPermission();
      if (!hasPermission) {
        setState(() => _locationLabel = 'Izin lokasi ditolak');
        return;
      }
      final pos = await _locationService.getCurrentLocation();
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _locationLabel = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
        _locationLoaded = true;
      });
    } catch (e) {
      setState(() => _locationLabel = 'Gagal mendapat lokasi');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(source: source, maxWidth: 1024);
    if (xFile != null) {
      setState(() => _photoFile = File(xFile.path));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori laporan'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi belum terdeteksi'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final reportsProv = context.read<ReportsProvider>();
    final siaga = context.read<SiagaProvider>();

    final reportId = const Uuid().v4();
    final result = await reportsProv.submitReport(
      reportId: reportId,
      authorUid: auth.user!.uid,
      authorName: auth.user!.name,
      category: _selectedCategory!,
      description: _descController.text.trim(),
      photoFile: _photoFile,
      latitude: _latitude!,
      longitude: _longitude!,
      locationLabel: _locationLabel,
      siagaLevel: siaga.status?.level ?? 1,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.laporanTerkirim), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Gagal mengirim laporan'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PiAlertAppBar(
        icon: Icons.add_circle_outline,
        title: AppStrings.buatLaporan,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Kategori *',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(_categoryLabels[cat]!),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: AppStrings.deskripsi,
                    hintText: 'Deskripsikan kondisi di lapangan...',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 10) return 'Minimal 10 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text(AppStrings.ambilFoto),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (_photoFile != null)
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_photoFile!, width: 64, height: 64, fit: BoxFit.cover),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_locationLabel, style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      if (!_locationLoaded)
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReport,
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text(AppStrings.kirimLaporan),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
