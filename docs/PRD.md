# PRD — Product Requirements Document
# PiAlert: Sistem Informasi Siaga Merapi Berbasis Komunitas

**Versi:** 1.0  
**Platform:** Mobile (Android & iOS) — Flutter  
**Tim:** Bakwan Kawi  
**Mata Kuliah:** Teknologi Mobile untuk SDGs

---

## 1. Ringkasan Produk

**PiAlert** adalah aplikasi mobile lintas platform yang memungkinkan warga di lereng Gunung Merapi mendapatkan informasi siaga bencana secara cepat dan terpadu, serta melaporkan kondisi lapangan secara real-time kepada sesama warga dan petugas. Aplikasi ini dibangun di atas infrastruktur Firebase dengan antarmuka Flutter.

| Atribut | Detail |
|---|---|
| **Nama Aplikasi** | PiAlert |
| **Tagline** | Sigap bersama, selamat bersama |
| **Platform** | Android & iOS (Flutter cross-platform) |
| **SDGs** | SDG 11, SDG 13, SDG 17 |
| **Bahasa UI** | Bahasa Indonesia |

---

## 2. Latar Belakang & Masalah

### 2.1 Konteks
Gunung Merapi merupakan gunung api paling aktif di dunia, berlokasi di wilayah Daerah Istimewa Yogyakarta. Warga di kawasan lereng Merapi (Sleman, Magelang, Klaten, Boyolali) membutuhkan sistem komunikasi kebencanaan yang cepat, mudah diakses, dan transparan.

### 2.2 Masalah Utama
- Informasi resmi dari BPPTKG/BPBD sering terlambat menjangkau warga di level dusun/kampung.
- Tidak ada saluran digital yang memungkinkan warga melaporkan kondisi lokal secara real-time.
- Warga kesulitan mengakses jalur evakuasi dan titik kumpul secara cepat saat darurat.

---

## 3. Pengguna (User Roles)

### Role 1: Warga
Warga dan komunitas di kawasan lereng Merapi sebagai pelapor kondisi lapangan dan penerima informasi siaga.

**Karakteristik:**
- Tinggal di sekitar lereng Merapi (DIY dan sekitarnya)
- Akses internet terbatas/tidak stabil saat darurat
- Mayoritas pengguna smartphone Android kelas menengah

### Role 2: Admin / Petugas
Admin/petugas (BPBD, relawan, pengurus dusun) sebagai pengelola informasi siaga, verifikator laporan, dan pengirim pengumuman darurat.

**Karakteristik:**
- Memiliki akses dashboard pengelolaan
- Berwenang memperbarui level siaga, verifikasi laporan, dan broadcast pengumuman

---

## 4. Fitur & Requirement

### 4.1 Fitur Core

#### F-01: Autentikasi & Role Management
- **Deskripsi:** Register, login, dan pembatasan akses berbasis 2 peran (warga dan admin/petugas).
- **Actor:** Semua pengguna
- **Acceptance Criteria:**
  - [ ] Pengguna baru dapat mendaftar menggunakan email dan password
  - [ ] Pengguna yang sudah terdaftar dapat login
  - [ ] Sistem membedakan akses antara role `warga` dan role `admin`
  - [ ] Admin tidak dapat didaftarkan melalui form publik (harus di-set manual di Firestore atau oleh super-admin)
  - [ ] Sesi login persisten (tidak logout saat app ditutup)
  - [ ] Tersedia tombol logout

---

#### F-02: Tampilan & Update Level Siaga
- **Deskripsi:** Menampilkan level siaga Merapi saat ini dengan indikator visual yang jelas; admin dapat memperbarui level beserta catatan situasi.
- **Actor:** Warga (lihat), Admin (lihat + update)
- **Level Siaga:**

  | Level | Label | Warna |
  |---|---|---|
  | 1 | Normal | Hijau |
  | 2 | Waspada | Kuning |
  | 3 | Bahaya | Merah |

- **Acceptance Criteria:**
  - [ ] Halaman Home menampilkan level siaga aktif dengan warna dan ikon yang sesuai
  - [ ] Admin dapat mengubah level siaga dan menambahkan catatan situasi
  - [ ] Perubahan level siaga langsung terrefleksi ke seluruh pengguna (real-time via Firestore)
  - [ ] Waktu pembaruan terakhir ditampilkan

---

#### F-03: Notifikasi Push Siaga
- **Deskripsi:** Notifikasi otomatis dikirim ke seluruh pengguna saat admin memperbarui level siaga Merapi.
- **Actor:** Warga (penerima)
- **Acceptance Criteria:**
  - [ ] Notifikasi push dikirim ke semua pengguna saat level siaga diperbarui
  - [ ] Notifikasi berisi informasi level baru dan ringkasan situasi
  - [ ] Notifikasi dapat dibuka langsung ke halaman Home

---

#### F-04: Peta Interaktif
- **Deskripsi:** Peta area lereng Merapi menampilkan titik kumpul, jalur evakuasi, zona bahaya, dan laporan warga.
- **Actor:** Warga
- **Layer Peta:**
  - Titik kumpul evakuasi per dusun (GeoJSON statis)
  - Jalur evakuasi rekomendasi (GeoJSON statis)
  - Radius zona bahaya (GeoJSON statis)
  - Pin laporan warga (realtime dari Firestore)
- **Acceptance Criteria:**
  - [ ] Peta dapat di-zoom in/out dan di-pan
  - [ ] Layer titik kumpul, jalur evakuasi, dan zona bahaya ditampilkan dari data GeoJSON
  - [ ] Pin laporan warga ditampilkan di peta dengan koordinat GPS yang sesuai
  - [ ] Tap pada pin laporan menampilkan ringkasan laporan
  - [ ] Lokasi pengguna saat ini ditampilkan (dengan izin lokasi)

---

#### F-05: Crowd-Reporting Warga
- **Deskripsi:** Warga dapat membuat laporan kondisi lokal berupa foto + lokasi GPS + kategori + deskripsi.
- **Actor:** Warga
- **Kategori Laporan:**
  - Hujan Abu
  - Bau Belerang
  - Suara Gemuruh
  - Jalan Terblokir
  - Pengungsian Darurat
  - Lainnya
- **Acceptance Criteria:**
  - [ ] Warga dapat membuat laporan dengan memilih kategori
  - [ ] Warga dapat menambahkan foto dari kamera atau galeri
  - [ ] Koordinat GPS otomatis diambil dari perangkat
  - [ ] Warga dapat menambahkan deskripsi teks singkat
  - [ ] Laporan tersimpan ke Firestore dan foto ke Firebase Storage
  - [ ] Laporan muncul di feed dan peta setelah berhasil dikirim

---

#### F-06: Feed Laporan Warga
- **Deskripsi:** Daftar seluruh laporan terbaru dari komunitas yang dapat dilihat publik.
- **Actor:** Warga
- **Acceptance Criteria:**
  - [ ] Feed menampilkan laporan warga diurutkan dari terbaru
  - [ ] Setiap item feed menampilkan: kategori, deskripsi singkat, foto (jika ada), waktu, dan lokasi kasar
  - [ ] Feed dapat di-refresh (pull-to-refresh)
  - [ ] Loading state ditampilkan saat data diambil

---

#### F-07: "Saya Aman" — Status Keselamatan
- **Deskripsi:** Saat level siaga meningkat, warga dapat mengetuk tombol "Saya Aman" untuk mengonfirmasi keselamatannya.
- **Actor:** Warga (input), Admin (monitor)
- **Acceptance Criteria:**
  - [ ] Tombol "Saya Aman" muncul di halaman Home saat level siaga ≥ 2 (Waspada)
  - [ ] Warga hanya bisa menekan tombol sekali per event siaga (tidak berulang untuk event yang sama)
  - [ ] Admin dapat melihat total warga yang sudah/belum merespons di Dashboard
  - [ ] Timestamp konfirmasi tersimpan

---

#### F-08: Broadcast Pengumuman Darurat
- **Deskripsi:** Admin dapat mengirim pengumuman situasional yang tampil sebagai banner di halaman Home seluruh pengguna.
- **Actor:** Admin
- **Acceptance Criteria:**
  - [ ] Admin dapat membuat dan mengirim pengumuman teks
  - [ ] Pengumuman tampil sebagai banner/card di halaman Home warga
  - [ ] Admin dapat menghapus pengumuman yang sudah tidak relevan
  - [ ] Pengumuman tampil real-time tanpa perlu refresh manual

---

#### F-09: Dashboard Admin
- **Deskripsi:** Halaman khusus admin untuk mengelola seluruh aspek operasional aplikasi.
- **Actor:** Admin
- **Acceptance Criteria:**
  - [ ] Admin dapat mengubah level siaga Merapi
  - [ ] Admin dapat melihat dan menghapus laporan warga yang tidak valid
  - [ ] Admin dapat melihat daftar dan jumlah warga yang sudah menekan "Saya Aman"
  - [ ] Admin dapat membuat dan menghapus pengumuman darurat
  - [ ] Halaman Dashboard hanya dapat diakses oleh pengguna dengan role `admin`

---

#### F-10: Informasi & Edukasi
- **Deskripsi:** Konten edukatif tentang panduan tindakan per level siaga, daftar barang tas siaga, dan kontak darurat.
- **Actor:** Warga
- **Konten yang disediakan:**
  - Panduan tindakan per level siaga (Normal/Waspada/Siaga/Awas)
  - Daftar barang yang harus ada di tas siaga darurat
  - Kontak darurat penting (BPBD, Basarnas, Puskesmas terdekat)
- **Acceptance Criteria:**
  - [ ] Konten edukatif dapat diakses dari menu navigasi utama
  - [ ] Konten dibagi per level siaga dengan tampilan yang jelas
  - [ ] Konten dapat diakses offline (pre-loaded/static content)

---

### 4.2 Fitur Bonus (Opsional)

| ID | Fitur | Deskripsi |
|---|---|---|
| B-01 | Auto-fetch Status BPPTKG | Ambil data status siaga otomatis dari endpoint publik magma.esdm.go.id |
| B-02 | Filter Layer Peta | Toggle tampil/sembunyikan layer peta (titik kumpul, jalur evakuasi, laporan) |
| B-03 | Riwayat Laporan Pribadi | Warga dapat melihat riwayat laporan yang pernah mereka buat |
| B-04 | Dark Mode | Dukungan tema gelap |

---

## 5. Non-Functional Requirements

| Kategori | Requirement |
|---|---|
| **Performa** | Halaman Home dan Feed harus load dalam < 3 detik pada koneksi 4G |
| **Ketersediaan** | Konten edukatif (F-10) harus dapat diakses offline |
| **Keamanan** | Firestore Security Rules harus memastikan warga tidak bisa mengakses data admin |
| **Keamanan** | Upload foto hanya diizinkan untuk pengguna yang sudah login |
| **Skalabilitas** | Firestore didesain untuk mendukung ratusan laporan tanpa degradasi performa |
| **UX** | Aplikasi harus bisa dioperasikan dengan satu tangan di kondisi darurat |
| **Bahasa** | Seluruh UI dalam Bahasa Indonesia |
| **Aksesibilitas** | Ukuran font minimal 14sp, kontras warna memenuhi WCAG AA |

---

## 6. Batasan Sistem

- Aplikasi **tidak** menjadi sumber siaga resmi; data level siaga diinput manual oleh admin (kecuali fitur bonus B-01 diimplementasikan).
- Data GeoJSON (titik kumpul, jalur evakuasi) bersifat **statis** dan hardcoded ke dalam aplikasi; diperbarui hanya saat rilis versi baru.
- Tidak ada fitur obrolan/chat langsung antar pengguna.
- Verifikasi laporan warga dilakukan secara manual oleh admin, bukan otomatis.
