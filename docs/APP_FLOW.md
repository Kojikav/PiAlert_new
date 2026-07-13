# App Flow — PiAlert
# Alur Pengguna & Navigasi Antar Screen

---

## 1. Diagram Alur Utama

```
┌─────────────────────────────────────────────────────────────┐
│                      LAUNCH APP                             │
└─────────────────────┬───────────────────────────────────────┘
                       │
                       ▼
              ┌─────────────────┐
              │  Splash Screen  │  (cek sesi login)
              └────────┬────────┘
                       │
           ┌───────────┴───────────┐
           │                       │
           ▼                       ▼
   [Belum login]            [Sudah login]
           │                       │
           ▼                  ┌────┴────┐
   ┌───────────────┐          │ cek role │
   │  Login Screen │          └────┬────┘
   └───────┬───────┘               │
           │               ┌───────┴───────┐
   [Belum punya akun]   [warga]         [admin]
           │                │               │
           ▼                ▼               ▼
   ┌──────────────┐  ┌──────────┐  ┌──────────────────┐
   │Register Scrn │  │  Main    │  │  Admin Dashboard │
   └──────┬───────┘  │  Screen  │  │  Screen          │
          │          │ (Bottom  │  └──────────────────┘
          └──────────┤  Nav)    │
                     └──────────┘
```

---

## 2. Struktur Navigasi

### 2.1 Navigation untuk Role: Warga
Menggunakan **Bottom Navigation Bar** dengan 4 tab:

```
Bottom Navigation Bar:
├── Tab 1: Home       (icon: home)
├── Tab 2: Peta       (icon: map)
├── Tab 3: Feed       (icon: list)
└── Tab 4: Edukasi    (icon: book)
```

### 2.2 Navigation untuk Role: Admin
Admin menggunakan halaman **Dashboard** yang berdiri sendiri (tidak menggunakan Bottom Nav warga). Admin memiliki akses ke:

```
Admin Dashboard Screen:
├── Section: Level Siaga (update level)
├── Section: Pengumuman (buat / hapus)
├── Section: Laporan Warga (lihat / hapus)
└── Section: Status "Saya Aman" (monitor)
```

---

## 3. Alur Per Screen

### Screen 1: Splash Screen
**Tujuan:** Inisialisasi Firebase, cek sesi login, routing awal.

```
Splash Screen
│
├── Cek Firebase Auth currentUser
│   ├── [null] → Login Screen
│   └── [ada]  → Ambil data user dari Firestore
│                 ├── role == "warga" → Main Screen (Tab: Home)
│                 └── role == "admin" → Admin Dashboard Screen
```

---

### Screen 2: Login Screen
**Tujuan:** Autentikasi pengguna dengan email & password.

**Elemen UI:**
- Logo PiAlert
- Field: Email
- Field: Password (with toggle visibility)
- Tombol: "Masuk"
- Link: "Belum punya akun? Daftar"

**Alur:**
```
Login Screen
│
├── Input email + password → Tap "Masuk"
│   ├── [Berhasil] → Ambil data role dari Firestore
│   │                 ├── warga → Main Screen (Home)
│   │                 └── admin → Admin Dashboard Screen
│   └── [Gagal]    → Tampilkan pesan error (email/password salah)
│
└── Tap "Daftar" → Register Screen
```

---

### Screen 3: Register Screen
**Tujuan:** Pendaftaran akun baru (khusus role warga).

**Elemen UI:**
- Field: Nama Lengkap
- Field: Email
- Field: Password
- Field: Konfirmasi Password
- Tombol: "Daftar"
- Link: "Sudah punya akun? Masuk"

**Alur:**
```
Register Screen
│
├── Input data → Tap "Daftar"
│   ├── Validasi: email format, password min 6 karakter, password match
│   ├── [Berhasil] → Buat user di Firebase Auth
│   │                → Simpan ke Firestore (users/{uid}) dengan role: "warga"
│   │                → Redirect ke Main Screen (Home)
│   └── [Gagal]    → Tampilkan pesan error
│
└── Tap "Masuk" → Login Screen
```

---

### Screen 4: Home Screen (Tab 1 — Warga)
**Tujuan:** Pusat informasi utama: level siaga, pengumuman, dan tombol "Saya Aman".

**Elemen UI:**
- **Header:** Nama pengguna + logo PiAlert
- **Card Level Siaga:** Badge warna sesuai level + label + deskripsi + waktu update
- **Banner Pengumuman:** Muncul jika ada pengumuman aktif dari admin (bisa lebih dari 1, scroll horizontal)
- **Tombol "Saya Aman":** Muncul hanya saat level siaga ≥ 2 (Waspada), berwarna hijau
- **Tombol Logout** (di AppBar)

**Alur:**
```
Home Screen
│
├── Listen real-time: siaga_status/current → update Card Level Siaga
├── Listen real-time: announcements (isActive == true) → update Banner
│
├── Tap "Saya Aman"
│   ├── Ambil koordinat GPS (dengan izin lokasi)
│   ├── Simpan ke safety_confirmations/{uid}
│   └── Tombol berubah jadi "✓ Sudah Dikonfirmasi" (disabled)
│
└── Tap Logout → Konfirmasi dialog → Firebase Auth signOut → Login Screen
```

---

### Screen 5: Peta Interaktif (Tab 2 — Warga)
**Tujuan:** Visualisasi geografis zona bahaya, jalur evakuasi, titik kumpul, dan laporan warga.

**Elemen UI:**
- **flutter_map Widget** dengan tile OpenStreetMap
- **Layer GeoJSON:** Titik kumpul (ikon biru), jalur evakuasi (garis hijau), zona bahaya (area merah transparan)
- **Pin laporan warga:** Marker sesuai kategori laporan
- **FAB (Floating Action Button):** Tombol "Buat Laporan" → menuju Create Report Screen
- **Lokasi pengguna:** Marker biru terang

**Alur:**
```
Peta Screen
│
├── Load GeoJSON dari assets (saat screen init)
├── Listen real-time: reports (isDeleted == false) → tampilkan pin
├── Izin lokasi diminta → tampilkan lokasi pengguna saat ini
│
├── Tap pin laporan → Bottom Sheet muncul:
│   - Kategori laporan
│   - Deskripsi singkat
│   - Foto (jika ada)
│   - Waktu laporan
│
└── Tap FAB "Buat Laporan" → Create Report Screen
```

---

### Screen 6: Feed Laporan (Tab 3 — Warga)
**Tujuan:** Daftar semua laporan terbaru dari komunitas.

**Elemen UI:**
- **List / ListView:** Daftar laporan diurutkan dari terbaru
- **Report Card:** Kategori (badge warna), nama pelapor, deskripsi, foto thumbnail, waktu
- **FAB:** Tombol "Buat Laporan" → Create Report Screen
- **Pull-to-Refresh**

**Alur:**
```
Feed Screen
│
├── Fetch realtime: reports (isDeleted == false, order by createdAt desc)
├── Pull to refresh → reload data
│
├── Tap Report Card → Detail Report Screen (opsional, jika diimplementasikan)
│
└── Tap FAB "Buat Laporan" → Create Report Screen
```

---

### Screen 7: Create Report Screen
**Tujuan:** Form membuat laporan kondisi lapangan.

**Elemen UI:**
- **Dropdown / Chip Selector:** Pilih kategori laporan
- **TextArea:** Deskripsi kondisi
- **Image Picker:** Tombol ambil foto (kamera atau galeri) — opsional
- **Preview foto** (setelah dipilih)
- **Lokasi otomatis:** Text "📍 Lokasi terdeteksi: [koordinat]"
- **Tombol:** "Kirim Laporan"

**Alur:**
```
Create Report Screen
│
├── Screen init → minta izin kamera & lokasi → ambil koordinat GPS otomatis
│
├── User memilih kategori (wajib)
├── User mengisi deskripsi (wajib, min 10 karakter)
├── User memilih foto (opsional)
│
└── Tap "Kirim Laporan"
    ├── Validasi: kategori & deskripsi harus diisi
    ├── Upload foto ke Firebase Storage (jika ada) → dapatkan URL
    ├── Simpan dokumen baru ke Firestore (reports/{autoId})
    ├── [Berhasil] → Kembali ke Feed Screen + tampilkan SnackBar sukses
    └── [Gagal]    → Tampilkan pesan error
```

---

### Screen 8: Edukasi (Tab 4 — Warga)
**Tujuan:** Konten informatif dan panduan tindakan per level siaga.

**Elemen UI:**
- **Tab view** atau **Accordion/ExpansionTile** per level siaga
- **Section:** Panduan tindakan per level
- **Section:** Daftar isi tas siaga darurat
- **Section:** Kontak darurat penting (BPBD, Basarnas, Puskesmas)
- **Konten statis** (tidak perlu internet setelah load pertama)

**Konten per Level:**

| Level | Panduan Singkat |
|---|---|
| Normal (1) | Aktivitas sehari-hari normal; pantau info dari BPBD |
| Waspada (2) | Hindari mendekati puncak; siapkan tas siaga |
| Siaga (3) | Evakuasi mandiri ke titik kumpul; ikuti arahan petugas |
| Awas (4) | Evakuasi segera! Tinggalkan kawasan radius bahaya |

---

### Screen 9: Admin Dashboard Screen
**Tujuan:** Pusat kendali admin untuk mengelola semua aspek operasional.

**Elemen UI:**
- **Section 1 — Level Siaga:**
  - Card level saat ini
  - Tombol "Perbarui Level" → Dialog pilih level + input catatan situasi

- **Section 2 — Pengumuman:**
  - List pengumuman aktif
  - Tombol "Buat Pengumuman" → Dialog/bottom sheet input judul + konten + tipe
  - Swipe-to-delete atau tombol hapus per pengumuman

- **Section 3 — Laporan Warga:**
  - List laporan terbaru (termasuk yang belum diverifikasi)
  - Tombol hapus laporan yang tidak valid

- **Section 4 — Status "Saya Aman":**
  - Counter: X dari Y warga sudah konfirmasi
  - List nama warga yang sudah konfirmasi + waktu

**Alur:**
```
Admin Dashboard Screen
│
├── Listen real-time: siaga_status/current → Section 1
├── Listen real-time: announcements        → Section 2
├── Listen real-time: reports              → Section 3
├── Listen real-time: safety_confirmations → Section 4
│
├── Tap "Perbarui Level" → Dialog:
│   - Pilih level (1/2/3/4)
│   - Input catatan situasi
│   - Confirm → Update Firestore + trigger FCM notification
│
├── Tap "Buat Pengumuman" → Dialog/Sheet:
│   - Input judul
│   - Input konten
│   - Pilih tipe (info/warning/danger)
│   - Confirm → Simpan ke announcements/{autoId}
│
├── Swipe/Hapus laporan → Konfirmasi dialog → Set isDeleted: true
│
└── Tap Logout → Konfirmasi → signOut → Login Screen
```

---

## 4. Ringkasan Screen & Route

| Screen | Route Name | Role | Navigasi |
|---|---|---|---|
| Splash Screen | `/splash` | Semua | Initial route |
| Login Screen | `/login` | Semua | Push |
| Register Screen | `/register` | Semua | Push |
| Main Screen (Bottom Nav) | `/main` | Warga | Replace setelah login |
| → Home Tab | — | Warga | Tab 0 |
| → Peta Tab | — | Warga | Tab 1 |
| → Feed Tab | — | Warga | Tab 2 |
| → Edukasi Tab | — | Warga | Tab 3 |
| Create Report Screen | `/create-report` | Warga | Push dari Peta / Feed |
| Admin Dashboard Screen | `/admin` | Admin | Replace setelah login |

---

## 5. Handling Notifikasi Push (FCM)

```
FCM Notifikasi Diterima
│
├── [App di foreground]  → Tampilkan in-app notification banner
├── [App di background]  → Notifikasi sistem OS muncul
└── [App ditutup]        → Notifikasi sistem OS muncul
                           → Tap notifikasi → buka app → Home Screen
```
