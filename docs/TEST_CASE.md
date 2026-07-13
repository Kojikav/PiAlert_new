# Test Case Document — PiAlert

**Tujuan:** Memastikan setiap fitur di `PRD.md` berfungsi sesuai acceptance criteria. Dokumen ini juga jadi acuan bagi AI agent untuk tahu kapan suatu fitur dianggap "selesai dan benar" (definition of done).

**Format ID:** `TC-[Fitur]-[Nomor]` → contoh `TC-F01-01`

**Status:**
- ⬜ Belum diuji
- ✅ Lulus
- ❌ Gagal

---

## F-01: Autentikasi & Role Management

| ID | Skenario | Langkah | Expected Result | Status |
|---|---|---|---|---|---|
| TC-F01-01 | Register akun baru berhasil | 1. Buka Register Screen 2. Isi nama, email, password valid 3. Tap "Daftar" | User baru tersimpan di Firebase Auth & Firestore (`role: warga`), redirect ke Home | ✅ |
| TC-F01-02 | Register dengan email sudah terdaftar | 1. Isi form dengan email yang sudah ada | Muncul pesan error "Email sudah terdaftar" | ✅ |
| TC-F01-03 | Register dengan password < 6 karakter | 1. Isi password "123" | Muncul validasi error sebelum submit ke Firebase | ✅ |
| TC-F01-04 | Login berhasil (warga) | 1. Login dengan akun role warga | Redirect ke Main Screen (Home) | ✅ |
| TC-F01-05 | Login berhasil (admin) | 1. Login dengan akun role admin | Redirect ke Admin Dashboard Screen | ✅ |
| TC-F01-06 | Login dengan password salah | 1. Masukkan password salah | Muncul pesan error, tidak redirect | ✅ |
| TC-F01-07 | Sesi login persisten | 1. Login 2. Tutup aplikasi sepenuhnya 3. Buka kembali | User tetap dalam keadaan login, langsung ke Home/Dashboard | ✅ |
| TC-F01-08 | Logout berhasil | 1. Tap tombol logout 2. Konfirmasi | Redirect ke Login Screen, sesi terhapus | ✅ |
| TC-F01-09 | Warga tidak bisa akses Admin Dashboard | 1. Login sebagai warga 2. Coba akses route `/admin` manual | Akses ditolak / redirect kembali | ✅ |

---

## F-02: Tampilan & Update Level Siaga

| ID | Skenario | Langkah | Expected Result | Status |
|---|---|---|---|---|---|
| TC-F02-01 | Home menampilkan level siaga aktif | 1. Login sebagai warga 2. Buka Home | Card level siaga tampil dengan warna & label sesuai level di Firestore | ✅ |
| TC-F02-02 | Admin update level siaga | 1. Login admin 2. Buka Dashboard 3. Ubah level + isi catatan 4. Konfirmasi | `siaga_status/current` di Firestore terupdate dengan level, deskripsi, dan timestamp baru | ✅ |
| TC-F02-03 | Update level real-time ke warga | 1. Admin update level 2. Warga sedang membuka Home (tanpa refresh) | Card level siaga di Home warga berubah otomatis tanpa reload manual | ✅ |
| TC-F02-04 | Waktu update terakhir tampil benar | 1. Buka Home | Label waktu sesuai `updatedAt` di Firestore, format mudah dibaca (misal: "2 menit lalu") | ✅ |

---

## F-03: Notifikasi Push Siaga

| ID | Skenario | Langkah | Expected Result | Status |
|---|---|---|---|---|---|
| TC-F03-01 | Notifikasi terkirim saat level berubah | 1. Admin update level siaga 2. Cek device warga (app di background) | Notifikasi push muncul di device warga | ✅ |
| TC-F03-02 | Isi notifikasi sesuai | 1. Cek notifikasi yang masuk | Judul & isi notifikasi mencerminkan level baru & ringkasan situasi | ✅ |
| TC-F03-03 | Tap notifikasi membuka app | 1. Tap notifikasi dari tray | App terbuka langsung ke Home Screen | ✅ |
| TC-F03-04 | Notifikasi saat app foreground | 1. App sedang dibuka (foreground) 2. Admin update level | In-app banner notifikasi muncul (tidak crash/freeze) | ✅ |

---

## F-04: Peta Interaktif

| ID | Skenario | Langkah | Expected Result | Status |
|---|---|---|---|---|---|
| TC-F04-01 | Peta dimuat dengan layer dasar | 1. Buka tab Peta | Tile OpenStreetMap tampil, layer titik kumpul/jalur evakuasi/zona bahaya muncul dari GeoJSON | ✅ |
| TC-F04-02 | Zoom & pan peta berfungsi | 1. Pinch zoom 2. Geser peta | Peta merespons tanpa lag berlebihan | ✅ |
| TC-F04-03 | Pin laporan warga tampil di peta | 1. Buat 1 laporan baru 2. Buka tab Peta | Pin baru muncul di koordinat yang sesuai | ✅ |
| TC-F04-04 | Tap pin laporan menampilkan detail | 1. Tap salah satu pin laporan | Bottom sheet muncul dengan kategori, deskripsi, foto, waktu | ✅ |
| TC-F04-05 | Lokasi pengguna ditampilkan | 1. Izinkan akses lokasi 2. Buka Peta | Marker biru lokasi pengguna tampil sesuai posisi GPS aktual | ✅ |
| TC-F04-06 | Izin lokasi ditolak | 1. Tolak izin lokasi saat diminta | Peta tetap tampil (tanpa marker lokasi pengguna), tidak crash | ✅ |

---

## F-05: Crowd-Reporting Warga

| ID | Skenario | Langkah | Expected Result | Status |
|---|---|---|---|---|---|
| TC-F05-01 | Buat laporan lengkap (dengan foto) | 1. Pilih kategori 2. Isi deskripsi 3. Ambil foto 4. Kirim | Laporan tersimpan ke Firestore, foto ter-upload ke Storage, redirect ke Feed dengan SnackBar sukses | ✅ |
| TC-F05-02 | Buat laporan tanpa foto | 1. Pilih kategori 2. Isi deskripsi 3. Kirim tanpa foto | Laporan tersimpan dengan `photoUrl: null`, tidak error | ✅ |
| TC-F05-03 | Submit tanpa pilih kategori | 1. Kosongkan kategori 2. Tap "Kirim Laporan" | Muncul validasi error, laporan tidak terkirim | ✅ |
| TC-F05-04 | Submit dengan deskripsi < 10 karakter | 1. Isi deskripsi "abc" | Muncul validasi error | ✅ |
| TC-F05-05 | Koordinat GPS terambil otomatis | 1. Buka Create Report Screen | Koordinat lokasi muncul otomatis tanpa input manual | ✅ |
| TC-F05-06 | Laporan baru langsung muncul di Feed & Peta | 1. Kirim laporan 2. Buka Feed/Peta | Laporan baru tampil tanpa perlu restart app | ✅ |
| TC-F05-07 | Upload gagal karena tanpa koneksi internet | 1. Matikan internet 2. Kirim laporan | Muncul pesan error jelas, tidak crash, data tidak hilang (idealnya bisa retry) | ✅ |

---

## F-06: Feed Laporan Warga

| ID | Skenario | Langkah | Expected Result | Status |
|---|---|---|---|---|---|
| TC-F06-01 | Feed menampilkan laporan terbaru di atas | 1. Buka tab Feed | Laporan terurut dari `createdAt` terbaru ke terlama | ✅ |
| TC-F06-02 | Pull-to-refresh berfungsi | 1. Tarik layar ke bawah di Feed | Data ter-refresh, indikator loading muncul sesaat | ✅ |
| TC-F06-03 | Laporan yang dihapus admin tidak tampil | 1. Admin hapus 1 laporan (`isDeleted: true`) 2. Refresh Feed warga | Laporan tersebut tidak lagi muncul di Feed | ✅ |
| TC-F06-04 | Feed kosong (belum ada laporan) | 1. Kondisi awal tanpa data laporan | Tampil state kosong yang informatif (bukan layar putih/crash) | ✅ |

---

## F-07: "Saya Aman" — Status Keselamatan

| ID | Skenario | Langkah | Expected Result | Status |
|---|---|---|---|---|
| TC-F07-01 | Tombol muncul saat level ≥ Waspada | 1. Admin set level ke 2 (Waspada) 2. Warga buka Home | Tombol "Saya Aman" tampil | ✅ |
| TC-F07-02 | Tombol tidak muncul saat level Normal | 1. Level siaga = 1 (Normal) 2. Warga buka Home | Tombol "Saya Aman" tidak tampil | ✅ |
| TC-F07-03 | Tap "Saya Aman" berhasil | 1. Tap tombol | Data tersimpan ke `safety_confirmations/{uid}`, tombol berubah jadi "✓ Sudah Dikonfirmasi" | ✅ |
| TC-F07-04 | Tidak bisa konfirmasi 2x untuk event sama | 1. Sudah konfirmasi 2. Coba tap lagi | Tombol disabled / tidak bisa ditekan ulang | ✅ |
| TC-F07-05 | Tombol muncul lagi di event siaga baru | 1. Warga sudah konfirmasi di level 2 2. Admin naikkan ke level 3 | Tombol "Saya Aman" aktif kembali (karena `siagaLevel` berbeda) | ✅ |
| TC-F07-06 | Admin bisa lihat counter konfirmasi | 1. Beberapa warga konfirmasi 2. Admin buka Dashboard | Counter "X dari Y warga" sesuai jumlah aktual | ✅ |

---

## F-08: Broadcast Pengumuman Darurat

| ID | Skenario | Langkah | Expected Result | Status |
|---|---|---|---|---|
| TC-F08-01 | Admin buat pengumuman baru | 1. Isi judul, konten, pilih tipe 2. Kirim | Pengumuman tersimpan dengan `isActive: true` | ✅ |
| TC-F08-02 | Pengumuman tampil real-time di Home warga | 1. Admin kirim pengumuman 2. Warga sedang di Home | Banner pengumuman muncul tanpa refresh manual | ✅ |
| TC-F08-03 | Warna banner sesuai tipe | 1. Buat pengumuman tipe "danger" | Banner berwarna merah (sesuai mapping tipe) | ✅ |
| TC-F08-04 | Admin hapus pengumuman | 1. Hapus 1 pengumuman dari Dashboard | Banner hilang dari Home warga secara real-time | ✅ |
| TC-F08-05 | Multiple pengumuman aktif sekaligus | 1. Buat 2+ pengumuman aktif | Semua tampil di Home (bisa di-scroll jika lebih dari 1) | ✅ |

---

## F-09: Dashboard Admin

| ID | Skenario | Langkah | Expected Result | Status |
|---|---|---|---|---|
| TC-F09-01 | Hanya admin bisa akses Dashboard | 1. Login sebagai warga 2. Coba navigasi ke Dashboard | Akses ditolak | ✅ |
| TC-F09-02 | Admin bisa lihat semua laporan warga | 1. Buka Section Laporan di Dashboard | Semua laporan (termasuk belum diverifikasi) tampil | ✅ |
| TC-F09-03 | Admin hapus laporan tidak valid | 1. Tap hapus pada 1 laporan 2. Konfirmasi | `isDeleted: true` di Firestore, laporan hilang dari Feed & Peta warga | ✅ |
| TC-F09-04 | Semua section Dashboard real-time | 1. Buka Dashboard 2. Trigger perubahan dari device lain (laporan baru/konfirmasi baru) | Data di Dashboard terupdate otomatis | ✅ |

---

## F-10: Informasi & Edukasi

| ID | Skenario | Langkah | Expected Result | Status |
|---|---|---|---|---|
| TC-F10-01 | Konten edukasi dapat diakses | 1. Buka tab Edukasi | Konten panduan per level, tas siaga, kontak darurat tampil lengkap | ✅ |
| TC-F10-02 | Konten dapat diakses offline | 1. Matikan internet 2. Buka tab Edukasi | Konten tetap tampil normal (karena data statis lokal) | ✅ |
| TC-F10-03 | Kontak darurat dapat di-tap | 1. Tap salah satu kontak darurat | Membuka dialer telepon | ✅ |

---

## Non-Functional Test Cases

| ID | Kategori | Skenario | Expected Result | Status |
|---|---|---|---|---|---|
| TC-NF-01 | Performa | Buka Home & Feed pada koneksi 4G | Load < 3 detik | ✅ |
| TC-NF-02 | Keamanan | Warga coba write langsung ke `siaga_status` via console/manual | Ditolak oleh Firestore Security Rules | ✅ |
| TC-NF-03 | Keamanan | User belum login coba upload foto | Ditolak oleh Storage Rules | ⬜ |
| TC-NF-04 | Aksesibilitas | Cek ukuran font & kontras warna di seluruh screen | Font ≥ 14sp, kontras memenuhi WCAG AA | ⬜ |
| TC-NF-05 | Kompatibilitas | Jalankan app di Android & iOS | Semua fitur core berfungsi normal di kedua platform | ⬜ |
| TC-NF-06 | Reliabilitas | Hilangkan koneksi internet di tengah penggunaan app | App tidak crash, muncul pesan/indikator offline yang jelas | ✅ |

---

## Cara Menggunakan Dokumen Ini (untuk Agent & Developer)

1. Setelah mengimplementasikan suatu fitur, jalankan test case terkait fitur tersebut satu per satu
2. Update kolom **Status** (✅/❌) sesuai hasil pengujian
3. Jika ❌, catat detail bug di bagian **Catatan untuk Agent Selanjutnya** pada `AGENTS.md`
4. Fitur dianggap **selesai (done)** hanya jika seluruh test case terkait berstatus ✅
5. Saat mengupdate **Status Progress Development** di `AGENTS.md`, sinkronkan dengan status test case di sini
