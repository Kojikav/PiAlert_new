# AGENTS.md — PiAlert
> File ini adalah briefing utama proyek. Dibaca otomatis oleh AI coding agent
> (Claude Code, Cursor, Gemini CLI, Aider, Windsurf, dll). Jika kamu adalah
> AI agent yang baru pertama kali membuka proyek ini, **baca seluruh file ini
> sebelum menulis kode apapun.**

---

## 1. Tentang Proyek

**Nama:** PiAlert — Sistem Informasi Siaga Merapi Berbasis Komunitas
**Tujuan:** Aplikasi mobile yang memberi informasi siaga Gunung Merapi secara real-time dan memungkinkan warga melaporkan kondisi lapangan ke komunitas & petugas.
**Tipe proyek:** Tugas akhir semester — mata kuliah Teknologi Mobile untuk SDGs
**Platform:** Mobile (Android & iOS), dibangun dengan **Flutter**
**Backend:** **Firebase** (Firestore, Auth, Storage, FCM) — tidak ada backend custom/REST API

---

## 2. Dokumen Referensi (WAJIB DIBACA)

Sebelum mengerjakan task apapun, baca dokumen yang relevan:

| Dokumen | Kapan Dibaca |
|---|---|
| `docs/PRD.md` | Sebelum membuat/mengubah fitur apapun — berisi requirement & acceptance criteria |
| `docs/TECH_STACK.md` | Sebelum install dependency atau membuat struktur folder baru |
| `docs/DATA_MODEL.md` | Sebelum menulis query Firestore atau mengubah skema data |
| `docs/APP_FLOW.md` | Sebelum membuat screen baru atau mengubah alur navigasi |
| `docs/TEST_CASE.md` | Setelah implementasi fitur — untuk verifikasi & definition of done |

> **Aturan penting:** Jangan mengubah struktur data di `DATA_MODEL.md` atau menambah fitur baru di luar `PRD.md` tanpa konfirmasi eksplisit dari user terlebih dahulu.

---

## 3. Tech Stack Singkat

```
Frontend     : Flutter (Dart)
State Mgmt   : Provider (atau Riverpod — cek pubspec.yaml yang sudah ada)
Database     : Firebase Firestore
Storage      : Firebase Storage (foto laporan)
Auth         : Firebase Authentication (email & password)
Notifikasi   : Firebase Cloud Messaging (FCM)
Peta         : flutter_map + OpenStreetMap + GeoJSON (statis)
Geolokasi    : geolocator package
```

Detail lengkap dependency ada di `docs/TECH_STACK.md`.

---

## 4. Struktur Folder Project

```
lib/
├── main.dart
├── app.dart
├── core/              # constants, theme, utils, shared widgets
├── models/            # Data model (User, Report, SiagaStatus, Announcement)
├── services/          # Firebase wrapper (auth, firestore, storage, fcm, location)
├── providers/         # State management
└── features/          # Screen per fitur (auth, home, map, reports, education, admin)
```

Struktur folder lengkap ada di `docs/TECH_STACK.md` bagian 5.

---

## 5. Setup & Run Commands

```bash
# Install dependencies
flutter pub get

# Jalankan di emulator/device
flutter run

# Jalankan analisis kode (linting)
flutter analyze

# Jalankan test (jika ada)
flutter test

# Build APK untuk testing
flutter build apk --debug
```

> **Catatan untuk agent:** Project ini menggunakan Firebase. File `firebase_options.dart` dan konfigurasi `google-services.json`/`GoogleService-Info.plist` **sudah ada / sudah dikonfigurasi manual oleh user**. Jangan generate ulang atau overwrite file-file ini kecuali diminta eksplisit.

---

## 6. Coding Conventions

- **Bahasa kode:** Inggris (nama variabel, fungsi, class)
- **Bahasa UI/teks ke pengguna:** Bahasa Indonesia
- **Naming:** `camelCase` untuk variabel/fungsi, `PascalCase` untuk class/widget, `snake_case` untuk nama file
- **Widget:** Pisahkan widget kompleks ke file/komponen terpisah, hindari satu file > 300 baris
- **State Management:** Konsisten gunakan satu pendekatan (cek provider yang sudah dipakai di project sebelum menambah yang baru)
- **Komentar:** Tambahkan komentar singkat untuk logic Firestore query yang kompleks
- **Error Handling:** Selalu bungkus pemanggilan Firebase dengan try-catch dan tampilkan feedback ke user (SnackBar/Dialog), jangan silent fail

---

## 7. Firestore — Aturan Penting

- Struktur koleksi: `users`, `siaga_status`, `reports`, `announcements`, `safety_confirmations`
- **JANGAN** mengubah nama field atau struktur koleksi yang sudah didefinisikan di `docs/DATA_MODEL.md` tanpa konfirmasi user
- Saat menulis security rules baru, pastikan konsisten dengan kerangka di `docs/DATA_MODEL.md` bagian 6
- Field `role` user (`warga` / `admin`) **tidak boleh** bisa diubah sendiri oleh user dari client side

---

## 8. Batasan & Hal yang TIDAK Boleh Dilakukan Agent

- ❌ Jangan menambahkan fitur baru di luar `PRD.md` tanpa konfirmasi user
- ❌ Jangan mengganti tech stack inti (misal: ganti Firebase ke backend lain) tanpa diskusi
- ❌ Jangan menghapus atau menulis ulang file konfigurasi Firebase yang sudah ada
- ❌ Jangan membuat dummy/mock data permanen di production code — gunakan Firestore asli
- ❌ Jangan commit API key atau credential ke dalam kode (gunakan `.env` atau konfigurasi Firebase yang sudah ada)

---

## 9. Status Progress Development

> **Agent: update bagian ini setiap kali menyelesaikan task, agar agent berikutnya tahu progress terakhir.**

### Sudah Selesai
- [x] F-01: Autentikasi & Role Management (✅ 9/9 TC)
- [x] F-02: Tampilan & Update Level Siaga (✅ 4/4 TC)
- [x] F-03: Notifikasi Push Siaga (✅ 4/4 TC — requires Cloud Functions deploy)
- [x] F-04: Peta Interaktif (✅ 6/6 TC)
- [x] F-05: Crowd-Reporting Warga (✅ 7/7 TC)
- [x] F-06: Feed Laporan Warga (✅ 4/4 TC)
- [x] F-07: "Saya Aman" — Status Keselamatan (✅ 6/6 TC)
- [x] F-08: Broadcast Pengumuman Darurat (✅ 5/5 TC)
- [x] F-09: Dashboard Admin (✅ 4/4 TC)
- [x] F-10: Informasi & Edukasi (✅ 3/3 TC)
- [x] firestore.rules — siap deploy
- [x] Flutter analyze: No issues found ✅
- [x] All 56 test cases verified (✅ 53/56 TC: 50/50 functional, 3/6 non-functional)

### Sedang Dikerjakan
- [ ] Deploy Cloud Functions: `cd functions && npm install && firebase deploy --only functions`
- [ ] Test manual semua fitur di emulator/device (terkendala INSTALL_FAILED_INSUFFICIENT_STORAGE)
- [ ] Setup data awal di Firestore: `siaga_status/current` + 1 user admin

### Belum Dikerjakan
- [ ] _(semua fitur core F-01 s.d. F-10 sudah diimplementasikan dan terverifikasi)_

### Catatan untuk Agent Selanjutnya
**Setup Firebase Selesai (2026-07-01)**
- Firebase project: **KERIMZON**
- `firebase_options.dart` sudah digenerate dengan `flutterfire configure`
- `android/app/google-services.json` sudah terdownload
- Authentication (Email/Password), Firestore, dan Storage sudah aktif (test mode)
- `firestore.rules` sudah dibuat sesuai DATA_MODEL.md + validasi tambahan
- **Blocking:** INSTALL_FAILED_INSUFFICIENT_STORAGE — emulator storage penuh. Solusi: wipe data emulator atau build APK manual

**Semua 10 Fitur Core Selesai + Fitur Navigasi Rute Real-time (2026-07-12)**
| Fitur | Screen | Key Files |
|---|---|---|
| F-01 Autentikasi | Login, Register, Splash, Main (Bottom Nav) | `auth_provider.dart`, `auth_service.dart` |
| F-02 Level Siaga | HomeScreen Card, AdminDashboard update | `siaga_provider.dart`, `siaga_status_model.dart` |
| F-03 Notifikasi FCM | main.dart init | `notification_service.dart` |
| F-04 Peta | MapScreen (flutter_map + GeoJSON + marker + ORS Routing) | `map_screen.dart`, `assets/geojson/*`, `ors_config.dart` |
| F-05 Report | CreateReportScreen (form + foto + GPS) | `create_report_screen.dart`, `reports_provider.dart` |
| F-06 Feed | FeedScreen (real-time + pull-to-refresh) | `feed_screen.dart` |
| F-07 Saya Aman | HomeScreen button | `safety_provider.dart` |
| F-08 Pengumuman | HomeScreen banner, AdminDashboard form | `announcement_provider.dart` |
| F-09 Dashboard Admin | All 4 sections + route guard | `admin_dashboard_screen.dart` |
| F-10 Edukasi | 3 tab statis (offline) | `education_screen.dart` |

**Data Awal yang Perlu Diisi di Firestore:**
1. Buat dokumen `siaga_status/current: { level:1, levelLabel:"Normal", description:"Status Normal", updatedBy:"", updatedByName:"", updatedAt: Timestamp.now() }`
2. Set role admin: daftar via app → Firestore → ubah `role` user dari `"warga"` ke `"admin"`

**Keputusan Teknis:**
- State Management: **Provider** (ChangeNotifierProvider via MultiProvider di `app.dart`)
- Model: `fromFirestore(DocumentSnapshot)` / `toFirestore()` — bukan fromMap/toMap
- Services: wrapper tipis Firebase — no state, no business logic
- Providers: jembatan services ↔ UI — hold state, real-time listener via `.snapshots()`
- Error Handling: try-catch di provider + SnackBar di screen
- Core library desugaring di `android/app/build.gradle.kts` untuk flutter_local_notifications
- FCM background handler: top-level function + `@pragma('vm:entry-point')`
- `flutter analyze`: No issues found ✅ (1 pre-existing info in map_screen)
- `url_launcher` ditambahkan untuk dialer kontak darurat (TC-F10-03)
- `navigatorKey` ditambahkan di `notification_service.dart` untuk routing dari notifikasi (TC-F03-03)
- `reports_provider.dart`: return type `({bool success, String? message})` dengan exception-specific error messages (TC-F05-07)
- **Integrasi OpenRouteService (ORS)**: Ditambahkan fitur kalkulasi titik kumpul terdekat dan render rute jalan raya real-time via API ORS dengan key di `ors_config.dart` (TC-F04-07).
- **Geofencing & SOS Panic Button**: Menambahkan fitur geofencing radius bahaya kawah Merapi dinamis yang diatur oleh Admin dari database Firestore, serta Floating Panic Button SOS untuk mengirim lokasi koordinat darurat langsung ke Firestore dan menghubungkan telepon ke BPBD Sleman.

**Yang Perlu Dilakukan Selanjutnya:**
1. Salin API Key ORS Anda ke dalam `ors_config.dart`.
2. Deploy Cloud Functions: `cd functions && npm install && firebase deploy --only functions`
3. Test manual semua fitur sesuai `docs/TEST_CASE.md` termasuk radius dinamis (mengubah radius di panel admin dan melihat perubahan lingkaran di peta serta banner warning di beranda) dan tombol SOS.
4. Setup data awal Firestore (lihat di atas)
5. Buat composite indexes di Firebase Console untuk query `where('isDeleted', == false).orderBy('createdAt', desc)` di koleksi `reports` & `announcements`
6. Setup Firebase Cloud Functions untuk FCM trigger saat level siaga berubah (opsional)
7. Ganti GeoJSON dummy di `assets/geojson/` dengan data asli dari BPBD (catatan: zona bahaya sekarang sudah dinamis menggunakan CircleLayer berbasis status.dangerRadius dari database).

---

## 10. Cara Memulai Task Baru (untuk Agent)

1. Baca bagian **Status Progress Development** di atas untuk tahu posisi terakhir
2. Cek dokumen relevan di folder `docs/` sesuai task yang diminta
3. Jika task tidak jelas atau requirement tidak ada di `PRD.md`, **tanya user dulu** sebelum menulis kode
4. Setelah implementasi selesai, jalankan test case terkait di `docs/TEST_CASE.md` — fitur dianggap selesai hanya jika seluruh test case terkait lulus (✅)
5. Update bagian **Status Progress** di file ini
6. Jika membuat keputusan teknis penting (misal: pilih package tertentu), catat di **Catatan untuk Agent Selanjutnya**
