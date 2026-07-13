class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'PiAlert';
  static const String tagline = 'Sigap bersama, selamat bersama';

  // Auth
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Konfirmasi Password';
  static const String fullName = 'Nama Lengkap';
  static const String noAccount = 'Belum punya akun? Daftar';
  static const String haveAccount = 'Sudah punya akun? Masuk';
  static const String logout = 'Keluar';
  static const String logoutConfirm = 'Apakah Anda yakin ingin keluar?';

  // Siaga levels
  static const String levelNormal = 'Normal';
  static const String levelWaspada = 'Waspada';
  static const String levelBahaya = 'Bahaya';

  // Home
  static const String statusSiaga = 'Status Siaga Merapi';
  static const String lastUpdated = 'Terakhir diperbarui';
  static const String sayaAman = 'Saya Aman';
  static const String sudahDikonfirmasi = '✓ Sudah Dikonfirmasi';
  static const String announcement = 'Pengumuman';
  static const String hello = 'Halo';

  // Reports
  static const String buatLaporan = 'Buat Laporan';
  static const String kategori = 'Kategori';
  static const String deskripsi = 'Deskripsi';
  static const String ambilFoto = 'Ambil Foto';
  static const String kirimLaporan = 'Kirim Laporan';
  static const String laporanTerkirim = 'Laporan berhasil dikirim';

  // Navigation
  static const String home = 'Beranda';
  static const String peta = 'Peta';
  static const String feed = 'Laporan';
  static const String edukasi = 'Edukasi';

  // Admin
  static const String dashboard = 'Dashboard Admin';
  static const String kelolaLevel = 'Kelola Level Siaga';
  static const String kelolaLaporan = 'Kelola Laporan Warga';
  static const String monitoringAman = 'Monitoring Saya Aman';
  static const String buatPengumuman = 'Buat Pengumuman';

  // Education
  static const String panduanSiaga = 'Panduan Tindakan per Level Siaga';
  static const String tasSiaga = 'Tas Siaga Darurat';
  static const String kontakDarurat = 'Kontak Darurat';

  // Errors
  static const String errorGeneral = 'Terjadi kesalahan. Silakan coba lagi.';
  static const String errorNetwork = 'Tidak ada koneksi internet.';
  static const String errorEmailUsed = 'Email sudah terdaftar';
  static const String errorWrongPassword = 'Email atau password salah';
  static const String errorWeakPassword = 'Password minimal 6 karakter';
  static const String errorInvalidEmail = 'Format email tidak valid';
  static const String errorPasswordsDontMatch = 'Password tidak cocok';
  static const String errorLocationDenied = 'Izin lokasi diperlukan';
}
