# Halaman Budget (iOS) — Analisis Data, Perhitungan & Hardcode

Dokumen ini fokus pada tab **Budget** di iOS (`ios-app/WeddingApp/Sources/Features/Budget/`).

Terakhir dicek: 6 Juli 2026.

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
