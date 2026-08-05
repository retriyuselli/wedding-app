# Wedding App iOS — Checklist Pengecekan

Dokumen ini untuk QA manual semua halaman yang sudah dibuat di aplikasi iOS.

**Cara pakai:** centang `[x]` jika lulus, biarkan `[ ]` jika belum/gagal. Catat bug di kolom **Catatan** di bagian bawah setiap seksi.

---

## Informasi Testing


| Item                    | Nilai                                    |
| ----------------------- | ---------------------------------------- |
| Tanggal test            | 05 Juli 2026                             |
| Tester                  |                                          |
| Device                  | ☐ Simulator ☐ iPhone fisik               |
| Model iOS               |                                          |
| Versi app               | 1.0.0                                    |
| Backend URL (Simulator) | `http://127.0.0.1:8000/api/v1`           |
| Backend URL (Device)    | `http://<IP-Mac>:8000/api/v1`            |
| Akun test               | `ramadhona.utama@gmail.com` / `password` |


---



## Persiapan Sebelum Mulai

- [x] Backend Laravel berjalan:
  ```bash
  cd /Applications/MAMP/htdocs/wedding-app
  php artisan serve --host=0.0.0.0 --port=8000
  ```
- [x] Database sudah di-seed (`php artisan migrate:fresh --seed` jika perlu data baru)
- [x] App di-build & di-run dari Xcode
- [x] **Simulator:** `APIConfig.swift` pakai `127.0.0.1` (default)
- [x] **Device fisik:** `lanHost` di `APIConfig.swift` = IP Mac (`ipconfig getifaddr en0`)
- [x] Mac dan iPhone satu jaringan Wi-Fi (untuk device fisik)

---



## Legenda Status Fitur


| Simbol | Arti                             |
| ------ | -------------------------------- |
| ✅ API  | Terhubung ke backend Laravel     |
| 🎨 UI  | Tampilan saja / data sample      |
| 🚧     | Belum diimplementasi (bukan bug) |


---



## 1. Auth — Login & Register



### 1.1 Login (`LoginView`)


| #   | Test Case                                                           | Pass | Fail | Catatan        |
| --- | ------------------------------------------------------------------- | ---- | ---- | -------------- |
| 1   | Halaman login tampil dengan benar (header, field, tombol, dekorasi) | ☐    | ☐    |                |
| 2   | Login dengan email & password benar → masuk ke Home                 | ☐    | ☐    |                |
| 3   | Login dengan password salah → muncul pesan error                    | ☐    | ☐    |                |
| 4   | Login dengan email tidak valid → validasi / pesan error             | ☐    | ☐    |                |
| 5   | Tombol **Masuk** disabled saat field kosong                         | ☐    | ☐    |                |
| 6   | Loading indicator muncul saat proses login                          | ☐    | ☐    |                |
| 7   | Tap **Daftar sekarang** → navigasi ke Register                      | ☐    | ☐    |                |
| 8   | Tap **Lupa kata sandi?**                                            | ☐    | ☐    | 🚧 Belum aktif |
| 9   | Tombol Apple / Google / Telepon                                     | ☐    | ☐    | 🚧 Belum aktif |
| 10  | Keyboard: field Email → Password (Next/Go)                          | ☐    | ☐    |                |
| 11  | Scroll & dismiss keyboard berfungsi                                 | ☐    | ☐    |                |
| 12  | Backend mati → pesan error koneksi jelas                            | ☐    | ☐    |                |


**Koneksi API:** ✅ `POST /api/v1/auth/login`

---



### 1.2 Register (`RegisterView`)


| #   | Test Case                                                 | Pass | Fail | Catatan        |
| --- | --------------------------------------------------------- | ---- | ---- | -------------- |
| 1   | Halaman register tampil konsisten dengan gaya login       | ☐    | ☐    |                |
| 2   | Tombol back (chevron) kembali ke Login                    | ☐    | ☐    |                |
| 3   | Register dengan data lengkap & valid → berhasil masuk app | ☐    | ☐    |                |
| 4   | Konfirmasi password tidak cocok → muncul hint             | ☐    | ☐    |                |
| 5   | Email sudah terdaftar → pesan error dari server           | ☐    | ☐    |                |
| 6   | Password kurang dari 8 karakter → pesan error             | ☐    | ☐    |                |
| 7   | Tombol **Daftar** disabled jika form belum lengkap        | ☐    | ☐    |                |
| 8   | Tap **Masuk** di footer → kembali ke Login                | ☐    | ☐    |                |
| 9   | Tombol sosial (Apple/Google/Telepon)                      | ☐    | ☐    | 🚧 Belum aktif |


**Koneksi API:** ✅ `POST /api/v1/auth/register`

---



### 1.3 Sesi & Logout


| #   | Test Case                                              | Pass | Fail | Catatan |
| --- | ------------------------------------------------------ | ---- | ---- | ------- |
| 1   | Tutup app → buka lagi → **tetap login** (auto-restore) | ☐    | ☐    |         |
| 2   | Logout dari More → kembali ke Login                    | ☐    | ☐    |         |
| 3   | Setelah logout, token tidak bisa dipakai lagi          | ☐    | ☐    |         |


**Koneksi API:** ✅ `GET /api/v1/auth/me`, `POST /api/v1/auth/logout`

---



## 2. Home — Dashboard (`DashboardView`)


| #   | Test Case                                                   | Pass | Fail | Catatan |
| --- | ----------------------------------------------------------- | ---- | ---- | ------- |
| 1   | Tab bar 5 menu tampil: Home, Checklist, Guest, Budget, More | ☐    | ☐    |         |
| 2   | Nama mempelai / info pernikahan tampil                      | ☐    | ☐    |         |
| 3   | Ringkasan budget tampil                                     | ☐    | ☐    |         |
| 4   | Event pernikahan tampil                                     | ☐    | ☐    |         |
| 5   | Quote carousel berjalan otomatis                            | ☐    | ☐    |         |
| 6   | Pull-to-refresh / buka ulang app → data ter-update          | ☐    | ☐    |         |
| 7   | Tap shortcut **Vendor** → halaman Vendor terbuka            | ☐    | ☐    |         |
| 8   | Tap shortcut **Inspirasi** → halaman Inspirasi terbuka      | ☐    | ☐    |         |
| 9   | Tap shortcut **Pesan** → halaman Pesan terbuka              | ☐    | ☐    |         |
| 10  | Backend mati → error / fallback tampil wajar                | ☐    | ☐    |         |


**Koneksi API:** ✅ `wedding-info`, `wedding-budget`, `wedding-events`, `guests`

---



## 3. Vendor



### 3.1 List Vendor (`VendorView`)


| #   | Test Case                                        | Pass | Fail | Catatan |
| --- | ------------------------------------------------ | ---- | ---- | ------- |
| 1   | List vendor load dari API                        | ☐    | ☐    |         |
| 2   | Banner promo carousel berjalan                   | ☐    | ☐    |         |
| 3   | Filter kategori (24 kategori dari API) berfungsi | ☐    | ☐    |         |
| 4   | Search vendor berfungsi                          | ☐    | ☐    |         |
| 5   | Tap vendor → buka detail (tidak kembali ke list) | ☐    | ☐    |         |
| 6   | Backend mati → pesan error jelas                 | ☐    | ☐    |         |


**Koneksi API:** ✅ `GET /api/v1/vendors`, `GET /api/v1/categories`

---



### 3.2 Detail Vendor (`VendorDetailView`)


| #   | Test Case                                       | Pass | Fail | Catatan |
| --- | ----------------------------------------------- | ---- | ---- | ------- |
| 1   | Info vendor tampil (nama, lokasi, rating, dll.) | ☐    | ☐    |         |
| 2   | Tab paket per vendor tampil horizontal          | ☐    | ☐    |         |
| 3   | Ganti tab paket → konten berubah                | ☐    | ☐    |         |
| 4   | Harga & label **Mulai Dari** tampil benar       | ☐    | ☐    |         |
| 5   | Tombol back kembali ke list                     | ☐    | ☐    |         |
| 6   | Gambar vendor load (jika ada)                   | ☐    | ☐    |         |


**Koneksi API:** ✅ `GET /api/v1/vendors/{slug}`, `GET /api/v1/vendors/{slug}/packages`

---



### 3.3 Fasilitas Paket (`PackageFacilitiesView`)


| #   | Test Case                                  | Pass | Fail | Catatan |
| --- | ------------------------------------------ | ---- | ---- | ------- |
| 1   | Judul grup fasilitas tampil                | ☐    | ☐    |         |
| 2   | Item fasilitas per grup tampil benar       | ☐    | ☐    |         |
| 3   | Section **TIDAK TERMASUK** tampil bernomor | ☐    | ☐    |         |
| 4   | Tidak ada duplikasi header "Fasilitas"     | ☐    | ☐    |         |


---



## 4. Checklist (`ChecklistView` → `DetailChecklistView`)


| #   | Test Case                                | Pass | Fail | Catatan |
| --- | ---------------------------------------- | ---- | ---- | ------- |
| 1   | List section & tugas load dari API       | ☐    | ☐    |         |
| 2   | Progress / status tugas tampil           | ☐    | ☐    |         |
| 3   | Tap tugas → buka detail checklist        | ☐    | ☐    |         |
| 4   | Centang / uncentang sub-tugas tersimpan  | ☐    | ☐    |         |
| 5   | Tambah sub-tugas (jika ada)              | ☐    | ☐    |         |
| 6   | Upload lampiran (jika ada)               | ☐    | ☐    |         |
| 7   | Pull-to-refresh berfungsi                | ☐    | ☐    |         |
| 8   | Data kosong → tampilan empty state wajar | ☐    | ☐    |         |


**Koneksi API:** ✅ `customer-preparation-sections`, tasks, sub-tasks

---



## 5. Guest (`GuestView` + `GuestListView`)


| #   | Test Case                                                            | Pass | Fail | Catatan |
| --- | -------------------------------------------------------------------- | ---- | ---- | ------- |
| 1   | Statistik tamu (total, hadir, pending, absen) tampil                 | ☐    | ☐    |         |
| 2   | List tamu load dari API                                              | ☐    | ☐    |         |
| 3   | Filter RSVP (confirmed, pending, absent) berfungsi                   | ☐    | ☐    |         |
| 4   | Search tamu berfungsi                                                | ☐    | ☐    |         |
| 5   | Tambah tamu baru → tersimpan ke backend                              | ☐    | ☐    |         |
| 6   | Edit tamu → perubahan tersimpan                                      | ☐    | ☐    |         |
| 7   | Hapus tamu → terhapus dari list                                      | ☐    | ☐    |         |
| 8   | Jika API kosong → fallback sample data (catat jika tidak diinginkan) | ☐    | ☐    |         |


**Koneksi API:** ✅ `GET/POST/PUT/DELETE /api/v1/guests`

---



## 6. Budget (`BudgetView`)


| #   | Test Case                            | Pass | Fail | Catatan |
| --- | ------------------------------------ | ---- | ---- | ------- |
| 1   | Total budget & mata uang tampil      | ☐    | ☐    |         |
| 2   | Edit total budget → tersimpan ke API | ☐    | ☐    |         |
| 3   | Jadwal pembayaran tampil             | ☐    | ☐    |         |
| 4   | Tambah / edit jadwal pembayaran      | ☐    | ☐    |         |
| 5   | Pembayaran masuk tampil              | ☐    | ☐    |         |
| 6   | Tambah / edit pembayaran masuk       | ☐    | ☐    |         |
| 7   | Perhitungan sisa budget benar        | ☐    | ☐    |         |
| 8   | Data kosong → tampilan wajar         | ☐    | ☐    |         |


**Koneksi API:** ✅ `wedding-budget`, `wedding-payment-schedules`, `wedding-incoming-payments`

---



## 7. More (`MoreView`)



### 7.1 Halaman Utama


| #   | Test Case                                        | Pass | Fail | Catatan |
| --- | ------------------------------------------------ | ---- | ---- | ------- |
| 1   | Profil pasangan, tanggal, lokasi tampil          | ☐    | ☐    |         |
| 2   | Tap **Edit Profil** → `InfoTabView`              | ☐    | ☐    |         |
| 3   | Tap **Detail Pernikahan** → `WeddingDetailView`  | ☐    | ☐    |         |
| 4   | Tap **Pasangan** → `InfoTabView`                 | ☐    | ☐    |         |
| 5   | Share Wedding App (ShareLink) berfungsi          | ☐    | ☐    |         |
| 6   | **Keluar dari Akun** → logout & kembali ke Login | ☐    | ☐    |         |
| 7   | Pull-to-refresh memperbarui data profil          | ☐    | ☐    |         |


**Koneksi API:** ✅ `wedding-info`, `wedding-events`

---



### 7.2 Menu Belum Ada Halaman (🚧)

Centang jika sudah diverifikasi **belum navigasi** (expected):


| Menu                | Pass (wajar kosong) | Catatan |
| ------------------- | ------------------- | ------- |
| Vendor Tersimpan    | ☐                   |         |
| Inspirasi & Ide     | ☐                   |         |
| Dokumen             | ☐                   |         |
| Pengaturan          | ☐                   |         |
| Privasi & Keamanan  | ☐                   |         |
| Pengingat           | ☐                   |         |
| Bahasa              | ☐                   |         |
| Bantuan & FAQ       | ☐                   |         |
| Tentang Wedding App | ☐                   |         |


---



### 7.3 Detail Pernikahan (`WeddingDetailView` + `WeddingDetailEditView`)


| #   | Test Case                          | Pass | Fail | Catatan |
| --- | ---------------------------------- | ---- | ---- | ------- |
| 1   | Data detail pernikahan tampil      | ☐    | ☐    |         |
| 2   | Tap edit → form edit terbuka       | ☐    | ☐    |         |
| 3   | Simpan perubahan → data ter-update | ☐    | ☐    |         |
| 4   | Validasi field wajar               | ☐    | ☐    |         |


**Koneksi API:** ✅ `wedding-info`, `wedding-events`

---



### 7.4 Info Pasangan (`InfoTabView`)


| #   | Test Case                                              | Pass | Fail | Catatan |
| --- | ------------------------------------------------------ | ---- | ---- | ------- |
| 1   | Nama mempelai pria & wanita tampil                     | ☐    | ☐    |         |
| 2   | Edit nama → tersimpan ke API                           | ☐    | ☐    |         |
| 3   | Data budaya / songlist (jika ada) tampil & bisa diedit | ☐    | ☐    |         |


**Koneksi API:** ✅ `PUT /api/v1/wedding-info`

---



## 8. Inspirasi (`InspirationView`) — 🎨 Data Sample


| #   | Test Case                           | Pass | Fail | Catatan |
| --- | ----------------------------------- | ---- | ---- | ------- |
| 1   | Halaman terbuka dari Home           | ☐    | ☐    |         |
| 2   | Featured carousel berjalan          | ☐    | ☐    |         |
| 3   | Search & filter berfungsi           | ☐    | ☐    |         |
| 4   | Simpan / unsimpan inspirasi (lokal) | ☐    | ☐    |         |
| 5   | Tombol back kembali ke Home         | ☐    | ☐    |         |


**Koneksi API:** 🎨 Belum terhubung backend

---



## 9. Pesan (`MessagesView`) — 🎨 Data Sample


| #   | Test Case                              | Pass | Fail | Catatan |
| --- | -------------------------------------- | ---- | ---- | ------- |
| 1   | Halaman terbuka dari Home              | ☐    | ☐    |         |
| 2   | List thread pesan tampil               | ☐    | ☐    |         |
| 3   | Search & filter kategori berfungsi     | ☐    | ☐    |         |
| 4   | Tap thread → detail percakapan terbuka | ☐    | ☐    |         |
| 5   | Filter unread only berfungsi           | ☐    | ☐    |         |
| 6   | Tombol back kembali ke Home            | ☐    | ☐    |         |


**Koneksi API:** 🎨 Belum terhubung backend

---



## 10. Pengecekan UI/UX Global

Uji di **minimal 2 ukuran layar** (mis. iPhone SE & iPhone 15 Pro Max):


| #   | Aspek                                                    | Pass | Fail | Catatan |
| --- | -------------------------------------------------------- | ---- | ---- | ------- |
| 1   | Tidak ada teks terpotong / overlap                       | ☐    | ☐    |         |
| 2   | ScrollView bisa di-scroll sampai bawah                   | ☐    | ☐    |         |
| 3   | Keyboard tidak menutupi field input                      | ☐    | ☐    |         |
| 4   | Tab bar selalu accessible                                | ☐    | ☐    |         |
| 5   | Loading state tampil saat fetch API                      | ☐    | ☐    |         |
| 6   | Error state tampil (bukan layar kosong)                  | ☐    | ☐    |         |
| 7   | Font Poppins load dengan benar                           | ☐    | ☐    |         |
| 8   | Warna & tema konsisten antar halaman                     | ☐    | ☐    |         |
| 9   | Safe area (notch / home indicator) tidak tertutup konten | ☐    | ☐    |         |


---



## 11. Pengecekan Koneksi & Error


| #   | Skenario                                         | Pass | Fail | Catatan |
| --- | ------------------------------------------------ | ---- | ---- | ------- |
| 1   | **Simulator** + backend jalan → semua API OK     | ☐    | ☐    |         |
| 2   | **Device fisik** + backend jalan → semua API OK  | ☐    | ☐    |         |
| 3   | Backend dimatikan → pesan error di halaman API   | ☐    | ☐    |         |
| 4   | Mode pesawat → pesan tidak ada koneksi           | ☐    | ☐    |         |
| 5   | Login → tutup app → buka lagi → masih login      | ☐    | ☐    |         |
| 6   | User baru (tanpa data wedding) → app tidak crash | ☐    | ☐    |         |


---



## 12. Ringkasan Hasil


| Area            | Total Test | Lulus | Gagal | Belum Dicek |
| --------------- | ---------- | ----- | ----- | ----------- |
| Auth            | 21         |       |       |             |
| Home            | 10         |       |       |             |
| Vendor          | 16         |       |       |             |
| Checklist       | 8          |       |       |             |
| Guest           | 8          |       |       |             |
| Budget          | 8          |       |       |             |
| More            | 20         |       |       |             |
| Inspirasi       | 5          |       |       |             |
| Pesan           | 6          |       |       |             |
| UI/UX Global    | 9          |       |       |             |
| Koneksi & Error | 6          |       |       |             |
| **TOTAL**       | **117**    |       |       |             |


---



## 13. Daftar Bug


| #   | Halaman | Langkah Reproduksi | Ekspektasi | Aktual | Severity           | Status         |
| --- | ------- | ------------------ | ---------- | ------ | ------------------ | -------------- |
| 1   |         |                    |            |        | ☐ Low ☐ Med ☐ High | ☐ Open ☐ Fixed |
| 2   |         |                    |            |        | ☐ Low ☐ Med ☐ High | ☐ Open ☐ Fixed |
| 3   |         |                    |            |        | ☐ Low ☐ Med ☐ High | ☐ Open ☐ Fixed |


---



## 14. Catatan & Known Limitations

Fitur berikut **belum diimplementasi** — jangan dicatat sebagai bug:

- Login Apple / Google / Nomor Telepon
- Lupa kata sandi
- Label "Email atau Nomor Telepon" — backend hanya menerima **email**
- Inspirasi & Pesan masih pakai data sample
- Menu More: Vendor Tersimpan, Dokumen, Pengaturan, FAQ, dll.

---



## Referensi File iOS


| Halaman        | File                                                 |
| -------------- | ---------------------------------------------------- |
| Root / routing | `ios-app/WeddingApp/Sources/App/RootView.swift`      |
| Login          | `Sources/Features/Auth/LoginView.swift`              |
| Register       | `Sources/Features/Auth/RegisterView.swift`           |
| Dashboard      | `Sources/Features/Dashboard/DashboardView.swift`     |
| Vendor list    | `Sources/Features/Vendor/VendorView.swift`           |
| Vendor detail  | `Sources/Features/Vendor/VendorDetailView.swift`     |
| Checklist      | `Sources/Features/Checklist/ChecklistView.swift`     |
| Guest          | `Sources/Features/Guests/GuestView.swift`            |
| Budget         | `Sources/Features/Budget/BudgetView.swift`           |
| More           | `Sources/Features/More/MoreView.swift`               |
| Inspirasi      | `Sources/Features/Inspiration/InspirationView.swift` |
| Pesan          | `Sources/Features/Messages/MessagesView.swift`       |
| API config     | `Sources/Networking/APIConfig.swift`                 |


