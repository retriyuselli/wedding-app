# Halaman Budget (iOS) — Analisis Data, Perhitungan & Hardcode

Dokumen ini fokus pada tab **Budget** di iOS (`ios-app/WeddingApp/Sources/Features/Budget/`).

Terakhir dicek: 12 Juli 2026.  
Update: ditambah **analisa migrasi L10n** (Prioritas #1).

---

## 1. Arsitektur Halaman

```
BudgetView (utama)
├── API load:
│   ├── wedding-budget
│   ├── wedding-budget/summary          ← metrik kartu utama
│   ├── wedding-payment-schedules
│   ├── wedding-budget-category-allocations
│   └── wedding-incoming-payments
├── BudgetCategoriesStore: budget-payment-categories (sekali per session, termasuk icon + meta defaults)
├── Turunan navigasi:
│   ├── EditTotalBudgetSheet          → PUT wedding-budget
│   ├── AddExpenseView                → POST/PUT wedding-payment-schedules
│   ├── BudgetCategoriesView          → alokasi kategori
│   ├── BudgetCategoryDetailView      → daftar expense per kategori
│   ├── BudgetSummaryDetailView       → ringkasan lengkap
│   ├── IncomingPaymentsView          → uang masuk
│   └── BudgetReportShareView         → laporan teks (share sheet)
└── Perhitungan kartu utama: server (`wedding-budget/summary`) + fallback client jika gagal
```

**Default aplikasi:** `config/wedding.php` → API `meta` di `budget-payment-categories` → `BudgetCategoriesStore.defaults` (di-load saat app start di `RootView`).

**Model pemilik (end user):** Setiap user hanya mengakses data miliknya (`user_id`). Di iOS, pemilik aplikasi melakukan CRUD penuh untuk pengeluaran dan uang masuk.

| Entitas | Create | Read | Update | Delete | Layar iOS |
|---------|--------|------|--------|--------|-----------|
| Pengeluaran (`wedding-payment-schedules`) | ✅ POST | ✅ GET | ✅ PUT | ✅ DELETE | `AddExpenseView`, swipe di list kategori |
| Uang masuk (`wedding-incoming-payments`) | ✅ POST | ✅ GET | ✅ PUT (+ status) | ✅ DELETE | `AddIncomingPaymentView`, `IncomingPaymentsView` |
| Total anggaran (`wedding-budget`) | auto | ✅ GET | ✅ PUT | — | `EditTotalBudgetSheet` |
| Alokasi kategori | ✅ POST | ✅ GET | ✅ PUT | ✅ DELETE | `CategoryAllocationFlows` |

---

## 2. Mapping Model ↔ API ↔ Tampilan

### 2.1 WeddingBudget

| Field API | Model iOS | Dipakai di UI Budget? |
|-----------|-----------|----------------------|
| `id` | `WeddingBudget.id` | Tidak tampil (internal) |
| `total_budget` | `totalBudget` | **Ya** — kartu Total Anggaran, semua % |
| `currency` | `currency` | Hanya saat simpan (`EditTotalBudgetSheet`), tidak ditampilkan |
| `notes` | `notes` | Hanya di sheet edit budget |
| `created_at`, `updated_at` | — | Tidak didecode |

**Endpoint:** `GET/PUT /api/v1/wedding-budget`

Jika user belum punya record budget → API bisa mengembalikan `data: null` → iOS fallback:
`WeddingBudget(id: nil, totalBudget: 0, currency: "IDR", notes: "")`.

### 2.2 WeddingBudgetSummary

| Field API | Dipakai di UI |
|-----------|---------------|
| `total_budget`, `spent`, `commitment`, `remaining` | Kartu utama, stats row, donut |
| `*_percent` | Label persentase |
| `planned_allocation_total`, `plan_coverage_percent` | Caption "Alokasi X% dari rencana" |
| `incoming_*` | Kartu Uang Masuk |

**Endpoint:** `GET /api/v1/wedding-budget/summary` (auth)  
**Backend:** `WeddingBudgetSummaryCalculator`

### 2.3 PaymentSchedule (expense)

| Field API | Model iOS | Dipakai di UI Budget? |
|-----------|-----------|----------------------|
| `title`, `amount`, `category`, `status` | ✅ | Form, list, perhitungan kategori |
| `vendor_name` | `vendorName` | List + **form Tambah/Edit Expense** |
| `wedding_event_id` | `weddingEventId` | **Picker acara opsional** di form |
| `customer_payment_method_id` | `customerPaymentMethodId` | Form expense |
| `proof_url`, `notes`, `due_date`, `paid_at` | ✅ | Form & list |
| `sort_order` | `sortOrder` | Urutan list: **`sort_order` → `due_date`** |
| `category_label`, `status_label` | ✅ | Label tampilan |

**Endpoint:** `GET/POST/PUT/DELETE /api/v1/wedding-payment-schedules`, `PATCH …/mark-paid`

**Status:**
- `paid` → **Terpakai**
- `pending` / `overdue` → **Komitmen**

### 2.4 BudgetCategoryAllocation

**Endpoint:** `GET/POST/PUT/DELETE /api/v1/wedding-budget-category-allocations`

### 2.5 BudgetPaymentCategory

| Field API | Keterangan |
|-----------|------------|
| `key`, `label`, `icon` | Dari `WeddingPaymentSchedule::$categoryOptions` + `$categoryIcons` |
| `meta` | Default budget (`default_currency`, `default_expense_category`, dll.) |

**Endpoint:** `GET /api/v1/budget-payment-categories` (public)

### 2.6 IncomingPayment

**Endpoint:** `GET/POST/PUT/DELETE /api/v1/wedding-incoming-payments`

Uang masuk **tidak mempengaruhi** sisa anggaran pengeluaran (dijelaskan di kartu UI). Status (`menunggu` / `confirmed` / `rejected`) diatur pemilik aplikasi lewat form iOS.

### 2.7 CustomerPaymentMethod

Hanya di **AddExpenseView**. **Endpoint:** `GET /api/v1/customer-payment-methods`

---

## 3. Model vs Tampilan (yang masih minim)

| Field / fitur | Keterangan |
|---------------|------------|
| `currency` | Disimpan ke API, tidak ditampilkan di halaman budget |
| `budget.notes` | Hanya di sheet "Atur Budget" |
| Uang masuk → saldo anggaran | Sengaja terpisah (bukan bug) |

**Ringkasan kategori:**
- `BudgetView` → `BudgetCategory.build()` — hanya kategori yang punya expense
- `BudgetCategoriesView` → `BudgetCategory.buildAll()` — semua kategori master API

---

## 4. Logika Perhitungan

### 4.1 Kartu utama (prioritas: API summary)

```
GET wedding-budget/summary → WeddingBudgetSummary
  spent, commitment, remaining, total_budget, *_percent
  plan_coverage_percent → caption kartu total
```

Fallback client (`BudgetSummaryMetrics.make`) jika summary gagal load.

### 4.2 Per kategori (tetap client-side dari schedules)

```
spent      = Σ amount WHERE status == "paid"
commitment = Σ amount WHERE status != "paid"
plannedAllocation = allocated_amount dari alokasi kategori
```

**File:** `BudgetCategory.make()` di `BudgetCategory.swift`

### 4.3 Contoh (total budget Rp 292jt, terpakai Rp 109jt)

```
percent(spent) = round(109.000.000 / 292.000.000 × 100) = 37%
remaining      = max(292M - 109M - komitmen, 0)
```

### 4.4 Uang masuk

```
totalAll, totalConfirmed, pendingCount — dihitung dari daftar wedding-incoming-payments
recentPayments = prefix(2)  ← hardcode limit tampilan
```

**Kartu utama:** metrik uang masuk dihitung dari array `incomingPayments` (bukan `summary.incoming_*`) agar selaras dengan daftar transaksi. Summary API dipakai hanya sebagai fallback jika daftar belum ter-load.

---

## 5. Hardcode yang Masih Ada

### 5.1 Label status (client-side)

| Lokasi | Hardcode |
|--------|----------|
| `PaymentSchedule.displayStatusLabel` | Override ID: Sudah Bayar / Terlambat / Belum Bayar |
| `IncomingPayment.displayStatusLabel` | Fallback ID jika `status_label` kosong |
| `IncomingPaymentFilter` | Enum filter status |

### 5.2 UI / UX constants

| Lokasi | Nilai | Catatan |
|--------|-------|---------|
| `AddExpenseView` | `notesLimit = 200` | Selaras backend `max:200` |
| `AddExpenseView` | `maxProofFileSize = 1 MB` | Selaras backend `max:1024` KB |
| `BudgetView` | `recentIncomingPayments.prefix(2)` | Jumlah item recent |
| `CurrencyFormatter` | Locale `id_ID`, prefix `Rp` | Format tampilan |
| Semua view Budget | Copy Bahasa Indonesia | Bukan dari API |
| `BudgetSummaryMetrics.reportText` | Template laporan teks | Struktur laporan hardcode |

---

## 6. Checklist — Sumber Nilai di Kartu Utama

| Elemen UI | Sumber |
|-----------|--------|
| Total Anggaran | `wedding-budget` / `summary.total_budget` |
| Pengeluaran Terpakai % & nominal | `summary.spent` / `summary.spent_percent` |
| Sisa Anggaran, Komitmen | `summary.remaining`, `summary.commitment` |
| Caption alokasi | `summary.plan_coverage_percent` |
| Uang Masuk | `summary.incoming_*` (terpisah dari sisa) |
| Baris kategori | Group `schedules` + `allocations` (client) |

---

## 7. File Referensi

**iOS:** `BudgetView.swift`, `BudgetComponents.swift`, `BudgetCategory.swift`, `BudgetDefaults.swift`, `WeddingBudgetSummary.swift`, `PaymentSchedule.swift`, `IncomingPayment.swift`, `BudgetPaymentCategory.swift`, `BudgetCategoriesStore.swift`, `AddExpenseView.swift`, `BudgetPaymentFlows.swift`, `IncomingPaymentFlows.swift`, `CategoryAllocationFlows.swift`

**Laravel:** `config/wedding.php`, `WeddingBudgetController`, `WeddingBudgetSummaryCalculator`, `WeddingPaymentScheduleController`, `WeddingBudgetCategoryAllocationController`, `BudgetPaymentCategoryController`, `WeddingIncomingPaymentController`, model `WeddingPaymentSchedule`

---

## 8. Analisa Migrasi L10n (Prioritas #1)

### 8.1 Status saat ini

| Area | Status L10n |
|------|-------------|
| Header tab Budget (`title`, `subtitle`) | ✅ Sudah `L10n.Budget.*` |
| Kartu utama: Total / Terpakai / Komitmen / Sisa | ✅ Sebagian (`totalBudget`, `spent`, `commitment`, `remaining`) |
| Label tab search: Pengeluaran / Kategori / Uang Masuk | ⚠️ Key sudah ada di `L10n`, tapi **UI search masih hardcode** |
| Action "Tambah Expense" + empty state | ⚠️ Key sudah ada, tapi **beberapa tempat masih hardcode literal** |
| Search, ringkasan detail, kategori, alokasi | ❌ Hardcode |
| Add/Edit Expense + bukti pembayaran | ❌ Hardcode |
| Atur Budget + laporan share | ❌ Hardcode |
| Uang Masuk (kartu, list, form, status) | ❌ Hardcode |
| Model status labels (`PaymentSchedule`, `IncomingPayment`) | ❌ Hardcode ID |

### 8.2 Key `L10n.Budget` yang sudah ada

File: `L10n.swift` + `id.lproj` / `en.lproj` `Localizable.strings`

| Key | ID | EN | Dipakai di UI? |
|-----|----|----|----------------|
| `budget.title` | Budget | Budget | ✅ `BudgetView` header |
| `budget.subtitle` | Kelola anggaran... | Manage your wedding budget... | ✅ header |
| `budget.total_budget` | Total Anggaran | Total Budget | ✅ kartu / stats |
| `budget.spent` | Terpakai | Spent | ✅ donut / stats |
| `budget.commitment` | Komitmen | Committed | ✅ donut / stats |
| `budget.remaining` | Sisa Anggaran | Remaining | ✅ donut / stats |
| `budget.expenses` | Pengeluaran | Expenses | ❌ belum dipakai di search header |
| `budget.categories` | Kategori | Categories | ❌ belum dipakai di search header |
| `budget.incoming` | Uang Masuk | Incoming | ❌ belum dipakai di kartu/section |
| `budget.add_expense` | Tambah Expense | Add Expense | ❌ action item masih literal |
| `budget.add_expense_sub` | Catat pengeluaran baru | Record a new expense | ❌ masih literal |
| `budget.no_expenses` | Belum ada pengeluaran | No expenses yet | ❌ empty state masih literal |
| `budget.no_expenses_sub` | Tambahkan expense pertama... | Add your first expense... | ❌ masih literal |

**Kesimpulan cepat:** fondasi L10n Budget sudah ada (13 key), tapi hanya ~6 key yang aktif dipakai. Sisanya harus di-wire, dan banyak string baru perlu ditambahkan.

---

### 8.3 Inventaris hardcode per layar

#### A. Budget utama — `BudgetView.swift`

| String hardcode | Elemen UI | Key L10n yang disarankan |
|-----------------|-----------|--------------------------|
| `Ketuk untuk atur total budget` | Caption kartu total (budget = 0) | `budget.tap_to_set_total` |
| `Alokasi \(n)% dari rencana` | Caption kartu total | `budget.allocation_of_plan` (format) |
| `Total rencana pernikahan` | Caption default | `budget.total_plan` |
| `Cari expense, vendor, kategori...` | Search placeholder | `budget.search_placeholder` |
| `Batal` | Cancel search | `common.cancel` *(sudah ada)* |
| `Cari di budget` | Empty search title | `budget.search_empty_title` |
| `Ketik nama expense, vendor, kategori, atau pengirim uang masuk.` | Empty search body | `budget.search_empty_sub` |
| `Tidak ditemukan` | No-results title | `budget.search_not_found` |
| `Tidak ada hasil untuk "..."` | No-results body | `budget.search_no_results` (format) |
| `Pengeluaran` / `Kategori` / `Uang Masuk` | Search section headers | `budget.expenses` / `categories` / `incoming` *(sudah ada)* |
| `Ringkasan Anggaran` | Section title | `budget.summary` |
| `Lihat detail` | Link | `common.see_detail` *(sudah ada)* |
| `Belum ada pengeluaran` + sub | Empty kategori | `budget.no_expenses` / `no_expenses_sub` *(sudah ada)* |
| `Tambah Expense` / `Catat pengeluaran baru` | Action | `budget.add_expense` / `add_expense_sub` *(sudah ada)* |
| `Kategori Budget` / `Kelola kategori anggaran` | Action | `budget.categories_action` / `categories_action_sub` |
| `Laporan Budget` / `Unduh laporan lengkap` | Action | `budget.report` / `report_sub` |

#### B. Components + laporan teks — `BudgetComponents.swift`

| String hardcode | Elemen UI | Key disarankan |
|-----------------|-----------|----------------|
| `Alokasi \(amount)` | Category row | `budget.allocation_amount` (format) |
| `Belum diatur · \(amount) tercatat` | Category row | `budget.not_set_recorded` (format) |
| `\(amount) komitmen` | Category meta | `budget.commitment_amount` (format) |
| `Terpakai` | Breakdown | `budget.spent` *(sudah ada)* |
| `\(n)% dari total anggaran` | Breakdown sub | `budget.percent_of_total` (format) |
| `Alokasi` / `Rencana kategori` | Breakdown | `budget.allocation` / `budget.category_plan` |
| `Komitmen` / `Menunggu bayar` | Breakdown | `budget.commitment` / `budget.awaiting_payment` |
| `Belum ada expense tercatat` | Empty category detail | `budget.no_expense_recorded` |
| Template laporan: `Laporan Budget Pernikahan`, `Total Anggaran:`, `Terpakai:`, `Komitmen:`, `Sisa Anggaran:`, `Uang Masuk:`, `Ringkasan per Kategori:` | Share report | `budget.report_*` |

#### C. Tambah / Edit Expense — `AddExpenseView.swift`

| String hardcode | Elemen UI | Key disarankan |
|-----------------|-----------|----------------|
| `Tambah Expense` / `Edit Expense` | Title | `budget.add_expense` / `budget.edit_expense` |
| `Catat pengeluaran baru Anda` / `Perbarui pengeluaran Anda` | Subtitle | `budget.add_expense_form_sub` / `edit_expense_form_sub` |
| `Pilih kategori expense` | Picker placeholder | `budget.pick_category` |
| `Pilih metode pembayaran` | Picker placeholder | `budget.pick_payment_method` |
| `Tidak terkait acara (opsional)` | Event placeholder | `budget.no_event_optional` |
| `Contoh: DP Venue, Catering, Dekorasi` | Title placeholder | `budget.expense_title_placeholder` |
| `Nama vendor (opsional)` | Vendor placeholder | `budget.vendor_optional` |
| `Masukkan jumlah` | Amount placeholder | `budget.enter_amount` |
| `Tulis catatan tambahan` | Notes placeholder | `budget.notes_placeholder` |
| `Hapus Expense` | Destructive | `budget.delete_expense` |
| `Status Pembayaran` | Section | `budget.payment_status` |
| `Belum Bayar` / `Sudah Bayar` | Toggle | `budget.unpaid` / `budget.paid` |
| Hint paid / overdue / pending | Status helpers | `budget.status_hint_*` |
| `Bukti Pembayaran (Opsional)` | Section | `budget.proof_optional` |
| `Lihat` / `Ganti Bukti` | Actions | `common.see_detail` / `budget.replace_proof` |
| `Maks. 1MB (JPG, PNG, PDF)` | Hint | `budget.proof_max_size` |
| `Ketuk Lihat untuk membuka bukti` | Proof UI | `budget.tap_to_open_proof` |
| `Tambah foto atau upload bukti pembayaran` | Proof empty | `budget.add_proof` |
| `Simpan Perubahan` / `Simpan Expense` | CTA | `common.save` / `budget.save_expense` |
| Alert ukuran file + pesan error | Alerts | `budget.file_too_large` / `budget.proof_read_error` |
| `Bukti Pembayaran` / `Buka Dokumen` / `Tutup` | Proof viewer | `budget.proof` / `budget.open_document` / `common.close` |
| `Pilih Kategori` / `Pilih Tanggal` / `Pilih Acara` / `Metode Pembayaran` | Sheet titles | `budget.pick_*` |
| `Tidak terkait acara` | Event option | `budget.no_event` |
| `Belum ada metode pembayaran` + admin hint | Empty methods | `budget.no_payment_methods` |
| `Selesai` | Done | `common.done` *(sudah ada)* |
| `Gagal memuat bukti` / `Periksa koneksi...` / `Belum ada file...` | Proof errors | `budget.proof_load_error` dll. |

#### D. Ringkasan / Kategori / Atur Budget / Laporan — `BudgetPaymentFlows.swift`

| String hardcode | Elemen UI | Key disarankan |
|-----------------|-----------|----------------|
| `Belum ada pengeluaran` + deskripsi jadwal/expense | Empty states | `budget.no_expenses` + sub baru |
| `Hapus` / `Lunas` | Swipe actions | `common.delete` / `budget.mark_paid` |
| `Ringkasan Anggaran` | Nav title | `budget.summary` |
| `Total Anggaran` / `Terpakai` / `Komitmen` / `Sisa` / `Per Kategori` | Summary | key existing + `budget.per_category` / `budget.remaining_short` |
| `Kategori Budget` | Nav title | `budget.categories_title` |
| `Belum ada kategori` / gagal muat | Empty | `budget.no_categories` / `budget.categories_load_error` |
| `Total Alokasi Kategori` / `dari \(amount)` | Allocation header | `budget.total_category_allocation` / `budget.from_total` |
| `Ketuk + untuk atur alokasi per kategori.` | Helper | `budget.tap_to_allocate` |
| `Dibayar:` / `Jatuh tempo:` | Schedule row | `budget.paid_on` / `budget.due_on` |
| `Atur Budget` / `Tetapkan total rencana anggaran` | Header | `budget.set_budget` / `set_budget_sub` |
| `Masukkan nominal` | Placeholder | `budget.enter_amount` |
| `Ini adalah plafon rencana pengeluaran...` | Helper | `budget.ceiling_hint` |
| `Catatan` / placeholder catatan | Form | `common.notes` / `budget.budget_notes_placeholder` |
| `Rencana Pengeluaran` + penjelasan panjang | Info card | `budget.spending_plan` / `spending_plan_info` |
| `Simpan Budget` | CTA | `budget.save_budget` |
| `Laporan Budget` / `Tutup` | Report sheet | `budget.report` / `common.close` |

#### E. Alokasi kategori — `CategoryAllocationFlows.swift`

| String hardcode | Elemen UI | Key disarankan |
|-----------------|-----------|----------------|
| `Edit Alokasi` / `Atur Alokasi` | Nav title | `budget.edit_allocation` / `set_allocation` |
| `Alokasi Anggaran` / `Nominal alokasi` | Form | `budget.budget_allocation` / `allocation_amount_field` |
| `Catatan` / `Opsional` | Form | `common.notes` / `budget.optional` |
| `Hapus Alokasi` | Destructive | `budget.delete_allocation` |
| `Terpakai … · Komitmen …` | Summary line | `budget.spent_commitment_line` (format) |
| `Ringkasan` / `Tercatat` / `Sisa alokasi` | Summary | `budget.summary_short` / `recorded` / `allocation_remaining` |
| `Simpan Perubahan` / `Simpan Alokasi` | CTA | `common.save` variant / `budget.save_allocation` |

#### F. Uang Masuk — `IncomingPaymentFlows.swift`

| String hardcode | Elemen UI | Key disarankan |
|-----------------|-----------|----------------|
| `Uang Masuk` | Section / nav | `budget.incoming` *(sudah ada)* |
| `Total tercatat` | Summary | `budget.incoming_total_recorded` |
| `Tidak mengurangi sisa anggaran pengeluaran` | Helper | `budget.incoming_not_affect_remaining` |
| `Dikonfirmasi` / `N menunggu` | Stats | `budget.confirmed` / `budget.pending_count` (format) |
| `Belum ada uang masuk tercatat` | Empty | `budget.no_incoming` |
| `Lihat semua` | Link | `common.see_all` *(sudah ada)* |
| `Belum ada data` + empty per filter | Empty states | `budget.incoming_empty_*` |
| `Total` / `Dikonfirmasi` | Metrics | `budget.total` / `budget.confirmed` |
| `Tambah Uang Masuk` / `Edit Uang Masuk` | CTA / titles | `budget.add_incoming` / `edit_incoming` |
| `Pengirim` / `Nominal` / `Tanggal Transfer` / `Detail Opsional` / `Status Penerimaan` | Form sections | `budget.sender` / `amount` / `transfer_date` / `optional_detail` / `receive_status` |
| `Nama pengirim` / `Jumlah uang masuk` / `Nama bank` / `Catatan` | Placeholders | `budget.sender_placeholder` dll. |
| `Menunggu` / `Dikonfirmasi` / `Ditolak` | Status picker | `budget.status_pending` / `confirmed` / `rejected` |
| Status helper copy (3 teks) | Hints | `budget.incoming_status_hint_*` |
| `Simpan Perubahan` / `Simpan Uang Masuk` / `Hapus` | Actions | `budget.save_incoming` / `common.delete` |
| `Ref: …` | Reference line | `budget.ref` (format) |

#### G. Model labels (tampil di UI)

| File | String | Key disarankan |
|------|--------|----------------|
| `PaymentSchedule.displayStatusLabel` | `Sudah Bayar` / `Terlambat` / `Belum Bayar` | `budget.paid` / `overdue` / `unpaid` |
| `IncomingPayment.displayStatusLabel` | `Dikonfirmasi` / `Ditolak` / `Menunggu` | sama dengan status incoming |
| `IncomingPayment` fallback nama | `Tanpa nama` | `budget.unnamed_sender` |
| `IncomingPaymentFilter` | `Semua` / `Menunggu` / `Dikonfirmasi` / `Ditolak` | `common.all` + status keys |

---

### 8.4 Yang **bukan** target L10n (tetap hardcode teknis)

Sesuai arsitektur §5.2 — **jangan** dimasukkan ke Localizable.strings:

| Item | Alasan |
|------|--------|
| `notesLimit = 200` | Validasi API |
| `maxProofFileSize = 1 MB` | Validasi API |
| `recentIncomingPayments.prefix(2)` | UX limit |
| Locale `id_ID` di `CurrencyFormatter` | Format mata uang |
| Prefix `Rp` / `jt` / `rb` / `MB` / `KB` | Format angka (bisa dipertimbangkan terpisah nanti) |
| API paths, status codes (`paid`, `pending`, `overdue`, `menunggu`, `confirmed`, `rejected`) | Contract backend |
| SF Symbol names | Sistem |

---

### 8.5 Rencana migrasi (urut kerja)

1. **Wire key yang sudah ada** — ganti literal yang duplikat dengan `L10n.Budget.expenses/categories/incoming/addExpense/...` di `BudgetView`.
2. **Model status labels** — pindahkan `displayStatusLabel` ke L10n agar semua list otomatis ikut bahasa.
3. **BudgetView + BudgetComponents** — search, caption, actions, breakdown, report template.
4. **BudgetPaymentFlows** — ringkasan, kategori, atur budget, swipe actions, laporan sheet.
5. **CategoryAllocationFlows** — form alokasi.
6. **AddExpenseView** — form expense + proof sheets (volume terbesar di satu file).
7. **IncomingPaymentFlows** — kartu, list, form uang masuk.

Setiap langkah: tambah key di `L10n.Budget` + `id.lproj` + `en.lproj`, ganti literal di Swift, lalu cek build iOS.

### 8.6 Estimasi volume

| Kelompok | Perkiraan string baru (unik) |
|----------|------------------------------|
| Wire key existing | 0 baru (hanya pakai ulang) |
| BudgetView + Components + report | ~35 |
| PaymentFlows (summary/categories/set/report) | ~30 |
| CategoryAllocation | ~12 |
| AddExpense (+ sheets) | ~45 |
| Incoming (+ model filter/status) | ~35 |
| **Total estimasi** | **~150 key baru** (+ 13 existing) |

---

### 8.7 Catatan implementasi

- Prefer reuse `L10n.Common.*` untuk `Batal`, `Simpan`, `Hapus`, `Tutup`, `Selesai`, `Lihat detail`, `Lihat semua`.
- String dengan interpolasi pakai helper `localized(_:)` ber-argumen seperti pola `L10n.Checklist.tasksCompleted`.
- Label kategori expense dari API (`BudgetPaymentCategory.label`) **tidak** di-hardcode di app — biarkan dari backend (sudah bilingual jika API menyediakannya).
- Setelah migrasi Budget selesai, update checklist di `hardcode/hardcode.md` section Budget (10–15) dan tandai di dokumen ini: **Status migrasi = done**.

**Status migrasi L10n Budget: DONE** (12 Juli 2026)
