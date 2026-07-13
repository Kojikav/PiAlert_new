# Data Model — PiAlert
# Firestore Database Schema

---

## Gambaran Koleksi

```
firestore/
├── users/                  # Data profil pengguna
├── siaga_status/           # Status level siaga Merapi (single document)
├── reports/                # Laporan kondisi dari warga
├── announcements/          # Pengumuman darurat dari admin
└── safety_confirmations/   # Konfirmasi "Saya Aman" dari warga
```

---

## 1. Koleksi `users`

**Path:** `users/{uid}`  
**Dibuat saat:** Register berhasil (via Firebase Auth `uid`)

```
users/
└── {uid}  (Document ID = Firebase Auth UID)
    ├── uid: string              # Sama dengan document ID
    ├── name: string             # Nama lengkap pengguna
    ├── email: string            # Email login
    ├── role: string             # "warga" | "admin"
    ├── fcmToken: string         # Token FCM untuk push notification
    ├── createdAt: timestamp     # Waktu registrasi
    └── updatedAt: timestamp     # Waktu update terakhir
```

**Contoh dokumen:**
```json
{
  "uid": "abc123xyz",
  "name": "Budi Santoso",
  "email": "budi@gmail.com",
  "role": "warga",
  "fcmToken": "dYz...token...",
  "createdAt": "2025-01-01T00:00:00Z",
  "updatedAt": "2025-01-01T00:00:00Z"
}
```

**Firestore Rules:**
- User hanya bisa read/write dokumen miliknya sendiri (`uid == request.auth.uid`)
- Admin bisa read semua dokumen users
- Field `role` tidak bisa diubah oleh warga (hanya admin)

---

## 2. Koleksi `siaga_status`

**Path:** `siaga_status/current`  
**Catatan:** Koleksi ini hanya berisi **satu dokumen** dengan ID `current`. Tidak ada dokumen lain.

```
siaga_status/
└── current  (Document ID = "current", selalu satu)
    ├── level: number            # 1 (Normal) | 2 (Waspada) | 3 (Siaga)
    ├── levelLabel: string       # "Normal" | "Waspada" | "Bahaya"
    ├── description: string      # Catatan situasi dari admin
    ├── updatedBy: string        # UID admin yang memperbarui
    ├── updatedByName: string    # Nama admin
    └── updatedAt: timestamp     # Waktu pembaruan terakhir
```

**Contoh dokumen:**
```json
{
  "level": 2,
  "levelLabel": "Waspada",
  "description": "Terjadi peningkatan kegempaan vulkanik sejak pukul 06.00 WIB.",
  "updatedBy": "adminUID123",
  "updatedByName": "Petugas BPBD Sleman",
  "updatedAt": "2025-06-01T06:30:00Z"
}
```

**Firestore Rules:**
- Semua authenticated user bisa **read**
- Hanya user dengan `role == "admin"` yang bisa **write**

---

## 3. Koleksi `reports`

**Path:** `reports/{reportId}`  
**Dibuat saat:** Warga berhasil submit laporan

```
reports/
└── {reportId}  (Document ID = auto-generated)
    ├── id: string               # Sama dengan document ID
    ├── authorUid: string        # UID warga pembuat laporan
    ├── authorName: string       # Nama warga pembuat laporan
    ├── category: string         # Lihat kategori di bawah
    ├── description: string      # Deskripsi singkat kondisi
    ├── photoUrl: string | null  # URL foto di Firebase Storage (nullable)
    ├── latitude: number         # Koordinat GPS latitude
    ├── longitude: number        # Koordinat GPS longitude
    ├── locationLabel: string    # Label lokasi teks (misal: "Dusun Kalitengah Lor")
    ├── isVerified: boolean      # Default: false; diubah admin jika valid
    ├── isDeleted: boolean       # Soft delete oleh admin; default: false
    ├── siagaLevel: number       # Level siaga saat laporan dibuat
    └── createdAt: timestamp     # Waktu laporan dibuat
```

**Nilai valid untuk `category`:**
```
"hujan_abu"
"bau_belerang"
"suara_gemuruh"
"jalan_terblokir"
"pengungsian_darurat"
"lainnya"
```

**Contoh dokumen:**
```json
{
  "id": "report_abc456",
  "authorUid": "userUID789",
  "authorName": "Siti Aminah",
  "category": "hujan_abu",
  "description": "Hujan abu tipis mulai turun sejak pagi di Dusun Kalitengah.",
  "photoUrl": "https://firebasestorage.../reports/report_abc456/photo.jpg",
  "latitude": -7.5456,
  "longitude": 110.4231,
  "locationLabel": "Dusun Kalitengah Lor, Cangkringan",
  "isVerified": false,
  "isDeleted": false,
  "siagaLevel": 2,
  "createdAt": "2025-06-01T07:15:00Z"
}
```

**Firestore Rules:**
- Authenticated user bisa **read** semua report (`isDeleted == false`)
- Authenticated user dengan role `warga` bisa **create** laporan baru
- Hanya `admin` yang bisa **update** atau **delete** laporan
- Warga tidak bisa mengubah laporan milik orang lain

**Firebase Storage Path:**
```
reports/{reportId}/{filename}
```

---

## 4. Koleksi `announcements`

**Path:** `announcements/{announcementId}`  
**Dibuat saat:** Admin mengirim pengumuman darurat

```
announcements/
└── {announcementId}  (Document ID = auto-generated)
    ├── id: string               # Sama dengan document ID
    ├── title: string            # Judul pengumuman singkat
    ├── content: string          # Isi pengumuman
    ├── type: string             # "info" | "warning" | "danger"
    ├── isActive: boolean        # True = tampil di Home; False = disembunyikan
    ├── createdBy: string        # UID admin pembuat
    ├── createdByName: string    # Nama admin
    ├── createdAt: timestamp     # Waktu dibuat
    └── updatedAt: timestamp     # Waktu terakhir diubah
```

**Nilai valid untuk `type`:**
```
"info"     → Banner biru  (informasi umum)
"warning"  → Banner oranye (peringatan)
"danger"   → Banner merah  (darurat kritis)
```

**Contoh dokumen:**
```json
{
  "id": "ann_xyz789",
  "title": "Jalur Evakuasi Kaliurang Ditutup",
  "content": "Jalur Kaliurang arah utara ditutup mulai pukul 08.00 WIB karena lahar dingin. Gunakan jalur alternatif Pakem.",
  "type": "danger",
  "isActive": true,
  "createdBy": "adminUID123",
  "createdByName": "Petugas BPBD Sleman",
  "createdAt": "2025-06-01T08:00:00Z",
  "updatedAt": "2025-06-01T08:00:00Z"
}
```

**Firestore Rules:**
- Semua user (termasuk yang belum login) bisa **read** pengumuman aktif
- Hanya `admin` yang bisa **create**, **update**, **delete**

---

## 5. Koleksi `safety_confirmations`

**Path:** `safety_confirmations/{uid}`  
**Catatan:** Document ID = UID warga. Satu dokumen per warga.

```
safety_confirmations/
└── {uid}  (Document ID = Firebase Auth UID warga)
    ├── uid: string              # UID warga
    ├── name: string             # Nama warga
    ├── latitude: number | null  # Lokasi saat konfirmasi (nullable)
    ├── longitude: number | null # Lokasi saat konfirmasi (nullable)
    ├── siagaLevel: number       # Level siaga saat konfirmasi
    └── confirmedAt: timestamp   # Waktu konfirmasi "Saya Aman"
```

**Logika penting:**
- Dokumen ini di-**overwrite** setiap kali warga menekan "Saya Aman"
- Untuk membedakan apakah warga sudah konfirmasi pada event siaga saat ini, bandingkan `siagaLevel` pada dokumen ini dengan `siagaLevel` di `siaga_status/current`
- Jika `siagaLevel` tidak cocok, tombol "Saya Aman" ditampilkan kembali

**Contoh dokumen:**
```json
{
  "uid": "userUID789",
  "name": "Siti Aminah",
  "latitude": -7.5456,
  "longitude": 110.4231,
  "siagaLevel": 2,
  "confirmedAt": "2025-06-01T07:00:00Z"
}
```

**Firestore Rules:**
- Warga hanya bisa **write** dokumen dengan ID miliknya sendiri
- `Admin` bisa **read** semua dokumen

---

## 6. Firestore Security Rules (Kerangka)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    function isAdmin() {
      return isAuthenticated() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    function isOwner(uid) {
      return isAuthenticated() && request.auth.uid == uid;
    }

    // users: read own, admin read all, no direct role write by warga
    match /users/{uid} {
      allow read: if isOwner(uid) || isAdmin();
      allow create: if isOwner(uid);
      allow update: if isOwner(uid) && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role']);
    }

    // siaga_status: everyone read, only admin write
    match /siaga_status/{docId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // reports: authenticated read, warga create, admin update/delete
    match /reports/{reportId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAdmin();
    }

    // announcements: everyone read, only admin write
    match /announcements/{announcementId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // safety_confirmations: owner write, admin read all
    match /safety_confirmations/{uid} {
      allow read: if isAdmin();
      allow write: if isOwner(uid);
    }
  }
}
```
