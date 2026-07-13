import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/pialert_app_bar.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  static const _levelGuides = [
    {
      'level': 1,
      'label': 'Normal',
      'color': AppColors.levelNormal,
      'icon': Icons.check_circle,
      'guide': 'Aktivitas sehari-hari normal.\n'
          'Pantau informasi dari BPBD dan BPPTKG.\n'
          'Kenali jalur evakuasi dan titik kumpul terdekat.\n'
          'Siapkan tas siaga darurat.',
      'do': [
        'Beraktivitas seperti biasa',
        'Pantau informasi resmi dari BPBD',
        'Kenali lingkungan sekitar',
        'Ikuti simulasi bencana jika ada',
      ],
      'dont': [
        'Tidak perlu panik',
        'Jangan mudah percaya informasi hoax',
      ],
    },
    {
      'level': 2,
      'label': 'Waspada',
      'color': AppColors.levelWaspada,
      'icon': Icons.warning_amber_rounded,
      'guide': 'Tingkatkan kewaspadaan.\n'
          'Hindari mendekati puncak Gunung Merapi.\n'
          'Siapkan tas siaga darurat.\n'
          'Catat nomor kontak darurat.',
      'do': [
        'Pantau informasi setiap 6 jam',
        'Siapkan tas siaga darurat',
        'Hindari pendakian',
        'Dokumentasikan barang berharga',
      ],
      'dont': [
        'Jangan mendekati radius bahaya',
        'Jangan panik berlebihan',
      ],
    },
    {
      'level': 3,
      'label': 'Siaga',
      'color': AppColors.levelSiaga,
      'icon': Icons.warning_rounded,
      'guide': 'Meningkatkan kesiapsiagaan.\n'
          'Warga di radius bahaya bersiap mengungsi.\n'
          'Siapkan barang berharga dan hewan ternak.\n'
          'Hubungi posko relawan terdekat.',
      'do': [
        'Pantau informasi secara intensif',
        'Kemasi barang berharga & dokumen',
        'Amankan hewan ternak ke kandang darurat',
        'Cek kesehatan kelompok rentan (lansia/balita)',
      ],
      'dont': [
        'Jangan mendekati radius rekomendasi bahaya',
        'Hindari aktivitas malam hari di lereng gunung',
      ],
    },
    {
      'level': 4,
      'label': 'Bahaya',
      'color': AppColors.levelBahaya,
      'icon': Icons.dangerous,
      'guide': 'Evakuasi mandiri ke titik kumpul.\n'
          'Ikuti arahan petugas BPBD dan relawan.\n'
          'Bawa tas siaga darurat.\n'
          'Bantu lansia, anak-anak, dan disabilitas.',
      'do': [
        'Evakuasi ke titik kumpul terdekat',
        'Ikuti arahan petugas',
        'Bawa tas siaga dan dokumen penting',
        'Bantu warga yang membutuhkan',
      ],
      'dont': [
        'Jangan tinggal di rumah',
        'Jangan menyebar hoax',
        'Jangan gunakan jalan alternatif tanpa info',
      ],
    },
  ];

  static const _tasSiagaItems = [
    'Dokumen penting (KTP, KK, akta, ijazah) dalam plastik kedap air',
    'Obat-obatan pribadi dan P3K (betadin, perban, plester)',
    'Makanan kering dan kaleng (beras, mie instan, biskuit, sarden)',
    'Air minum minimal 3 liter per orang',
    'Senter dan baterai cadangan',
    'Radio portabel untuk menerima informasi',
    'Masker (minimal 3 buah per orang)',
    'Selimut atau sleeping bag',
    'Pakaian ganti untuk 3 hari',
    'Handphone dan power bank',
    'Uang tunai secukupnya',
    'Pembalut dan kebutuhan bayi (jika ada)',
    'Korek api dan lilin',
    'Tali tambang dan pisau lipat',
    'Peluit sebagai isyarat darurat',
  ];

  static const _kontakDarurat = [
    {'nama': 'BPBD Sleman', 'nomor': '0274-868225', 'icon': Icons.local_police},
    {'nama': 'BPBD Magelang', 'nomor': '0293-363555', 'icon': Icons.local_police},
    {'nama': 'BPBD Boyolali', 'nomor': '0276-324518', 'icon': Icons.local_police},
    {'nama': 'BPBD Kulon Progo', 'nomor': '0274-773710', 'icon': Icons.local_police},
    {'nama': 'BPBD Bantul', 'nomor': '0274-368222', 'icon': Icons.local_police},
    {'nama': 'BPBD Gunungkidul', 'nomor': '0274-394091', 'icon': Icons.local_police},
    {'nama': 'BPBD DIY', 'nomor': '0274-555836', 'icon': Icons.local_police},
    {'nama': 'BPBD Kota Yogyakarta', 'nomor': '0274-4298225', 'icon': Icons.local_police},
    {'nama': 'Basarnas DIY', 'nomor': '0274-515515', 'icon': Icons.airline_seat_flat},
    {'nama': 'Puskesmas Cangkringan', 'nomor': '0274-896123', 'icon': Icons.local_hospital},
    {'nama': 'Puskesmas Pakem', 'nomor': '0274-895234', 'icon': Icons.local_hospital},
    {'nama': 'PLN Darurat', 'nomor': '123', 'icon': Icons.bolt},
    {'nama': 'Ambulans Darurat', 'nomor': '118', 'icon': Icons.local_hospital},
    {'nama': 'Call Center 112', 'nomor': '112', 'icon': Icons.phone_in_talk},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: PiAlertAppBar(
            icon: Icons.menu_book,
            title: AppStrings.edukasi,
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              tabs: [
                Tab(icon: Icon(Icons.lightbulb_outline), text: 'Panduan'),
                Tab(icon: Icon(Icons.backpack), text: 'Tas Siaga'),
                Tab(icon: Icon(Icons.phone), text: 'Kontak'),
              ],
            ),
          ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey.shade50, Colors.white],
            ),
          ),
          child: const TabBarView(
            children: [
              _PanduanSiagaTab(),
              _TasSiagaTab(),
              _KontakDaruratTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanduanSiagaTab extends StatelessWidget {
  const _PanduanSiagaTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Panduan Tindakan per Level Siaga',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Ketahui apa yang harus dilakukan pada setiap level siaga Gunung Merapi.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 16),
        ...EducationScreen._levelGuides.map((level) {
          final color = level['color'] as Color;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Icon(level['icon'] as IconData, color: color, size: 28),
              title: Text(
                'Level ${level['level']}: ${level['label']}',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text(level['guide'] as String),
                const SizedBox(height: 12),
                const Text('Yang harus dilakukan:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...(level['do'] as List).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item.toString())),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),
                const Text('Yang tidak boleh:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                const SizedBox(height: 4),
                ...(level['dont'] as List).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.cancel, size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item.toString())),
                        ],
                      ),
                    )),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _TasSiagaTab extends StatelessWidget {
  const _TasSiagaTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Isi Tas Siaga Darurat',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Siapkan tas siaga darurat dan letakkan di tempat yang mudah dijangkau. Periksa dan perbarui isinya setiap 6 bulan.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 16),
        ...EducationScreen._tasSiagaItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4)),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _KontakDaruratTab extends StatelessWidget {
  const _KontakDaruratTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Kontak Darurat',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Simpan nomor-nomor penting ini. Tap nomor untuk menghubungi langsung.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 16),
        ...EducationScreen._kontakDarurat.map((kontak) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withAlpha(25),
                  child: Icon(kontak['icon'] as IconData, color: AppColors.primary),
                ),
                title: Text(kontak['nama'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(kontak['nomor'] as String),
                trailing: const Icon(Icons.phone, color: AppColors.primary),
                onTap: () {
                  final nomor = kontak['nomor'] as String;
                  final uri = Uri.parse('tel:$nomor');
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
            )),
      ],
    );
  }
}
