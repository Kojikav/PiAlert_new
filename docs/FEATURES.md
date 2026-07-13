# Fitur-Fitur Aplikasi PiAlert

PiAlert adalah Aplikasi Mobile Sistem Informasi Siaga Merapi Berbasis Komunitas yang dibangun dengan **Flutter** dan **Firebase**. Aplikasi ini dirancang untuk memfasilitasi mitigasi bencana, pemantauan status aktivitas gunung, pelaporan komunitas, serta evakuasi mandiri yang cerdas.

Berikut adalah daftar lengkap fitur yang terimplementasi di dalam aplikasi PiAlert:

---

## 1. Fitur Utama Warga (Client-Side)

### 🔑 Autentikasi & Role Management (F-01)
* **Splash Screen Premium:** Animasi masuk (fade-in, scale-in logo, dan pulsing ring) berlatar belakang gradasi visual yang modern.
* **Registrasi & Login:** Menggunakan Firebase Authentication berbasis email dan password.
* **Proteksi Akun:** Akun otomatis terbagi menjadi role `warga` atau `admin`. User dialihkan ke halaman yang sesuai setelah login sukses.

### 🌋 Pemantauan Status Siaga Real-Time (F-02)
* **Real-time Sync:** Menampilkan status siaga terkini Gunung Merapi langsung dari Firestore.
* **4 Level Siaga Resmi:** Mendukung 4 tingkatan siaga sesuai klasifikasi BPBD/BPPTKG Yogyakarta:
  1. **Level 1 - Normal** (Warna Hijau - Ikon check circle)
  2. **Level 2 - Waspada** (Warna Kuning - Ikon warning outline)
  3. **Level 3 - Siaga** (Warna Oranye - Ikon warning solid)
  4. **Level 4 - Bahaya/Awas** (Warna Merah - Ikon dangerous)
* **Catatan Posko:** Menampilkan deskripsi kondisi terbaru dan waktu pembaruan terakhir yang diinput oleh Admin.

### 📍 Peta Interaktif & Rute Evakuasi Cerdas (F-04)
* **Peta OpenStreetMap:** Menggunakan library `flutter_map` dengan rendering cepat dan responsif.
* **Penanda Titik Kumpul:** Menampilkan marker titik kumpul pengungsian resmi (biru) lengkap dengan kapasitas dan fasilitas saat diklik.
* **Rute Evakuasi Jalan Raya (OpenRouteService API):**
  * Secara otomatis mendeteksi posisi GPS terkini pengguna.
  * Mencari Titik Kumpul terdekat berbasis kalkulasi formula jarak.
  * Menggambar rute jalan raya terbaik secara real-time berwarna **Oranye Tebal** langsung ke titik kumpul tersebut.
  * Kamera peta otomatis bergeser dan melakukan zoom pas (`_fitRouteBounds`) untuk menampilkan rute secara utuh.
* **Plotting Laporan Warga:** Menampilkan koordinat laporan bencana aktif dari komunitas langsung di atas peta (merah).

### 🚨 Deteksi Radius Bahaya & Geofencing Pintar (Smart Alert)
* **Real-time Geofencing:** Aplikasi membaca koordinat GPS warga secara berkala dan menghitung jarak lurusnya ke pusat kawah Merapi (`LatLng(-7.5407, 110.4457)`).
* **Warning Banner Darurat:** Jika warga terdeteksi berada di dalam radius bahaya aktif yang ditentukan oleh Admin, **Banner Merah Peringatan** akan muncul di atas halaman Beranda:
  > **🚨 ANDA DI ZONA BAHAYA!**  
  > Jarak Anda ke kawah Merapi hanya X km (Radius bahaya aktif saat ini: Y km). Segera ikuti rute evakuasi menuju titik kumpul terdekat.
* **Visualisasi Radius di Peta:** Peta menggambar lingkaran merah transparan (*CircleLayer*) secara dinamis berpusat di kawah Merapi dengan radius sesuai dengan parameter database (`status.dangerRadius`).

### 🆘 Tombol Darurat SOS (Panic Button)
* **Floating Action Button SOS:** Tombol merah Floating Action Button (FAB) berlabel **SOS** dipasang di halaman Beranda.
* **Double Confirmation:** Menekan tombol memicu dialog konfirmasi untuk menghindari salah klik.
* **Sinyal Darurat Database:** Ketika dikonfirmasi, aplikasi mencatat koordinat lokasi GPS warga saat itu juga ke koleksi `reports` Firestore dengan kategori `'lainnya'` dan deskripsi *"🚨 SOS DARURAT! Warga memerlukan penyelamatan segera..."*.
* **Direct Call BPBD Sleman:** Sesaat setelah data terkirim, aplikasi otomatis meluncurkan dialer telepon HP ke nomor panggilan darurat **BPBD Sleman (0274-868225)**.

### 📝 Crowd-Sourced Reporting (F-05 & F-06)
* **Buat Laporan:** Warga bisa mengirimkan laporan kondisi lapangan dengan form:
  * Kategori laporan (Hujan Abu, Bau Belerang, Suara Gemuruh, Jalan Terblokir, Pengungsian Darurat, Lainnya).
  * Deskripsi kejadian.
  * Lokasi GPS (diambil otomatis).
  * Unggah Foto bukti kejadian (disimpan aman di Firebase Storage).
* **Feed Laporan Terkini:** Daftar laporan real-time dari warga lain yang dikemas dalam bentuk kartu (*Card*) modern ber-border tipis, lengkap dengan nama pelapor, waktu pelaporan (*timeAgo*), foto, dan pin lokasi.

### 🟢 Konfirmasi Keselamatan "Saya Aman" (F-07)
* **Satu Ketukan:** Ketika status siaga naik ke tingkat bahaya (Level $\ge$ 2), tombol "Saya Aman" akan muncul di Beranda warga.
* **Pilihan Status:** Warga bisa memilih status mereka saat itu: `"Saya Aman"` atau `"Butuh Bantuan"`. Status ini langsung tersimpan ke database agar terpantau oleh petugas.

### 🌐 Pusat Info Gempa Terkini (BMKG)
* **Real-time API BMKG:** Menampilkan data gempa bumi terbaru secara live dari API resmi BMKG di halaman terpisah.
* **Detail Gempa:** Menampilkan Magnitudo, Kedalaman, Lokasi Koordinat, Waktu Kejadian, dan Wilayah Terdampak Utama dengan kartu visual yang jelas.

### 📢 Broadcast Pengumuman Darurat (F-08)
* **Emergency Banner:** Menampilkan pengumuman darurat prioritas dari Admin di bagian atas halaman Beranda warga agar langsung terbaca.

### 📖 Edukasi & Kontak Darurat (F-10)
* **Panduan Edukasi Dinamis:** Menampilkan tips siaga bencana (apa yang harus dilakukan & dihindari) yang isinya otomatis menyesuaikan status level siaga Merapi saat itu.
* **Daftar Kontak Darurat:** Akses cepat ke nomor telepon penting (BPBD Sleman/Magelang, Basarnas DIY, Puskesmas, PLN) yang terintegrasi langsung dengan dialer handphone.

---

## 2. Fitur Panel Administrator (Admin-Side)

### 📊 Dashboard Utama Admin (F-09)
* **Route Guarding:** Halaman dilindungi secara ketat; hanya pengguna terdaftar dengan role `'admin'` di Firestore yang bisa masuk ke halaman ini.
* **Tinjauan Cepat:** Menampilkan rangkuman statistik laporan aktif dari warga dan jumlah status konfirmasi keselamatan warga.

### 🔧 Manajemen Level Siaga & Radius Bahaya
* **Pembaruan Level:** Form untuk menaikkan/menurunkan 4 Level Siaga Merapi secara real-time.
* **Manajemen Radius Dinamis:** Admin dapat menginput batas radius bahaya (km). Memilih level siaga akan otomatis merekomendasikan radius default (Level 1 = 0km, Level 2 = 3km, Level 3 = 5km, Level 4 = 10km) yang tetap bisa disesuaikan manual.
* **Situasi Terkini:** Kolom catatan situasi/kondisi terkini dari posko pemantauan.

### 📣 Broadcast Pengumuman Darurat
* **Form Pengumuman:** Admin dapat membuat dan menyebarkan pengumuman darurat instan yang akan muncul sebagai banner merah berkedip di Beranda semua warga.

### 📋 Manajemen Laporan & Keselamatan Warga
* **Review Laporan Warga:** Admin dapat memantau seluruh laporan masuk beserta foto dan lokasi koordinat peta untuk validasi lapangan.
* **Pantau Keselamatan:** Admin dapat melihat daftar warga yang sudah mengonfirmasi keselamatannya, memisahkan warga yang `"Aman"` dan warga yang `"Butuh Bantuan"` secara real-time untuk mempercepat proses evakuasi tim SAR.
