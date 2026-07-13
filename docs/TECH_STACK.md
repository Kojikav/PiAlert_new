# Tech Stack — PiAlert

**Platform:** Mobile (Android & iOS)  
**Arsitektur:** Feature-first dengan Firebase sebagai Backend-as-a-Service (BaaS)

---

## 1. Ringkasan Stack

| Layer | Teknologi |
|---|---|
| **Frontend / Mobile** | Flutter (Dart) |
| **State Management** | Provider atau Riverpod |
| **Database** | Firebase Firestore |
| **File Storage** | Firebase Storage |
| **Autentikasi** | Firebase Authentication |
| **Push Notification** | Firebase Cloud Messaging (FCM) |
| **Peta** | flutter_map + OpenStreetMap (tile) |
| **Geolokasi** | geolocator package |
| **Data Peta Statis** | GeoJSON (bundled dalam assets) |
| **Version Control** | Git + GitHub |
| **UI Design** | Figma |

---

## 2. Flutter Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.x.x
  firebase_auth: ^5.x.x
  cloud_firestore: ^5.x.x
  firebase_storage: ^12.x.x
  firebase_messaging: ^15.x.x

  # Peta & Geolokasi
  flutter_map: ^7.x.x
  latlong2: ^0.9.x
  geolocator: ^13.x.x

  # Image Picker (untuk laporan foto)
  image_picker: ^1.x.x

  # State Management
  provider: ^6.x.x
  # ATAU: flutter_riverpod: ^2.x.x

  # Utilitas
  intl: ^0.19.x              # Format tanggal & waktu
  cached_network_image: ^3.x.x  # Cache gambar dari Storage
  uuid: ^4.x.x               # Generate ID unik untuk laporan
  connectivity_plus: ^6.x.x  # Cek koneksi internet
  permission_handler: ^11.x.x # Handle izin kamera & lokasi
  flutter_local_notifications: ^17.x.x # Notifikasi lokal

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.x.x
```

> **Catatan:** Versi di atas adalah perkiraan terkini. Selalu cek [pub.dev](https://pub.dev) untuk versi stabil terbaru sebelum mulai coding.

---

## 3. Firebase Services

### 3.1 Firebase Authentication
- **Provider:** Email & Password
- **Role management:** Disimpan di Firestore (`users/{uid}.role`) bukan di Firebase custom claims (untuk kemudahan implementasi akademik)
- **Persistence:** Login sesi persisten secara default

### 3.2 Firebase Firestore
- **Mode:** Production (bukan test mode)
- **Struktur koleksi:** Lihat `DATA_MODEL.md`
- **Security Rules:** Wajib dikonfigurasi — warga tidak bisa write ke koleksi `siaga_status` atau `announcements`

### 3.3 Firebase Storage
- **Digunakan untuk:** Upload foto laporan warga
- **Path struktur:** `reports/{report_id}/{filename}.jpg`
- **Rules:** Hanya authenticated user yang dapat upload

### 3.4 Firebase Cloud Messaging (FCM)
- **Trigger:** Dipanggil saat admin mengubah level siaga (via Firebase Functions — opsional, atau manual dari admin app)
- **Topic:** Semua pengguna subscribe ke topic `siaga_merapi`
- **Platform:** Android (wajib) + iOS (perlu konfigurasi APNs)

---

## 4. Peta & Geolokasi

### flutter_map + OpenStreetMap
- **Tile provider:** OpenStreetMap (gratis, tanpa API key berbayar)
- **URL Template:** `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- **Overlay data:** GeoJSON layer untuk titik kumpul, jalur evakuasi, zona bahaya

### GeoJSON Assets
- File GeoJSON disimpan di `assets/geojson/`
- `titik_kumpul.geojson` — titik kumpul evakuasi per dusun
- `jalur_evakuasi.geojson` — jalur evakuasi rekomendasi
- `zona_bahaya.geojson` — radius zona bahaya Merapi

### geolocator
- **Digunakan untuk:** Mengambil koordinat GPS saat warga membuat laporan
- **Permission:** `ACCESS_FINE_LOCATION` (Android), `NSLocationWhenInUseUsageDescription` (iOS)

---

## 5. Struktur Folder Project Flutter

```
pialert/
├── android/
├── ios/
├── assets/
│   ├── geojson/
│   │   ├── titik_kumpul.geojson
│   │   ├── jalur_evakuasi.geojson
│   │   └── zona_bahaya.geojson
│   └── images/
│       └── logo.png
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── app.dart                        # MaterialApp + routing
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart         # Palet warna (level siaga, dll.)
│   │   │   ├── app_strings.dart        # String konstan (label, pesan error)
│   │   │   └── app_routes.dart         # Nama route
│   │   ├── theme/
│   │   │   └── app_theme.dart          # ThemeData global
│   │   ├── utils/
│   │   │   ├── date_formatter.dart
│   │   │   └── location_helper.dart
│   │   └── widgets/
│   │       ├── loading_indicator.dart
│   │       └── error_widget.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── report_model.dart
│   │   ├── siaga_status_model.dart
│   │   └── announcement_model.dart
│   ├── services/
│   │   ├── auth_service.dart           # Firebase Auth wrapper
│   │   ├── firestore_service.dart      # Firestore CRUD
│   │   ├── storage_service.dart        # Firebase Storage upload
│   │   ├── notification_service.dart   # FCM setup & handling
│   │   └── location_service.dart       # geolocator wrapper
│   ├── providers/                      # State management (Provider/Riverpod)
│   │   ├── auth_provider.dart
│   │   ├── siaga_provider.dart
│   │   ├── reports_provider.dart
│   │   └── announcement_provider.dart
│   └── features/
│       ├── auth/
│       │   ├── login_screen.dart
│       │   └── register_screen.dart
│       ├── home/
│       │   └── home_screen.dart        # Siaga level + banner + tombol Saya Aman
│       ├── map/
│       │   └── map_screen.dart         # Peta interaktif
│       ├── reports/
│       │   ├── feed_screen.dart        # Feed laporan
│       │   └── create_report_screen.dart
│       ├── education/
│       │   └── education_screen.dart   # Informasi & edukasi
│       └── admin/
│           └── admin_dashboard_screen.dart
├── pubspec.yaml
├── CLAUDE.md
└── README.md
```

---

## 6. Konfigurasi Platform

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Izin yang diperlukan -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Dibutuhkan untuk menandai lokasi laporan Anda</string>
<key>NSCameraUsageDescription</key>
<string>Dibutuhkan untuk mengambil foto laporan</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Dibutuhkan untuk memilih foto dari galeri</string>
```

---

## 7. Environment & Setup

### Prerequisites
- Flutter SDK >= 3.x (stable channel)
- Dart SDK >= 3.x
- Android Studio / VS Code dengan Flutter extension
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

### Setup Firebase
```bash
# Login ke Firebase
firebase login

# Inisialisasi FlutterFire
flutterfire configure
# Pilih project Firebase yang sudah dibuat
# Centang Android & iOS
```

### Jalankan Project
```bash
flutter pub get
flutter run
```
