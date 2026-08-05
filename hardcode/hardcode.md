# Hardcode Inventory — iOS App

## Definisi yang dipakai (logika fitur)

**Hardcode** = tombol / aksi / entry UI yang:

1. **Belum punya halaman** saat diketuk, atau  
2. Masih **stub / teks / share lokal** saja, padahal **backend sudah punya API**, atau  
3. CTA menjanjikan fitur (mis. “unduh”) yang **belum di-wire** ke endpoint sungguhan.

Bukan fokus: terjemahan / `L10n` (ditunda).

---

## Catatan historis

Bagian bawah file bisa masih berisi inventaris **string bahasa** (era L10n).  
Section yang sudah dianalisis ulang dengan definisi **logika fitur**: **§10–§15 Budget family**.

---

## 1. Login

**File:** `Features/Auth/LoginView.swift`


| String                                           | Elemen UI            |
| ------------------------------------------------ | -------------------- |
| `Selamat datang!`                                | Headline             |
| `Masuk untuk melanjutkan persiapan pernikahanmu` | Subtitle             |
| `Masukkan email Anda`                            | Placeholder email    |
| `Masukkan kata sandi`                            | Placeholder password |
| `Lupa kata sandi?`                               | Link lupa password   |
| `Masuk ke akun saya`                             | Tombol utama         |
| `atau`                                           | Divider social       |
| `Belum punya akun?`                              | Footer               |
| `Daftar sekarang`                                | Link daftar          |


---



## 2. Lupa Password (sheet di Login)

**File:** `Features/Auth/LoginView.swift`


| String                                                            | Elemen UI         |
| ----------------------------------------------------------------- | ----------------- |
| `Atur ulang kata sandi`                                           | Judul             |
| `Masukkan email akun Anda. Kami akan mengirim instruksi...`       | Deskripsi         |
| `Masukkan email Anda`                                             | Placeholder email |
| `Kirim ulang instruksi` / `Kirim instruksi reset`                 | Tombol utama      |
| `Kembali ke login`                                                | Link kembali      |
| `Email wajib diisi.`                                              | Validasi          |
| `Jika email terdaftar, instruksi reset kata sandi sudah dikirim.` | Status sukses     |


---



## 3. Register

**File:** `Features/Auth/RegisterView.swift`


| String           | Elemen UI |
| ---------------- | --------- |
| `Buat akun baru` | Headline  |


> Catatan: sebagian besar string Register sudah pakai `L10n.Auth.*`.

---



## 4. Auth Shared / Hero Branding

**File:** `Features/Auth/AuthLoginReference.swift`


| String                                                     | Elemen UI                       |
| ---------------------------------------------------------- | ------------------------------- |
| `Wedding App`                                              | Brand title                     |
| `Rencanakan hari bahagiamu\ndengan mudah dan terorganisir` | Tagline hero                    |
| `Kembali`                                                  | Accessibility label tombol back |


---



## 5. Dashboard / Home

**File:** `Features/Dashboard/DashboardView.swift`


| String                                              | Elemen UI                   |
| --------------------------------------------------- | --------------------------- |
| `Wedding` / `App`                                   | Brand wordmark              |
| `Wedding Couple`                                    | Fallback nama pasangan      |
| `Wedding venue`                                     | Fallback lokasi             |
| `Set date`                                          | Fallback tanggal Next Up    |
| `Upcoming`                                          | Fallback badge Next Up      |
| `Today`                                             | Badge hari-H                |
| `In \(days) days`                                   | Badge countdown             |
| `Venue Meeting`, `Tasting Session`, `Fitting Dress` | Kartu Next Up demo/fallback |


---



## 6. Wedding Info (legacy/dev)

**File:** `Features/Dashboard/InfoTabView.swift`


| String                  | Elemen UI        |
| ----------------------- | ---------------- |
| `Wedding Info`          | Navigation title |
| `Mempelai`              | Section          |
| `Nama Pengantin Pria`   | Field            |
| `Nama Pengantin Wanita` | Field            |
| `Budaya`                | Field            |
| `Budget`                | Section          |
| `Total Budget`          | Field            |
| `Mata Uang`             | Field            |
| `Catatan`               | Field            |
| `Simpan`                | Tombol simpan    |
| `Keluar`                | Tombol logout    |


---



## 7. Checklist (list)

**File:** `Features/Checklist/ChecklistView.swift`


| String                      | Elemen UI              |
| --------------------------- | ---------------------- |
| `Persiapan`                 | Fallback judul grup    |
| `Lainnya`                   | Grup tugas orphan      |
| `Tampilkan lebih sedikit`   | Collapse               |
| `Lihat semua (\(count))`    | Expand                 |
| `Selesai pada \(formatted)` | Subtitle tugas selesai |


---



## 8. Checklist Detail / Edit Tugas

**File:** `Features/Checklist/DetailChecklistView.swift`


| String                                                                | Elemen UI               |
| --------------------------------------------------------------------- | ----------------------- |
| `Detail Tugas`                                                        | Header title            |
| `Kelola dan pantau detail tugas...`                                   | Subtitle                |
| `Kategori`                                                            | Info cell               |
| `Prioritas`                                                           | Info cell / form        |
| `Tanggal Dibuat`                                                      | Info cell               |
| `Target Selesai`                                                      | Info cell / form        |
| `Deskripsi`                                                           | Section                 |
| `Sub Tugas`                                                           | Section                 |
| `Catatan`                                                             | Section                 |
| `Lampiran`                                                            | Section                 |
| `Selesai`                                                             | Label sub-task / status |
| `Tandai Belum Selesai` / `Tandai Selesai`                             | CTA status              |
| `Sedang dikerjakan` / `Belum dimulai` / `In Progress` / `Belum Mulai` | Status display          |
| `Edit Tugas`                                                          | Nav title               |
| `Judul Tugas` / `Judul tugas`                                         | Label + placeholder     |
| `Tulis deskripsi tugas`                                               | Placeholder             |
| `Tambahkan catatan`                                                   | Placeholder             |
| `Batal` / `Simpan`                                                    | Toolbar                 |
| `Gagal menyimpan perubahan. Coba lagi.`                               | Error                   |


---



## 9. Tamu (Guests)

**File:** `Features/Guests/GuestView.swift`


| String                   | Elemen UI                         |
| ------------------------ | --------------------------------- |
| `Bagikan Undangan`       | Quick action title                |
| `Kirim undangan digital` | Quick action subtitle             |
| `QR Check-in`            | Quick action title                |
| `Scan saat datang`       | Quick action subtitle             |
| `Export Data`            | Quick action title                |
| `Unduh daftar tamu`      | Quick action subtitle             |
| `Tamu`                   | Fallback subtitle (tanpa telepon) |


---



## 10. Budget (utama)

**File:** `Features/Budget/BudgetView.swift`  
**Dicek ulang:** 12 Juli 2026  

**Definisi hardcode (fokus logika, bukan bahasa):**  
tombol / aksi / entry UI yang **belum punya halaman**, **tidak memanggil API**, atau **masih stub/teks** padahal backend sudah menyediakan endpoint.

### 10.1 Peta aksi di halaman utama

| UI / Tombol | Aksi sekarang | Halaman / tujuan | API backend | Status |
| ----------- | ------------- | ---------------- | ----------- | ------ |
| Kartu Total Anggaran (tap) | Buka edit total | `EditTotalBudgetView` | `PUT wedding-budget` | ✅ Wire lengkap |
| Ikon `slider.horizontal.3` (kanan header) | Buka filter status expense | `BudgetExpenseFilterSheet` | `GET wedding-payment-schedules?status=` | ✅ **FIXED** 12 Jul 2026 |
| Ikon search | Mode cari lokal | (inline search) | — (filter client) | ✅ OK |
| Kartu Uang Masuk | Buka list | `IncomingPaymentsView` | `GET/POST/PUT/DELETE wedding-incoming-payments` | ✅ Wire lengkap |
| “Lihat detail” Ringkasan | Buka ringkasan | `BudgetSummaryDetailView` | pakai data schedules yang sudah di-load | ✅ Wire lengkap |
| Baris kategori | Buka detail kategori | `BudgetCategoryDetailView` | schedules + allocations | ✅ Wire lengkap |
| **Tambah Expense** | Buka form | `AddExpenseView` | `POST/PUT wedding-payment-schedules` | ✅ Wire lengkap |
| **Kategori Budget** | Buka kelola alokasi | `BudgetCategoriesView` | `wedding-budget-category-allocations` CRUD | ✅ Wire lengkap |
| **Laporan Budget** (“Unduh laporan lengkap”) | Sheet teks + `ShareLink` file `.txt` | `BudgetReportShareView` | file lokal (bukan API export) | ✅ **FIXED** 12 Jul 2026 — unduh/share file nyata |
| Hasil search → expense | Edit expense | `AddExpenseView` | PUT schedule | ✅ |
| Hasil search → kategori | Detail kategori | `BudgetCategoryDetailView` | — | ✅ |
| Hasil search → uang masuk | Edit uang masuk | `AddIncomingPaymentView` | PUT incoming | ✅ |

### 10.2 Hardcode logika (yang perlu diperhatikan)

#### A. Laporan Budget — CTA “unduh” tanpa unduhan sungguhan — ✅ FIXED 12 Jul 2026

| Item | Detail |
|------|--------|
| UI | Action bar: judul laporan + subtitle bernada **unduh laporan lengkap** |
| Sekarang | Generate teks lokal → tulis file temp `Laporan-Budget-YYYYMMDD.txt` → `ShareLink(item: fileURL)` (Save to Files / share) |
| Backend | **Tidak ada** endpoint export PDF/Excel/CSV (tidak wajib untuk klaim unduh file lokal) |
| Verdict | ✅ **FIXED** — unduh/bagikan file `.txt` nyata |

#### B. Ikon filter yang bukan filter — ✅ FIXED 12 Jul 2026

| Item | Detail |
|------|--------|
| UI | Header kanan: `slider.horizontal.3` |
| Sekarang | Membuka `BudgetExpenseFilterSheet` (Semua / Sudah Bayar / Belum Bayar / Terlambat) → `GET wedding-payment-schedules?status=` |
| Atur budget | Tetap via tap kartu Total Anggaran |
| Verdict | ✅ **FIXED** |

### 10.3 Bukan hardcode (sudah wire)

Semua alur inti Budget di halaman utama **sudah punya halaman + API**:

- Atur total anggaran  
- Tambah/edit expense  
- Kategori & alokasi  
- Uang masuk (list + form)  
- Ringkasan & detail per kategori  
- Mark paid (dari list kategori, bukan dari kartu utama)
- Filter status expense
- Laporan unduh/share file

### 10.4 Ringkas §10

| # | Temuan | Prioritas |
|---|--------|-----------|
| 1 | ~~**Laporan Budget** = share teks lokal, bukan unduh~~ | ✅ **FIXED** 12 Jul 2026 |
| 2 | ~~Ikon header seperti filter tapi buka Atur Budget~~ | ✅ **FIXED** 12 Jul 2026 |
| 3 | Sisa tombol utama | Tidak hardcode logika |

> Inventaris string bahasa di screenshot lama **bukan** scope “hardcode” definisi ini.

---



## 11. Budget Components

**File:** `Features/Budget/BudgetComponents.swift`  
**Dicek ulang:** 12 Juli 2026 (logika)

Komponen **presentational** saja (`BudgetCategoryRow`, summary card, donut, bar, `CurrencyFormatter`, `BudgetSummaryMetrics`). Tidak ada tombol orphan di file ini.

| UI | Perilaku | Halaman tujuan? | API? | Verdict |
|----|----------|-----------------|------|---------|
| Category row / chevron | Display; navigasi di parent | Parent (`BudgetView` / Categories) | — | ✅ |
| `reportText(...)` | Generate teks laporan lokal | Dipakai `BudgetReportShareView` (file `.txt`) | file lokal | ✅ **FIXED** 12 Jul 2026 |

**Hardcode logika:** tidak ada dead button di sini.

---

## 12. Tambah / Edit Expense

**File:** `Features/Budget/AddExpenseView.swift`  
**Dicek ulang:** 12 Juli 2026 (logika)

| UI / Tombol | Perilaku sekarang | Halaman? | API backend | Verdict |
|-------------|-------------------|----------|-------------|---------|
| Pilih kategori | Picker sheet | ✅ | `budget-payment-categories` | ✅ |
| Pilih tanggal | Picker sheet | ✅ | `due_date` di schedule | ✅ |
| Pilih acara | Picker (hanya jika ada event) | ✅ | `wedding-events` | ✅ |
| Pilih metode pembayaran | List + tambah metode | ✅ `AddPaymentMethodView` | `customer-payment-methods` CRUD | ✅ **FIXED** 12 Jul 2026 |
| Status bayar / belum | Segmented → payload | — | POST/PUT schedules | ✅ |
| Upload bukti | Dialog foto / file (JPG/PNG/PDF) | Viewer | API terima **jpg/png/pdf** | ✅ **FIXED** 12 Jul 2026 |
| Lihat / ganti bukti | Viewer / re-pick | ✅ | multipart PUT | ✅ |
| Simpan | POST/PUT (± multipart) | dismiss | ✅ | ✅ |
| Hapus expense | DELETE | dismiss | ✅ | ✅ |

### Hardcode / gap §12

1. ~~**Metode pembayaran** — UI iOS belum punya halaman tambah metode~~ → ✅ **FIXED** 12 Jul 2026 (`AddPaymentMethodView` + toolbar `+`)  
2. ~~**Bukti PDF** — picker iOS `.images` → upload PDF mati~~ → ✅ **FIXED** 12 Jul 2026 (`confirmationDialog` + `fileImporter`)

---

## 13. Ringkasan / Kategori / Atur Budget / Laporan / Detail kategori

**File:** `Features/Budget/BudgetPaymentFlows.swift`  
**Dicek ulang:** 12 Juli 2026 (logika)

### Detail kategori / list expense

| UI | Perilaku | Halaman? | API | Verdict |
|----|----------|----------|-----|---------|
| Tap baris | Edit expense | `AddExpenseView` | PUT | ✅ |
| Swipe Hapus | DELETE | — | ✅ | ✅ |
| Swipe Lunas | `PATCH …/mark-paid` | — | ✅ | ✅ |
| Toolbar `+` | Tambah expense | `AddExpenseView` | POST | ✅ |

### Ringkasan Anggaran (`BudgetSummaryDetailView`)

| UI | Perilaku | Verdict |
|----|----------|---------|
| Metrics + baris kategori → detail | Navigasi ke `BudgetCategoryDetailView` | ✅ |

### Kategori Budget (`BudgetCategoriesView`)

| UI | Perilaku | Verdict |
|----|----------|---------|
| Tap kategori | Detail kategori | ✅ |
| `+` / pencil | `EditCategoryAllocationView` | ✅ CRUD alokasi |

### Atur Budget (`EditTotalBudgetView`)

| UI | Perilaku | Verdict |
|----|----------|---------|
| Simpan | `PUT wedding-budget` | ✅ |

### Laporan (`BudgetReportShareView`)

| UI | Perilaku | API export? | Verdict |
|----|----------|-------------|---------|
| Sheet teks + `ShareLink` file `.txt` | Tulis temp file + share/unduh | file lokal | ✅ **FIXED** 12 Jul 2026 |
| Tombol Unduh / Bagikan Laporan | `ShareLink(item: fileURL)` | — | ✅ |

**Hardcode §13:** ✅ laporan unduh file sudah diperbaiki. Mark paid / delete / edit / alokasi entry **sudah wire**.

---

## 14. Alokasi Kategori

**File:** `Features/Budget/CategoryAllocationFlows.swift`  
**Dicek ulang:** 12 Juli 2026 (logika)

| UI | Perilaku | API | Verdict |
|----|----------|-----|---------|
| Simpan (create) | `POST wedding-budget-category-allocations` | ✅ | ✅ |
| Simpan (edit) | `PUT …/{id}` | ✅ | ✅ |
| Hapus Alokasi | `DELETE …/{id}` | ✅ | ✅ |

**Kesimpulan:** CRUD lengkap. **Tidak ada hardcode logika** (tidak ada tombol mati / missing page).

---

## 15. Uang Masuk

**File:** `Features/Budget/IncomingPaymentFlows.swift`  
**Dicek ulang:** 12 Juli 2026 (logika)

| UI | Perilaku | Halaman? | API | Verdict |
|----|----------|----------|-----|---------|
| Kartu ringkas (di Budget utama) | Parent button → list | `IncomingPaymentsView` | GET | ✅ |
| Chip filter status | Filter **client-side** | inline | Index support `?status=` (opsional, tidak dipakai) | ✅ berfungsi |
| Tap baris | Edit | `AddIncomingPaymentView` | PUT | ✅ |
| Tambah | Create | `AddIncomingPaymentView` | POST | ✅ |
| Hapus (context menu) | DELETE | — | ✅ | ✅ |
| Status menunggu/confirmed/rejected | Segmented di form → payload | — | ✅ | ✅ |
| Upload bukti uang masuk | **Tidak ada UI** | — | API validate **tanpa** proof upload | ✅ tidak ada mismatch |
| Alasan penolakan | **Tidak ada UI** | — | Kolom DB ada; tidak di API validate | ✅ tidak dijanjikan di UI |

**Kesimpulan §15:** alur CRUD + status **sudah wire**. Tidak ada dead button. Filter query server opsional belum dipakai (bukan hardcode CTA).

---

## Ringkas Budget family (logika hardcode)

| Prioritas | Temuan | Section |
|-----------|--------|---------|
| — | ~~Laporan “unduh” = share teks~~ → file `.txt` + ShareLink | ✅ **FIXED** 12 Jul 2026 · §10, §13 |
| — | ~~Ikon filter → Atur Budget~~ → filter sheet status + API `?status=` | ✅ **FIXED** 12 Jul 2026 · §10 |
| — | ~~Metode pembayaran hanya select~~ → `AddPaymentMethodView` | ✅ **FIXED** 12 Jul 2026 · §12 |
| — | ~~Bukti PDF images-only~~ → foto + fileImporter PDF | ✅ **FIXED** 12 Jul 2026 · §12 |
| — | Alokasi, uang masuk, mark paid, edit budget | ✅ bersih |

---

## 16. Vendor (list)


**File:** `Features/Vendor/VendorView.swift` (+ `Models/Vendor.swift`)


| String                                                             | Elemen UI           |
| ------------------------------------------------------------------ | ------------------- |
| `Reset Filter` / `Hapus`                                           | Filter chips        |
| `Memuat kategori...`                                               | Loading             |
| `Coba Lagi`                                                        | Retry               |
| `Semua`                                                            | Category chip       |
| `Hasil Filter` / `Semua Vendor`                                    | List header         |
| `Urutkan`                                                          | Sort label          |
| `Populer` / `Rating` / `Terbaru`                                   | Sort options        |
| `Rating X+` / `Terverifikasi` / `Tersimpan`                        | Active filter chips |
| `Belum menemukan yang cocok?`                                      | CTA card            |
| `Kirim kebutuhanmu...`                                             | CTA subtitle        |
| `Kirim\nPermintaan`                                                | CTA button          |
| `Filter Vendor` / `Batal` / `Reset` / `Terapkan`                   | Filter sheet        |
| `Kategori` / `Provinsi` / `Kota / Kabupaten` / `Rating Minimum`    | Filter sections     |
| Empty filter messages                                              | Empty               |
| `Muat Ulang Kategori`                                              | Button              |
| `Hanya Vendor Terverifikasi` / `Hanya Vendor Tersimpan` + subtitle | Toggles             |
| `(N review)` / `N paket` / `· dari Rp…`                            | Card meta           |


---



## 17. Vendor Detail / Paket

**Files:** `VendorDetailView.swift`, `PackageFacilitiesView.swift`


| String                                           | Elemen UI       |
| ------------------------------------------------ | --------------- |
| `Dari …` / `Unggulan`                            | Chips           |
| `Tentang Vendor` / `Kontak` / `Paket Pernikahan` | Sections        |
| `Belum ada paket tersedia.`                      | Empty           |
| `Vendor tidak ditemukan.` / `Coba Lagi`          | Error           |
| `N–M pax` / `≤ N pax` / `N jam`                  | Package meta    |
| `FASILITAS` / `TIDAK TERMASUK`                   | Section headers |


---



## 18. Inspirasi

**File:** `Features/Inspiration/InspirationView.swift`


| String                                              | Elemen UI           |
| --------------------------------------------------- | ------------------- |
| `Suka N+` / `Tersimpan`                             | Active filter chips |
| `Reset Filter`                                      | Button              |
| `Belum ada inspirasi tersimpan`                     | Empty               |
| `Inspirasi tidak ditemukan` + messages              | Empty               |
| `Filter Inspirasi` / `Batal` / `Reset` / `Terapkan` | Filter sheet        |
| `Kategori` / `Jumlah Suka`                          | Sections            |
| `Hanya Inspirasi Tersimpan` + subtitle              | Toggle              |
| `Lihat seluruh inspirasi` / `N inspirasi tersedia`  | Rows                |
| `Semua Inspirasi`                                   | Category title      |
| `Belum ada inspirasi` + message                     | Category empty      |


---



## 19. Pesan / Chat

**File:** `Features/Messages/MessagesView.swift` (+ `Models/Message.swift`)


| String                                     | Elemen UI               |
| ------------------------------------------ | ----------------------- |
| `Menampilkan pesan belum dibaca`           | Unread filter banner    |
| `Hasil Pencarian` / `Percakapan`           | List header             |
| `N chat`                                   | Count                   |
| `Belum ada pesan`                          | Thread preview fallback |
| `Online` / `Offline`                       | Presence                |
| `Semua` / `Vendor` / `Panitia` / `Support` | Category chips          |
| `Baru` / `Kemarin`                         | Relative time           |


---



## 20. Acara (Events)

**File:** `Features/Events/EventListView.swift`


| String                                           | Elemen UI |
| ------------------------------------------------ | --------- |
| `Acara Pernikahan`                               | Nav title |
| `Tambah Acara`                                   | Nav title |
| `Jenis Acara` / `Tanggal` / `Lokasi` / `Catatan` | Form      |
| `Batal` / `Simpan`                               | Toolbar   |


---



## 21. More (menu)

**File:** `Features/More/MoreView.swift`


| String           | Elemen UI                                   |
| ---------------- | ------------------------------------------- |
| `Wedding Couple` | Fallback display name                       |
| `Indonesia`      | Language subtitle (saat selection disabled) |


---



## 22. Detail Pernikahan (view)

**File:** `Features/More/WeddingDetailView.swift`


| String            | Elemen UI                       |
| ----------------- | ------------------------------- |
| `Garden Romantic` | Fallback konsep (budaya kosong) |


---



## 23. Edit Detail Pernikahan

**File:** `Features/More/WeddingDetailEditView.swift`


| String                                                                     | Elemen UI    |
| -------------------------------------------------------------------------- | ------------ |
| `Edit Detail Pernikahan`                                                   | Nav title    |
| `Pasangan` / `Tanggal & Lokasi` / `Konsep` / `Rangkaian Acara` / `Catatan` | Sections     |
| `Nama Mempelai Wanita/Pria` / `Lokasi Utama`                               | Placeholders |
| `Konsep Pernikahan`                                                        | Picker label |
| `Garden Romantic` / `Classic White` / `Rustic Charm` / `Modern Minimal`    | Opsi konsep  |
| `Belum ada acara...` / `Acara default bisa dihapus...`                     | Helper       |
| `Hapus Acara` / `Tambah Acara` / `Simpan Perubahan`                        | Actions      |
| `Hapus` / `Batal` + pesan alert                                            | Delete alert |
| `Tanggal Acara` / `Waktu Mulai/Selesai` / `Lokasi Acara`                   | Event fields |


---



## 24. Vendor Tersimpan

**File:** `Features/More/SavedVendorsView.swift`


| String                                 | Elemen UI    |
| -------------------------------------- | ------------ |
| `Vendor Tersimpan`                     | Header title |
| `Daftar vendor pilihan Anda`           | Subtitle     |
| `Belum ada vendor tersimpan` + message | Empty        |


---



## 25. Inspirasi Tersimpan

**File:** `Features/More/SavedInspirationView.swift`


| String                                    | Elemen UI    |
| ----------------------------------------- | ------------ |
| `Inspirasi & Ide`                         | Header title |
| `Simpan inspirasi dan referensi`          | Subtitle     |
| `Belum ada inspirasi tersimpan` + message | Empty        |


---



## 26. Dokumen

**File:** `Features/More/WeddingDocumentsView.swift`


| String                                     | Elemen UI      |
| ------------------------------------------ | -------------- |
| `Akad` / `Resepsi` / `Vendor` / `Keuangan` | Category chips |
| `Tidak ada dokumen` + filtered empty       | Empty          |
| `Buka / Unduh`                             | Context action |
| `Tanggal tidak diketahui`                  | Fallback date  |


---



## 27. Bantuan & FAQ

**Files:** `HelpFAQView.swift`, `HelpContent.swift`


| String                                                  | Elemen UI                             |
| ------------------------------------------------------- | ------------------------------------- |
| `Bantuan & FAQ` / `Kami siap membantu Anda`             | Header                                |
| `Cari bantuan atau pertanyaan...`                       | Search                                |
| `Topik Bantuan` / `FAQ Populer` / `Butuh Bantuan Lain?` | Sections                              |
| `N artikel`                                             | Topic meta                            |
| `Tidak ada hasil`                                       | Empty                                 |
| `Hubungi Customer Support` / `Kirim Email`              | Contact rows                          |
| Seluruh judul/subtitle topik + isi FAQ/artikel          | Content catalog (`HelpContent.swift`) |


---



## 28. Artikel Topik Bantuan

**File:** `Features/More/HelpTopicArticlesView.swift`


| String                                             | Elemen UI |
| -------------------------------------------------- | --------- |
| `Tidak ada artikel` + message                      | Empty     |
| `N artikel tersedia` / `Panduan lengkap seputar …` | Summary   |
| `Cari artikel...`                                  | Search    |
| `N menit baca`                                     | Meta      |
| Footer CTA ke email support                        | Footer    |


---



## 29. Hubungi Support / Kirim Email / Chat Support

**File:** `Features/More/HelpContactViews.swift` (+ `HelpContent.swift`, `Models/Message.swift`)


| String                                                                                       | Elemen UI           |
| -------------------------------------------------------------------------------------------- | ------------------- |
| `Bantuan Akun` / `Bantuan Budget` / `Kendala Teknis` / `Permintaan Data` / `Pertanyaan Umum` | Topic enum          |
| `Hubungi Customer Support` / `Tim kami siap membantu Anda`                                   | Header              |
| `Topik Pertanyaan` / `Pesan Anda`                                                            | Form sections       |
| `Pesan Terkirim` / `Lihat Percakapan` + body                                                 | Success alert       |
| Chat intro copy                                                                              | Intro               |
| `Lanjutkan percakapan dengan support`                                                        | Fallback preview    |
| Message placeholder + tips + `Kirim Pesan`                                                   | Compose             |
| `Kirim Email` / `Subjek Email` / `Isi Pesan` / `Email Disalin` / `Buka Aplikasi Email`       | Email screen        |
| `Senin - Jumat` dll.                                                                         | Jam operasional     |
| `Akun & Login` / `Budget & Pembayaran` dll.                                                  | Support topic chips |


---



## 30. About Wedding App

**Files:** `AboutWeddingAppView.swift`, `AboutContent.swift`


| String                                                                          | Elemen UI                      |
| ------------------------------------------------------------------------------- | ------------------------------ |
| `About Wedding App` / `Kenali lebih dekat tentang aplikasi ini`                 | Header                         |
| `Wedding App` / `Versi X (Y)`                                                   | Brand / version                |
| `Tentang Aplikasi` / `Informasi` / `Ikuti Kami`                                 | Sections                       |
| `Pengembang` / `Website` / `Email` / `Kebijakan Privasi` / `Syarat & Ketentuan` | Info rows                      |
| `© … Wedding App` / `All rights reserved.`                                      | Footer                         |
| Mission / goal / feature blurbs + social names                                  | Content (`AboutContent.swift`) |


---



## 31. Kebijakan Privasi / Syarat & Ketentuan

**Files:** `PrivacyPolicyView.swift`, `TermsOfServiceView.swift` + `*Content.swift`


| Catatan                                                                                                                                                                                            |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| UI chrome data-driven. **Seluruh isi legal (ID + EN)** hardcode di content structs — belum lewat `L10n`. Boleh dianggap konten bilingual terpisah, atau dimigrasikan jika ingin satu sistem lokal. |


---



## Halaman sudah lokal (tidak ada hardcode berarti)


| Halaman            | File                                                             |
| ------------------ | ---------------------------------------------------------------- |
| Edit Profile       | `EditProfileView.swift`                                          |
| Couple             | `CoupleView.swift`                                               |
| Change Password    | `ChangePasswordView.swift`                                       |
| Delete Account     | `DeleteAccountView.swift` *(kecuali token konfirmasi* `HAPUS`*)* |
| Active Sessions    | `ActiveSessionsView.swift`                                       |
| Reminders          | `RemindersPreferencesView.swift`                                 |
| Language           | `LanguageSettingsView.swift`                                     |
| Privacy & Security | `PrivacySecurityView.swift`                                      |
| Root shell         | `RootView.swift` *(tidak ada copy)*                              |


---



## Prioritas migrasi (volume tertinggi)

1. ~~**Budget family**~~ — DONE (12 Jul 2026) — lihat `hardcode/budget.md` §8
2. ~~**Login + Lupa Password**~~ — DONE (12 Jul 2026) — lihat `hardcode/auth.md`
3. **Vendor** — filter, sort, CTA, detail
4. **Inspirasi** — filter sheet + empty states
5. **Checklist Detail** — seluruh detail/edit
6. **Help / Contact / About / HelpContent** — katalog konten besar
7. **Edit Detail Pernikahan** — form lengkap
8. **Events** — seluruh fitur

---

*Dihasilkan dari scan read-only* `ios-app/WeddingApp/Sources`*. Nomor baris bisa bergeser seiring edit.*