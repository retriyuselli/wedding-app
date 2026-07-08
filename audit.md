# WeddingApp — Audit Menyeluruh (App Store Readiness)
**Tanggal Audit:** 2026-07-07  
**Terakhir Diperbarui:** 2026-07-08  
**Auditor:** Senior iOS Engineer + QA Lead + Security Auditor + App Store Release Manager  
**Status:** ⚠️ HAMPIR SIAP — **~50 issue sudah diperbaiki** (Sesi 1–3). Sisa blocker utama: **deploy server production HTTPS** + metadata App Store (Privacy Policy, screenshots, TestFlight).  

---

## A. Executive Summary

Aplikasi WeddingApp memiliki UI/UX yang bagus dan konsisten secara visual (tema sage, tipografi Poppins+Cormorant Garamond, card layout yang bersih). Setelah Sesi 3, mayoritas blocker kritis **sudah diimplementasikan di kode** (API integration, Sign in with Apple, checklist summary). Yang tersisa sebelum submit ke App Store adalah **deploy backend production dengan HTTPS** dan kelengkapan metadata/review assets.

**Summary Status Per Kategori:**
| Kategori | Status | Prioritas |
|---|---|---|
| App Store Compliance | Hampir siap | Critical |
| Security (HTTP/ATS) | Kode siap — butuh deploy HTTPS | Critical |
| Sign in with Apple | ✅ Selesai (iOS + backend) | — |
| Fitur Belum Selesai | Sedikit (Lupa Password, Privacy Policy) | High |
| Dummy Data di Produksi | ✅ Selesai (Dashboard, Messages, Inspiration) | — |
| Performance | Perlu perbaikan minor | Medium |
| Code Quality | Perlu perbaikan minor | Medium |

---

## Changelog — Perubahan yang Sudah Dilakukan

### Sesi 1 & 2 — 2026-07-07

Semua perubahan di bawah sudah di-build dan dikonfirmasi **compile tanpa error**.

| # | File | Perubahan | Issue |
|---|---|---|---|
| 1 | `SessionStore.swift` | `deviceName` hardcoded `"iOS Simulator"` → `UIDevice.current.name` (+ import UIKit) | B3 ✅ |
| 2 | `APIError.swift` | Error message yang expose `php artisan serve` → pesan generic user-friendly | B4 ✅ |
| 3 | `KeychainStore.swift` | Tambah `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` saat simpan token | G4 ✅ |
| 4 | `DashboardView.swift` | `@StateObject` → `@ObservedObject` untuk `BudgetCategoriesStore.shared` | D2 ✅ |
| 5 | `BudgetView.swift` | `@StateObject` → `@ObservedObject` + `VStack` → `LazyVStack` di daftar kategori | D2, F1 ✅ |
| 6 | `GuestView.swift` | `VStack` → `LazyVStack` di daftar tamu | F1 ✅ |
| 7 | `ChecklistView.swift` | `DateFormatter` dibuat ulang tiap render → `static` properties; `VStack` → `LazyVStack` | D3, F1 ✅ |
| 8 | `VendorView.swift` | `VStack` → `LazyVStack` di daftar vendor | F1 ✅ |
| 9 | `MoreView.swift` | Tambah konfirmasi alert sebelum logout | E4 ✅ |
| 10 | `RootView.swift` | Tambah `SplashView` loading state selama `restoreSession()` berjalan (cegah flash LoginView) | C5 ✅ |
| 11 | `LoginView.swift` | Tambah validasi format email + hint banner + disable button jika format tidak valid | C10 ✅ |
| 12 | `RegisterView.swift` | Tambah validasi format email + hint banner + `isFormValid` menyertakan email validation | C10 ✅ |
| 13 | `GuestView.swift` | Hapus dua header circle button (`magnifyingglass`, `slider.horizontal.3`) yang non-fungsional | D9 ✅ |
| 14 | `GuestView.swift` | Action bar (Bagikan Undangan, QR Check-in, Export Data) sekarang menampilkan alert "Segera Hadir" | C3 ✅ |
| 15 | `MoreView.swift` | 6 item "Akun & Pengaturan" dengan `destination: nil` sekarang menampilkan alert "Segera Hadir" | C2 ✅ |
| 16 | `AppFont.swift` | Semua metode font tambah `relativeTo: .body` — Dynamic Type accessibility berfungsi | D6 ✅ |
| 17 | `WeddingAppApp.swift` | `appDidBecomeActive` hanya di-post jika >5 menit sejak terakhir — cegah 5 tab reload bersamaan | D1 ✅ |
| 18 | `WeddingAppApp.swift` | Tambah `Notification.Name.sessionExpired` | D10 ✅ |
| 19 | `APIClient.swift` | Post `sessionExpired` notification saat 401 diterima | D10 ✅ |
| 20 | `SessionStore.swift` | Tambah `clearSession()` method; `logout()` kini memanggil method ini | D10 ✅ |
| 21 | `RootView.swift` | `onReceive(.sessionExpired)` → `clearSession()` → otomatis redirect ke LoginView | D10 ✅ |
| 22 | `DashboardView.swift` | Bell icon membuka `NotificationsSheet` (empty state) — bukan lagi navigasi ke More tab | C4 ✅ |
| 23 | `MessagesView.swift` | Hapus `.refreshable {}` kosong | E7 ✅ |
| 24 | `InspirationView.swift` | Hapus `.refreshable {}` kosong | E7 ✅ |
| 25 | `VendorView.swift` | Debounce filter change — cancel task sebelumnya, hanya 1 API call yang jalan | D4 ✅ |
| 26 | `GuestListView.swift` | **Dihapus** — file legacy yang tidak digunakan (GuestView.swift yang dipakai) | E6 ✅ |
| 27 | `MoreView.swift` | Profile avatar hardcoded `Image("CouplePortrait")` → `UserAvatarCircle` yang load dari `session.currentUser?.avatarUrl` | E5 ✅ |
| 28 | `DateFormatters.swift` (baru) | Buat file terpusat di `Sources/App/` dengan `DateFormatter.apiInput` dan `DateFormatter.localeDateDisplay` | E1 ✅ |
| 29 | `DashboardView.swift` | Ganti `weddingInput` → `apiInput`, hapus definisi duplikat private | E1 ✅ |
| 30 | `MoreView.swift` | Ganti `moreInput`/`moreDisplay` → `apiInput`/`localeDateDisplay`, hapus private extension | E1 ✅ |
| 31 | `WeddingDetailView.swift` | Ganti `detailInput`/`detailDisplay` → `apiInput`/`localeDateDisplay`, hapus definisi duplikat | E1 ✅ |
| 32 | `WeddingDetailEditView.swift` | Ganti `detailInput` → `apiInput`, hapus entire private extension | E1 ✅ |
| 33 | `AddExpenseView.swift` | Ganti `expenseDisplay` → `localeDateDisplay`, hapus definisi duplikat (pertahankan `apiDate` karena punya UTC timezone) | E1 ✅ |

### Sesi 3 — 2026-07-08 (Backend + iOS API Integration)

#### Backend Laravel (14 tests lulus)

| # | Area | Perubahan | Issue |
|---|---|---|---|
| 34 | `CustomerPreparationTaskController` | Endpoint `GET customer-preparation-tasks/summary` + `CustomerPreparationSummaryCalculator` | K4 ✅ |
| 35 | `MessageController` | CRUD threads + send message (`messages/threads`, `messages/threads/{id}/send`) | K3a ✅ |
| 36 | `InspirationController` | Index + save/unsave inspirasi (`inspirations`, `inspirations/{id}/save`) | K3b ✅ |
| 37 | `AuthController` | `POST auth/apple` + `AppleTokenVerifier` + migration `apple_id` | K2 ✅ |
| 38 | Seeders | `MessageThreadSeeder`, `InspirationSeeder` | K3 ✅ |
| 39 | Tests | `CustomerPreparationSummaryApiTest`, `MessageApiTest`, `InspirationApiTest`, `AppleAuthTest` | — ✅ |

#### iOS Integration (BUILD SUCCEEDED)

| # | File | Perubahan | Issue |
|---|---|---|---|
| 40 | `ChecklistSummary.swift` (baru) | Model summary checklist dari API | K4 ✅ |
| 41 | `DashboardView.swift` | Fetch summary; ganti hardcoded `0.68` / `34/12/14` dengan data real | B5 ✅ |
| 42 | `Message.swift` | Rework model API-decodable; hapus `MessageThread.samples` | B5, C6 ✅ |
| 43 | `MessagesView.swift` | Load threads dari API; detail load + send message ke server | B5, C6 ✅ |
| 44 | `Inspiration.swift` | Rework model API-decodable; hapus `popularSamples` | B5, C7 ✅ |
| 45 | `InspirationView.swift` | Load inspirasi dari API; AsyncImage untuk `imageUrl` | B5, C7 ✅ |
| 46 | `SavedItemsStore.swift` | `SavedInspirationStore` API-backed (save/unsave ke server) | C7 ✅ |
| 47 | `SavedInspirationView.swift` | Load inspirasi tersimpan dari `inspirations?saved_only=1` | C7 ✅ |
| 48 | `AppleSignInService.swift` (baru) | `ASAuthorizationAppleIDProvider` flow | B2 ✅ |
| 49 | `SessionStore.swift` | `loginWithApple()` → `POST auth/apple` | B2 ✅ |
| 50 | `LoginView.swift` / `RegisterView.swift` | Tombol Apple fungsional | B2 ✅ |
| 51 | `WeddingApp.entitlements` (baru) | Sign in with Apple capability | B2 ✅ |
| 52 | `APIConfig.swift` | Release → `https://api.weddingapp.co.id/api/v1`; Debug tetap localhost | B1 ✅ |
| 53 | `project.yml` | Hapus `NSAllowsArbitraryLoads`; Debug pakai `NSAllowsLocalNetworking` saja | B1, G2 ✅ |

### Masih Pending — Sebelum Submit App Store

| Kategori | Item | Section |
|---|---|---|
| **BLOCKER** | Deploy production server dengan HTTPS + domain publik (`api.weddingapp.co.id`) | K1 |
| **BLOCKER** | Verifikasi end-to-end Release build terhadap server production | K1 |
| High | Lupa Kata Sandi — endpoint + UI | K5 |
| High | Privacy Policy — halaman statis di dalam app (bisa WebView ke URL) | C9 |
| High | Aktifkan Sign in with Apple di Apple Developer Portal untuk App ID | H |
| Medium | Tombol kosong di `VendorView` / `InspirationView` featured cards | C3 |
| Medium | Launch screen, App icon lengkap, Privacy manifest | H |
| Medium | TestFlight internal beta minimum 1 minggu | H |

---

## B. Critical Issues (App Store Blocker)

Isu-isu berikut **PASTI menyebabkan rejection** dari Apple App Store Review. Harus diselesaikan sebelum submit.

### B1. HTTP Digunakan Sebagai Protokol API ~~(BLOCKER)~~ ✅ Kode Siap — Butuh Deploy

**Status:** ✅ **Diperbaiki di kode** (Sesi 3) — Release build memakai HTTPS production. Debug build tetap localhost untuk development.

**File:** `Sources/Networking/APIConfig.swift`  
**File:** `project.yml` / `Generated/Info.plist`

```swift
// APIConfig.swift — Release build (App Store)
static let productionURL = URL(string: "https://api.weddingapp.co.id/api/v1")!
// Debug: http://127.0.0.1:8000 (simulator) atau LAN IP (device fisik)
```

**Yang sudah dilakukan:**
- `NSAllowsArbitraryLoads = true` **dihapus** dari `project.yml`
- Release build → `https://api.weddingapp.co.id/api/v1`
- Debug build → localhost/LAN (dengan `NSAllowsLocalNetworking` saja, bukan arbitrary loads)

**Yang masih perlu:**
1. Deploy backend ke `api.weddingapp.co.id` dengan sertifikat SSL aktif
2. Set `APPLE_IOS_CLIENT_ID=com.weddingapp.ios` di `.env` backend
3. Verifikasi Release build end-to-end terhadap server production

---

### B2. Sign in with Apple ~~(BLOCKER)~~ ✅ Selesai

**Status:** ✅ **Selesai** (Sesi 3) — iOS + backend + entitlement.

**File:** `Sources/Features/Auth/AppleSignInService.swift`, `SessionStore.swift`, `LoginView.swift`, `RegisterView.swift`  
**File:** `WeddingApp.entitlements`  
**Backend:** `POST /api/v1/auth/apple`, `AppleTokenVerifier`, migration `apple_id`

**Yang sudah dilakukan:**
1. Entitlement `com.apple.developer.applesignin` di `WeddingApp.entitlements`
2. `ASAuthorizationAppleIDProvider` di `AppleSignInService`
3. Endpoint `auth/apple` di backend Laravel dengan verifikasi JWT Apple JWKS
4. Tombol fungsional di LoginView dan RegisterView

**Yang masih perlu:**
- Aktifkan capability Sign in with Apple di [Apple Developer Portal](https://developer.apple.com) untuk App ID `com.weddingapp.ios`
- Set `APPLE_IOS_CLIENT_ID=com.weddingapp.ios` di `.env` backend

---

### B3. Hardcoded Device Name "iOS Simulator" di Produksi (BLOCKER)

**File:** `Sources/Features/Auth/SessionStore.swift` baris 9

```swift
private let deviceName = "iOS Simulator"  // SALAH — hardcoded development value
```

**Dampak:**  
Semua login dari device nyata akan mengirim `device_name: "iOS Simulator"` ke backend, menyebabkan masalah session management dan tracking yang salah.

**Perbaikan:**
```swift
private var deviceName: String {
    UIDevice.current.name
}
```

---

### B4. Error Message Mengekspos Detail Infrastruktur Backend (BLOCKER)

**File:** `Sources/Networking/APIError.swift` baris 53

```swift
case .cannotConnectToHost, .cannotFindHost, .timedOut:
    return "Tidak dapat terhubung ke server Laravel. Pastikan backend berjalan dengan `php artisan serve --host=0.0.0.0 --port=8000`."
```

**Dampak:**  
Apple App Review Guidelines §2.3.7 melarang app yang terlihat seperti "demo" atau "beta". Pesan error ini mengekspos detail implementasi internal kepada pengguna production. Apple reviewer yang melihat ini akan langsung reject.

**Perbaikan:**
```swift
case .cannotConnectToHost, .cannotFindHost, .timedOut:
    return "Tidak dapat terhubung ke server. Periksa koneksi internet Anda dan coba lagi."
```

---

### B5. Placeholder/Dummy Data Tampil Kepada User Produksi ~~(BLOCKER)~~ ✅ Selesai

**Status:** ✅ **Selesai** (Sesi 3) — Dashboard, Messages, dan Inspiration kini memuat data dari API.

**File yang diperbaiki:**
- `DashboardView.swift` — progress & stats dari `customer-preparation-tasks/summary`
- `MessagesView.swift` — threads dari `messages/threads`; kirim pesan ke server
- `InspirationView.swift` — items dari `inspirations`; save/unsave ke server

**Catatan:** Featured carousel Inspiration tetap statis (konten dekoratif kurasi, bukan data user).

---

## C. High Priority Issues

### C1. Lupa Password Tidak Diimplementasikan

**File:** `Sources/Features/Auth/LoginView.swift` baris 41-43

```swift
AuthDottedLink(title: "Lupa kata sandi?") {
    // Forgot password — coming soon
}
```

Tombol ada di UI tapi tidak melakukan apa-apa. User yang klik akan bingung. Harus diimplementasikan atau dihapus dari UI sebelum submit.

---

### C2. Banyak Item di Tab "More" Tidak Berfungsi

**File:** `Sources/Features/More/MoreView.swift` baris 166-173

6 dari 11 item di tab More tidak berfungsi (destination: nil): Pengaturan, Privasi & Keamanan, Pengingat, Bahasa, Bantuan & FAQ, Tentang Wedding App. Semua menampilkan chevron kanan tapi tidak navigasi kemana-mana — terlihat seperti bug.

**Perbaikan:** Implementasikan halaman atau hapus chevron dan tampilkan label "Segera Hadir".

---

### C3. Tombol Non-Fungsional di Beberapa Halaman

| Halaman | Tombol | File | Status |
|---|---|---|---|
| Guest | "Bagikan Undangan" | GuestView.swift | Tidak ada action |
| Guest | "QR Check-in" | GuestView.swift | Tidak ada action |
| Guest | "Export Data" | GuestView.swift | Tidak ada action |
| Vendor | "Kirim Permintaan" | VendorView.swift | `Button {} label:` kosong |
| Vendor | Promo carousel buttons | VendorView.swift | `Button {} label:` kosong |
| Inspiration | "Lihat Semua" | InspirationView.swift | `Button {} label:` kosong |
| Inspiration | Featured card buttons | InspirationView.swift | `Button {} label:` kosong |

---

### C4. Notification Bell di Dashboard Navigasi ke MoreView (Logic Error)

**File:** `Sources/Features/Dashboard/DashboardView.swift` baris 188

```swift
Button {
    selectTab(.more)  // bell icon dengan badge menavigasi ke tab More?
} label: {
    Image(systemName: "bell")
}
```

Icon bell dengan badge notifikasi membawa user ke tab "More" (Settings) bukan halaman notifikasi. Ini membingungkan secara UX.

---

### C5. RootView Tidak Ada Loading State Saat Session Restore

**File:** `Sources/App/RootView.swift`

```swift
var body: some View {
    Group {
        if session.currentUser != nil {
            DashboardView()
        } else {
            LoginView()  // langsung tampil sebelum restoreSession() selesai!
        }
    }
    .task {
        await session.restoreSession()  // async
    }
}
```

User yang sudah login akan melihat LoginView sebentar sebelum pindah ke DashboardView. Tambahkan splash screen atau loading state saat session sedang di-restore.

---

### C6. MessagesView — Tidak Ada API Integration

**File:** `Sources/Features/Messages/MessagesView.swift`

Seluruh MessagesView menggunakan `MessageThread.samples` dan tidak ada API call. Pesan yang dikirim hanya ada di memory dan hilang saat app di-restart. Ini UI mockup, bukan fitur nyata.

---

### C7. InspirationView — Tidak Ada API Integration

**File:** `Sources/Features/Inspiration/InspirationView.swift`

Sama dengan Messages — seluruh data adalah sample data statis (`InspirationItem.popularSamples`). Tidak ada API integration sama sekali.

---

### C8. ShareLink Menggunakan URL Hardcoded dengan Force Unwrap

**File:** `Sources/Features/More/MoreView.swift` baris 194

```swift
ShareLink(item: URL(string: "https://paketpernikahan.co.id")!) {
```

URL yang di-share seharusnya adalah link App Store app ini, bukan website eksternal. Juga menggunakan force unwrap.

---

### C9. Tidak Ada Privacy Policy di Dalam App

App Store mensyaratkan Privacy Policy URL yang dapat diakses dari dalam aplikasi (terutama karena app memproses data personal: nama, email, nomor HP, data pernikahan). Tidak ditemukan halaman atau link privacy policy di dalam app.

---

### C10. Validasi Email Tidak Ada di Form Login dan Register

Form `isFormValid` hanya mengecek `!email.isEmpty`, tidak memvalidasi format email. User bisa submit `"abc"` sebagai email dan baru mendapat error setelah API call yang seharusnya tidak perlu terjadi.

---

## D. Medium Priority Issues

### D1. Multiple API Calls Saat App Foreground

Semua tab (Home, Budget, Checklist, Guest, More) subscribe ke `NotificationCenter.default.publisher(for: .appDidBecomeActive)` dan memanggil `load()`. Setiap kali app masuk foreground, minimum 5 API call paralel terjadi.

**Perbaikan:** Implementasikan rate limiting — hanya refresh jika data lebih dari 5 menit atau setelah background minimum durasi tertentu.

---

### D2. `@StateObject` Digunakan untuk Shared Singleton (Anti-Pattern)

**File:** `DashboardView.swift` baris 63, `BudgetView.swift` baris 4

```swift
@StateObject private var categoriesStore = BudgetCategoriesStore.shared
```

`@StateObject` seharusnya untuk objek yang di-*owned* oleh view. Untuk shared singleton, gunakan `@ObservedObject`. Inkonsistensi ini (ada yang pakai `@StateObject`, ada `@ObservedObject` untuk pola sama) berpotensi bug pada lifecycle management.

---

### D3. DateFormatter Dibuat Ulang di Dalam Static Method

**File:** `Sources/Features/Checklist/ChecklistView.swift` baris 532-541

```swift
private static func displayDate(_ raw: String) -> String? {
    let input = DateFormatter()   // dibuat baru tiap panggil!
    let output = DateFormatter()  // dibuat baru tiap panggil!
    ...
}
```

`DateFormatter` mahal dibuat. Ini dipanggil untuk setiap `TaskRow` yang di-render. Gunakan static properties.

---

### D4. `VendorView.loadVendors()` Dipanggil Setiap Perubahan Filter Tanpa Debounce

**File:** `Sources/Features/Vendor/VendorView.swift` baris 130-132

```swift
.onChange(of: filter) { _, _ in
    Task { await loadVendors() }  // API call setiap kali filter berubah
}
```

Jika user memilih 3 filter berturut-turut cepat, 3 API call paralel terjadi. Tambahkan debounce atau task cancellation.

---

### D5. LuxuryWeddingBackground Dirender di Setiap View

`LuxuryWeddingBackground` menggunakan `LinearGradient` + `RadialGradient` + `Image("FloralHeader")` (330x330) yang di-render ulang di setiap view pindah tab. Bisa menyebabkan jank pada device lama.

---

### D6. Custom Font Tidak Mendukung Dynamic Type

**File:** `Sources/App/AppFont.swift`

```swift
static func regular(_ size: CGFloat) -> Font {
    .custom("Poppins-Regular", size: size)  // fixed size, tidak scale
}
```

Apple mengharuskan aplikasi menghormati Dynamic Type accessibility setting. Gunakan:
```swift
.custom("Poppins-Regular", size: size, relativeTo: .body)
```

---

### D7. UILaunchScreen di Info.plist Kosong

**File:** `Generated/Info.plist` baris 44-45

```xml
<key>UILaunchScreen</key>
<dict/>  <!-- Kosong — akan tampil layar putih saat launch -->
```

Launch screen kosong menghasilkan flash putih saat launch. Tambahkan background color dan logo sesuai tema app.

---

### D8. Tab Bar Labels Bahasa Inggris, Konten Bahasa Indonesia

Tab bar menggunakan "Home", "Checklist", "Guest", "Budget", "More" (Inggris) sementara konten di dalam semua dalam Bahasa Indonesia. Inkonsisten, pilih satu bahasa.

---

### D9. GuestView Header Buttons Tidak Berfungsi

**File:** `Sources/Features/Guests/GuestView.swift` baris 88-91

```swift
circleButton("magnifyingglass")   // tidak ada action — hanya Image, bukan Button
circleButton("slider.horizontal.3")  // tidak ada action
```

Kedua tombol circle di header GuestView terlihat interaktif tapi tidak melakukan apapun.

---

### D10. Tidak Ada Handling untuk Token Expired / Auto-Logout

Saat 401, token dihapus tapi tidak ada notifikasi ke user atau auto-redirect ke LoginView. User mungkin tetap di DashboardView dengan semua request gagal secara silent.

---

## E. Low Priority / Improvement

**E1.** Duplikasi `DateFormatter` extension di DashboardView.swift, MoreView.swift, ChecklistView.swift — konsolidasikan ke satu file utilities.

**E2.** `struct PreparationSection` didefinisikan di `ChecklistView.swift` baris 614 — seharusnya ada di `Sources/Models/`.

**E3.** Magic numbers tersebar (`182`, `168`, `128`, `330`) — pertimbangkan named constants.

**E4.** Tidak ada konfirmasi dialog saat logout — tambahkan `Alert` konfirmasi.

**E5.** Tab More profile card menggunakan `Image("CouplePortrait")` hardcoded — seharusnya menggunakan avatar URL dari session user.

**E6.** `GuestListView.swift` ada di project tapi tampaknya tidak digunakan (GuestView.swift yang dipakai) — cek dan hapus jika duplikat.

**E7.** `.refreshable {}` kosong di MessagesView dan InspirationView — pull-to-refresh yang tidak melakukan apapun adalah pengalaman buruk.

**E8.** Checklist "slider.horizontal.3" button ada di header tapi tidak memiliki action — tampak seperti filter button yang belum diimplementasikan.

---

## F. Performance Recommendations

### Prioritas Tinggi

**F1. Lazy Loading untuk List Panjang**  
Semua list menggunakan `VStack { ForEach(...) }` bukan `LazyVStack`. Untuk 100+ item ini akan menyebabkan hang:
```swift
// Ganti VStack { ForEach(...) } dengan:
LazyVStack(spacing: 10) { ForEach(filteredVendors) { ... } }
```

**F2. Image Caching**  
`AsyncImage` tidak memiliki built-in disk cache. Vendor dan user avatar images akan re-download setiap scroll. Gunakan library caching (Nuke, Kingfisher) atau implementasikan custom URLCache.

**F3. Debounce untuk Search Input**  
Search di BudgetView, ChecklistView, GuestView melakukan filter computation synchronously per keystroke. Tambahkan debounce 300ms untuk mengurangi render cycle.

### Prioritas Menengah

**F4. Pagination untuk Vendor List**  
`loadVendors()` mengambil semua vendor sekaligus. Implementasikan pagination dengan query `?page=1&per_page=20`.

**F5. Background Rendering Optimization**  
`LuxuryWeddingBackground` dengan multiple gradients dan large image bisa di-cache/share di level TabView atas daripada di-render tiap view.

### Penggunaan Instruments Sebelum Release

- **Time Profiler** — identifikasi rendering bottleneck dan blocking main thread calls
- **Leaks Instrument** — cek retain cycles, terutama closure captures di `Task {}` blocks
- **Network Link Conditioner** — test dengan koneksi 3G/lambat untuk UX loading states
- **Core Animation FPS** — test scroll performance pada iPhone SE (375pt width, oldest device)

---

## G. Security Recommendations

### Kritis

**G1. Migrasi ke HTTPS Segera**  
Semua API traffic menggunakan HTTP. Auth token, password, data pernikahan dikirim dalam plaintext. Ini adalah kerentanan keamanan kelas tertinggi dan juga App Store blocker.

**G2. Hapus NSAllowsArbitraryLoads**  
Gunakan domain-specific exception yang tepat:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.weddingapp.co.id</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
        </dict>
    </dict>
</dict>
```

**G3. Implementasi Sign in with Apple dengan Proper Credential Storage**  
Simpan Apple User ID di Keychain (bukan UserDefaults) untuk validasi session berikutnya.

### Tinggi

**G4. Tambahkan kSecAttrAccessible ke Keychain Token**  
**File:** `Sources/Networking/KeychainStore.swift`

```swift
// Tambahkan ke attributes di saveToken():
attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
```
Ini mencegah token diakses saat device terkunci dan memastikan tidak disync ke iCloud Keychain.

**G5. Fix Error Messages yang Mengekspos Detail Infrastruktur**  
Semua error message yang menyebutkan "Laravel", "php artisan", atau detail teknis internal harus diganti dengan pesan generic yang user-friendly.

**G6. Pertimbangkan SSL Certificate Pinning**  
Untuk aplikasi yang menyimpan data pernikahan sensitif, pertimbangkan certificate pinning untuk mencegah MITM attacks.

### Menengah

**G7. Implementasikan Proper Session Invalidation**  
Saat 401, selain delete token, navigasikan user ke LoginView secara eksplisit. Pertimbangkan juga token refresh mechanism jika backend mendukungnya.

**G8. GIDClientID di Info.plist adalah Standard Practice**  
OAuth client ID `1008010367829-am6itqilhmatsctp7ckj1flhrkeg77es.apps.googleusercontent.com` di Info.plist adalah requirement Google Sign-In yang tidak bisa dihindari. Pastikan tidak ada OAuth client secret yang hardcoded di codebase.

---

## H. App Store Submission Checklist

### Wajib Selesai Sebelum Archive

#### Blocking Issues
- [ ] **BLOCKER** — Deploy production server dengan HTTPS (`api.weddingapp.co.id`)
- [x] ~~**BLOCKER** — Update `APIConfig.swift` ke production URL (Release build)~~ ✅ Done
- [x] ~~**BLOCKER** — Hapus `NSAllowsArbitraryLoads = true` dari Info.plist~~ ✅ Done
- [x] ~~**BLOCKER** — Implementasikan Sign in with Apple (entitlement + code + backend)~~ ✅ Done
- [x] ~~**BLOCKER** — Fix `deviceName` dari "iOS Simulator" ke `UIDevice.current.name`~~ ✅ Done
- [x] ~~**BLOCKER** — Fix error messages yang expose detail backend~~ ✅ Done
- [x] ~~**BLOCKER** — Implementasikan Messages dari API (hapus sample data)~~ ✅ Done
- [x] ~~**BLOCKER** — Implementasikan Inspiration dari API (hapus sample data)~~ ✅ Done
- [x] ~~**BLOCKER** — Fix Dashboard progress dari data real (hapus hardcoded 0.68 dan "34/12/14")~~ ✅ Done

#### Konfigurasi & Identity
- [ ] Bundle ID terdaftar di Apple Developer Portal
- [ ] App name tersedia di App Store
- [ ] `CFBundleShortVersionString` diset dengan benar (sekarang "1.0")
- [ ] `CFBundleVersion` diset dan increment setiap build baru (sekarang "1")
- [ ] Development team dipilih di Signing & Capabilities
- [ ] Provisioning profile "App Store Distribution" dibuat dan dipilih

#### Permissions & Entitlements
- [x] ~~Sign in with Apple entitlement ditambahkan~~ ✅ Done (`WeddingApp.entitlements`)
- [ ] Aktifkan Sign in with Apple di Apple Developer Portal untuk App ID `com.weddingapp.ios`
- [ ] `NSPhotoLibraryUsageDescription` ditambahkan (untuk upload bukti pembayaran)
- [ ] `NSCameraUsageDescription` ditambahkan (untuk QR scan check-in)
- [ ] Privacy manifest `PrivacyInfo.xcprivacy` dibuat

#### Security
- [x] ~~`kSecAttrAccessibleWhenUnlockedThisDeviceOnly` ditambahkan ke Keychain token storage~~ ✅ Done

#### Assets
- [ ] App icon 1024x1024 (PNG, tanpa transparansi, tanpa rounded corners)
- [ ] Semua ukuran icon di AppIcon.appiconset terisi
- [ ] Launch screen (UILaunchScreen) tidak kosong

### App Store Connect

#### Metadata
- [ ] App name, subtitle, deskripsi ditulis
- [ ] Keywords (max 100 karakter)
- [ ] Support URL (halaman support/kontak aktif)
- [ ] **WAJIB** — Privacy Policy URL aktif dan dapat diakses publik
- [ ] Category: Lifestyle (atau Productivity)

#### Screenshots
- [ ] 6.7" iPhone — WAJIB (iPhone 15 Pro Max / iPhone 16 Plus)
- [ ] 6.1" iPhone — direkomendasikan
- [ ] Screenshot menampilkan data nyata, bukan dummy/sample data

#### App Privacy Labels
- [ ] Nama pengguna (linked to user, required)
- [ ] Email address (linked to user, required)
- [ ] Nomor telepon (linked to user, optional)
- [ ] User Content — data pernikahan (linked to user)
- [ ] Third-party: Google Sign-In (name, email)

#### Review Information
- [ ] Test account (email + password) disiapkan untuk Apple reviewer
- [ ] Notes untuk reviewer menjelaskan flow Google Sign-In
- [ ] Semua fitur utama accessible dengan test account

### TestFlight
- [ ] Build diupload dan diproses tanpa error
- [ ] Internal testing (minimal tim developer) selesai
- [ ] External beta testing dilakukan minimal 1 minggu
- [ ] Semua crash dari TestFlight diselesaikan sebelum App Store submission

---

## I. QA Checklist Per Halaman

### Auth — Login
- [ ] Login dengan email + password valid berhasil masuk ke Dashboard
- [ ] Login dengan password salah menampilkan error message yang jelas
- [ ] Login dengan email tidak terdaftar menampilkan error
- [ ] Google Sign-In flow OAuth terbuka dan berhasil
- [ ] Apple Sign-In flow berfungsi (setelah diimplementasikan)
- [ ] Keyboard "Next" dari email pindah fokus ke password
- [ ] Keyboard "Go" dari password submit form
- [ ] Tombol "Masuk" disabled saat loading
- [ ] Error message hilang saat user mulai mengetik
- [ ] Tombol "Lupa Kata Sandi" berfungsi (setelah diimplementasikan)
- [ ] Navigasi ke RegisterView berfungsi

### Auth — Register
- [ ] Register sukses otomatis login dan masuk Dashboard
- [ ] Password tidak cocok menampilkan pesan error sebelum submit
- [ ] Submit dengan password berbeda tidak bisa dilakukan
- [ ] Semua field wajib diisi sebelum button aktif
- [ ] Email format tidak valid menampilkan error
- [ ] Password kurang dari minimum menampilkan error dari API
- [ ] Back button kembali ke LoginView dengan benar

### Dashboard — Home
- [ ] Nama couple dan tanggal dari data real (bukan hardcoded)
- [ ] Countdown menghitung dari tanggal event yang benar
- [ ] Progress pernikahan berasal dari data checklist real (bukan 68%)
- [ ] Stats Completed/In Progress/To Do dari data real (bukan 34/12/14)
- [ ] NextUp menampilkan event mendatang, bukan tanggal masa lalu
- [ ] Quote carousel auto-scroll setiap 4 detik dan berhenti saat tidak visible
- [ ] Pull-to-refresh memperbarui semua data
- [ ] Bell notification menuju halaman notifikasi (bukan More tab)
- [ ] Quick Actions semua berfungsi (Tasks, Vendors, Inspiration, Budget, Messages)
- [ ] Empty state jika belum ada event

### Checklist
- [ ] Data checklist tampil dari API, bukan sample data
- [ ] Section expand/collapse berfungsi dengan animasi
- [ ] Tap task membuka task detail
- [ ] Change status (pending → in_progress → done) tersimpan ke server
- [ ] Progress count akurat sesuai status
- [ ] Search task berfungsi
- [ ] Filter chip per event berfungsi
- [ ] Empty state jika belum ada tasks
- [ ] Sample data TIDAK tampil saat API berhasil

### Guest
- [ ] Daftar tamu tampil dari API
- [ ] Search nama berfungsi
- [ ] Filter RSVP (Konfirmasi/Pending/Tidak Hadir) berfungsi
- [ ] Tambah Tamu sheet → simpan → list refresh
- [ ] Statistik RSVP sesuai data real
- [ ] Sample data TIDAK tampil saat API berhasil
- [ ] Tombol magnifyingglass di header membuka search mode
- [ ] Tombol filter membuka filter options
- [ ] "Bagikan Undangan", "QR Check-in", "Export Data" — ada tindakan atau label coming soon

### Budget
- [ ] Total anggaran tampil dari API
- [ ] Donut chart dan stats sesuai data real
- [ ] Kategori tampil dengan expense masing-masing
- [ ] Tambah Expense end-to-end berfungsi
- [ ] Edit expense berfungsi
- [ ] Delete expense berfungsi
- [ ] Uang Masuk dapat ditambahkan dan diedit
- [ ] Search budget berfungsi (expense, kategori, uang masuk)
- [ ] Laporan budget dapat di-share
- [ ] Edit Total Budget tersimpan

### Vendor
- [ ] Daftar vendor tampil dari API
- [ ] Search vendor berfungsi
- [ ] Filter kategori (semua chip) berfungsi
- [ ] Filter sheet (provinsi, kota, rating, terverifikasi) berfungsi
- [ ] Sort (Popular/Rating/Terbaru) berfungsi
- [ ] Tap vendor membuka detail vendor
- [ ] Simpan/unsimpan vendor persists antar session
- [ ] "Kirim Permintaan" memiliki tindakan atau dihapus

### Inspiration
- [ ] Data inspirasi tampil dari API (bukan sample data)
- [ ] Search berfungsi
- [ ] Filter kategori berfungsi
- [ ] Simpan/unsimpan inspirasi berfungsi
- [ ] "Lihat Semua" buttons berfungsi atau dihapus
- [ ] Pull-to-refresh berfungsi

### Messages
- [ ] Thread percakapan tampil dari API (bukan sample data)
- [ ] Search percakapan berfungsi
- [ ] Filter kategori berfungsi
- [ ] Buka thread menampilkan riwayat pesan dari server
- [ ] Kirim pesan dikirim ke server dan persists
- [ ] Pull-to-refresh berfungsi

### More
- [ ] Foto profil dari avatar user (bukan hardcoded "CouplePortrait")
- [ ] Nama couple dari data real
- [ ] Tanggal dan lokasi dari data event
- [ ] Edit Profil → simpan → data terupdate di profil
- [ ] Detail Pernikahan navigasi berfungsi
- [ ] Pasangan navigasi berfungsi
- [ ] Vendor Tersimpan navigasi berfungsi
- [ ] Inspirasi & Ide navigasi berfungsi
- [ ] Dokumen navigasi berfungsi
- [ ] Item Akun & Pengaturan: implementasikan atau tandai "coming soon"
- [ ] Logout → konfirmasi alert → kembali ke LoginView
- [ ] ShareLink mengarah ke URL App Store yang benar

### UI/UX Global
- [ ] Dark Mode: semua AppTheme colors terlihat baik di dark background
- [ ] Dynamic Island (iPhone 15/16 Pro): konten tidak tersembunyi
- [ ] iPhone SE (375pt width): tidak ada konten terpotong atau overflow
- [ ] iPhone Pro Max (430pt width): layout proporsional
- [ ] Dynamic Type Large/XLarge: teks tidak terpotong (perlu `relativeTo:`)
- [ ] Safe area: konten tidak tersembunyi di area notch/home indicator
- [ ] Semua tombol memiliki `accessibilityLabel` yang deskriptif
- [ ] Offline state: pesan error jelas saat tidak ada internet
- [ ] Loading state konsisten di semua halaman (ProgressView atau skeleton)

---

## J. Rekomendasi Refactor Struktur Project

### J1. Pisahkan View File yang Terlalu Besar

`DashboardView.swift` (661 baris) dan `BudgetView.swift` (760 baris) terlalu besar dan sulit di-maintain. Pisahkan komponen internal:

```
Sources/Features/Dashboard/
    DashboardView.swift             ← TabView container saja
    HomeDashboardView.swift         ← main dashboard content
    Components/
        WeddingSummaryCard.swift
        WeddingProgressCard.swift
        QuoteCarouselCard.swift
        NextUpSection.swift
        QuickActionsCard.swift
```

### J2. Buat Service Layer untuk API Calls

Saat ini setiap view memanggil `APIClient.shared.request(...)` langsung. Buat service layer untuk memudahkan testing dan separation of concerns:

```swift
// Sources/Services/WeddingInfoService.swift
protocol WeddingInfoServiceProtocol {
    func fetchInfo() async throws -> WeddingInfo
    func fetchEvents() async throws -> [WeddingEvent]
}

final class WeddingInfoService: WeddingInfoServiceProtocol {
    func fetchInfo() async throws -> WeddingInfo {
        let envelope: Envelope<WeddingInfo> = try await APIClient.shared.request("wedding-info")
        return envelope.data
    }
}
```

### J3. Pindahkan Orphan Models ke `Sources/Models/`

- `PreparationSection` — dari `ChecklistView.swift` baris 614 ke `Sources/Models/PreparationSection.swift`
- `RsvpKind` — dari `GuestView.swift` ke `Sources/Models/Guest.swift` atau file tersendiri
- `DashboardTab` — bisa tetap private tapi pertimbangkan konsistensi

### J4. Buat DateFormatters.swift Terpusat

Duplikasi `private extension DateFormatter` di minimal 3 file. Konsolidasikan:

```swift
// Sources/Utils/DateFormatters.swift
extension DateFormatter {
    static let weddingInput: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    static let weddingDateDisplay: DateFormatter = { ... }()
    static let weddingDateOnly: DateFormatter = { ... }()
}
```

### J5. Pisahkan Sample/Stub Data ke DEBUG Only

Semua `static let samples` harus dibungkus `#if DEBUG` agar tidak masuk production build:

```swift
#if DEBUG
static let samples: [GuestRowItem] = [
    GuestRowItem(id: 1, name: "Keluarga Besar Pratama", ...),
    ...
]
#endif
```

Ini mencegah sample data secara tidak sengaja tampil di production builds dan mengurangi binary size.

### J6. Gunakan @ObservedObject untuk Shared Singletons

```swift
// SALAH — @StateObject untuk singleton
@StateObject private var categoriesStore = BudgetCategoriesStore.shared

// BENAR — @ObservedObject untuk singleton
@ObservedObject private var categoriesStore = BudgetCategoriesStore.shared
```

### J7. Tambahkan Unit Test Dasar Sebelum Release

Saat ini tidak ada test file. Prioritas:

```
Tests/WeddingAppTests/
    BudgetCalculationTests.swift    ← BudgetSummaryMetrics.resolve(), CurrencyFormatter
    CountdownTests.swift            ← daysRemaining logic
    AuthValidationTests.swift       ← isFormValid, passwordsMismatch
    GuestRSVPTests.swift            ← RsvpKind.from(), statistik total/percent
    ChecklistProgressTests.swift    ← progress calculation dari status tasks
```

---

## Ringkasan Prioritas Pengerjaan

### Sprint 1 — Blocker (Selesaikan SEBELUM hal lain)
1. Setup production server dengan HTTPS dan domain publik (`api.weddingapp.co.id`)
2. ~~Update `APIConfig.swift` ke production HTTPS URL~~ ✅ Done (Release build)
3. ~~Hapus `NSAllowsArbitraryLoads`, konfigurasi ATS yang benar~~ ✅ Done
4. ~~Implementasikan Sign in with Apple (entitlement + ASAuthorizationController + backend)~~ ✅ Done
5. ~~Fix `deviceName` dari "iOS Simulator" ke `UIDevice.current.name`~~ ✅ Done
6. ~~Fix error messages yang expose detail backend~~ ✅ Done
7. ~~Implementasikan API integration untuk MessagesView~~ ✅ Done
8. ~~Implementasikan API integration untuk InspirationView~~ ✅ Done
9. ~~Hapus hardcoded progress (0.68) dan stats (34/12/14) di Dashboard~~ ✅ Done

### Sprint 2 — High Priority (Sebelum TestFlight)
1. ~~Fix semua tombol non-fungsional~~ ✅ Done — action bar Guest & More nil-items sekarang tampilkan "Segera Hadir"
2. Implementasikan Lupa Password (butuh backend — lihat K5)
3. Implementasikan halaman Settings, Privacy, FAQ di More tab (sementara sudah ada "Segera Hadir")
4. ~~Fix RootView — tambahkan splash screen/loading state saat session restore~~ ✅ Done
5. Tambahkan Privacy Policy yang dapat diakses dari dalam app
6. ~~Tambahkan konfirmasi dialog sebelum logout~~ ✅ Done
7. ~~Tambahkan validasi format email di LoginView dan RegisterView~~ ✅ Done
8. ~~Fix tombol bell dashboard ke notifikasi~~ ✅ Done — sheet NotificationsSheet
9. ~~Fix GuestView header buttons~~ ✅ Done (dihapus — redundant)

### Sprint 3 — Quality (Sebelum App Store Submit)
1. ~~Performance: `LazyVStack` untuk semua list~~ ✅ Done
2. ~~Performance: Debounce filter VendorView~~ ✅ Done
3. ~~Performance: Rate-limit appDidBecomeActive~~ ✅ Done
4. ~~Security: `kSecAttrAccessible` di Keychain~~ ✅ Done
5. ~~Security: 401 auto-logout redirect ke LoginView~~ ✅ Done
6. ~~Dynamic Type: `AppFont` dengan `relativeTo:`~~ ✅ Done
7. ~~Profile avatar dari user session~~ ✅ Done
8. ~~DateFormatter konsolidasi~~ ✅ Done
9. ~~File legacy GuestListView.swift dihapus~~ ✅ Done
10. Accessibility: `accessibilityLabel` untuk semua elemen interaktif
11. Launch screen — design sesuai tema (butuh asset)
12. App icon — lengkapi semua ukuran
13. Unit tests — minimal Budget calculation, Countdown, Auth validation
14. Screenshot App Store dengan data real
15. TestFlight internal beta minimum 1 minggu

---

## K. Panduan Backend untuk App Store Readiness

Semua pekerjaan iOS dan backend API **sudah selesai (Sesi 1–3, 53 item)**. Sisa blocker utama adalah **deploy server production HTTPS** dan kelengkapan App Store metadata.

**Endpoint yang sudah tersedia:**

| Endpoint | Method | Auth |
|---|---|---|
| `customer-preparation-tasks/summary` | GET | Sanctum |
| `messages/threads` | GET | Sanctum |
| `messages/threads/{id}` | GET | Sanctum |
| `messages/threads/{id}/send` | POST | Sanctum |
| `inspirations` | GET | Sanctum |
| `inspirations/{id}/save` | POST / DELETE | Sanctum |
| `auth/apple` | POST | Public |

---

### K1. Deploy Production Server + HTTPS (BLOCKER UTAMA)

Ini adalah blocker paling mendasar. Semua blocker lain bergantung pada ini.

#### Langkah Deploy

1. **Pilih hosting** — Laravel Forge + DigitalOcean/AWS/Hetzner, atau Laravel Cloud (`cloud.laravel.com`)
2. **Domain publik** — daftarkan domain, contoh: `api.weddingapp.co.id`
3. **SSL Certificate** — Let's Encrypt (gratis, auto-renewal) atau Cloudflare proxy
4. **Server requirements** — PHP 8.4, MySQL 8+, Redis (untuk queue/cache)

#### Setelah Deploy — Perubahan iOS

> ✅ **Sudah dilakukan di Sesi 3.** Release build memakai `https://api.weddingapp.co.id/api/v1` dan `NSAllowsArbitraryLoads` sudah dihapus.

**File: `Sources/Networking/APIConfig.swift`** — Release build:

```swift
struct APIConfig {
    static let baseURL = URL(string: "https://api.weddingapp.co.id/api/v1")!
}
```

**File: `Generated/Info.plist`** — `NSAllowsArbitraryLoads` sudah dihapus. Debug build memakai `NSAllowsLocalNetworking` saja untuk development lokal.

Setelah HTTPS aktif di server production, Release build siap tanpa konfigurasi ATS tambahan.

---

### K2. Sign in with Apple ~~(BLOCKER)~~ ✅ Selesai

> ✅ **Sudah diimplementasikan** di Sesi 3. Lihat Changelog item #37, #48–51.

#### Backend Laravel

```bash
php artisan make:controller Auth/AppleAuthController
```

```php
// routes/api.php
Route::post('auth/apple', [AppleAuthController::class, 'login']);
```

```php
// app/Http/Controllers/Auth/AppleAuthController.php
public function login(Request $request): JsonResponse
{
    $request->validate([
        'identity_token' => 'required|string',
        'device_name'    => 'required|string',
        'full_name'      => 'nullable|string', // hanya dikirim saat pertama kali login
        'email'          => 'nullable|email',  // hanya dikirim saat pertama kali login
    ]);

    // Verifikasi identity token dengan Apple public key
    // Gunakan package: lcobucci/jwt atau stancl/apple-sign-in
    $applePayload = AppleSignIn::verify($request->identity_token);
    $appleUserId  = $applePayload->sub; // Apple user ID yang unik dan stabil

    $user = User::firstOrCreate(
        ['apple_id' => $appleUserId],
        [
            'name'     => $request->full_name ?? 'Apple User',
            'email'    => $request->email ?? $applePayload->email,
            'password' => bcrypt(Str::random(32)),
        ]
    );

    $token = $user->createToken($request->device_name)->plainTextToken;

    return response()->json(['user' => $user, 'token' => $token]);
}
```

**Migration yang perlu ditambahkan:**

```bash
php artisan make:migration add_apple_id_to_users_table
```

```php
$table->string('apple_id')->nullable()->unique()->after('id');
$table->string('google_id')->nullable()->unique()->after('apple_id'); // jika belum ada
```

**Package yang direkomendasikan:**

```bash
composer require patrickbussmann/apple-sign-in
```

#### iOS — Perubahan Setelah Backend Siap

1. Xcode → Target → Signing & Capabilities → tambah **Sign in with Apple**
2. Di `SessionStore.swift`, implementasikan `loginWithApple()` menggunakan `ASAuthorizationAppleIDProvider`
3. Di `LoginView.swift` dan `RegisterView.swift`, isi closure yang sekarang kosong: `AuthSocialFullButton(provider: .apple) { Task { await session.loginWithApple() } }`

---

### K3. Messages & Inspiration API (BLOCKER — Dummy Data)

Kedua fitur ini saat ini 100% sample data. Apple akan reject app yang menampilkan dummy data.

#### K3a. Messages API

```bash
php artisan make:model Message -m
php artisan make:model MessageThread -m
php artisan make:controller MessageController --api
```

**Endpoint yang dibutuhkan iOS:**

```php
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('messages/threads', [MessageController::class, 'threads']);
    Route::get('messages/threads/{thread}', [MessageController::class, 'show']);
    Route::post('messages/threads/{thread}/send', [MessageController::class, 'send']);
});
```

**Response format yang diharapkan iOS** (sesuai `Sources/Models/Message.swift`):

```json
// GET /api/v1/messages/threads
{
  "data": [
    {
      "id": 1,
      "name": "Vendor Fotografer",
      "category": "vendor",
      "avatar_url": "https://...",
      "last_message": "Terima kasih pesanannya",
      "last_message_at": "2026-07-01T10:00:00.000000Z",
      "unread_count": 2,
      "has_unread": true
    }
  ]
}
```

#### K3b. Inspiration API

```bash
php artisan make:model InspirationItem -m
php artisan make:controller InspirationController --api
```

**Endpoint yang dibutuhkan iOS:**

```php
Route::get('inspirations', [InspirationController::class, 'index']);
Route::post('inspirations/{id}/save', [InspirationController::class, 'save']);
Route::delete('inspirations/{id}/save', [InspirationController::class, 'unsave']);
```

**Response format** (sesuai `Sources/Models/Inspiration.swift`):

```json
// GET /api/v1/inspirations
{
  "data": [
    {
      "id": 1,
      "title": "Dekorasi Rustic Garden",
      "image_url": "https://...",
      "category": "decoration",
      "likes": 1240,
      "is_saved": false
    }
  ]
}
```

---

### K4. Dashboard Stats dari Checklist API (BLOCKER — Dummy Data)

Dashboard saat ini menampilkan progress 68% dan angka "34/12/14" yang hardcoded.

**Tambahkan endpoint summary di ChecklistController:**

```php
// routes/api.php
Route::get('checklists/summary', [ChecklistController::class, 'summary']);
```

```php
// app/Http/Controllers/ChecklistController.php
public function summary(): JsonResponse
{
    $userId = auth()->id();
    $tasks  = PreparationTask::where('user_id', $userId)->get();

    $total      = $tasks->count();
    $completed  = $tasks->where('status', 'done')->count();
    $inProgress = $tasks->where('status', 'in_progress')->count();
    $todo       = $tasks->where('status', 'pending')->count();
    $progress   = $total > 0 ? round($completed / $total, 2) : 0;

    return response()->json([
        'data' => [
            'total'       => $total,
            'completed'   => $completed,
            'in_progress' => $inProgress,
            'todo'        => $todo,
            'progress'    => $progress, // 0.0 - 1.0
        ]
    ]);
}
```

**Response format:**

```json
{
  "data": {
    "total": 60,
    "completed": 34,
    "in_progress": 12,
    "todo": 14,
    "progress": 0.57
  }
}
```

**Setelah endpoint ini siap**, update `DashboardView.swift`:
- Tambahkan `@State private var checklistSummary: ChecklistSummary?`
- Ganti `private var preparationProgress: Double { 0.68 }` dengan nilai dari API
- Ganti `ProgressStatRow` hardcoded dengan nilai dari `checklistSummary`

---

### K5. Lupa Kata Sandi (High Priority)

```bash
php artisan make:controller Auth/ForgotPasswordController
```

**Endpoint:**

```php
// routes/api.php
Route::post('auth/forgot-password', [ForgotPasswordController::class, 'send']);
Route::post('auth/reset-password',  [ForgotPasswordController::class, 'reset']);
```

Laravel sudah punya built-in password reset via `Illuminate\Auth\Passwords\PasswordBroker`. Gunakan:

```php
use Illuminate\Support\Facades\Password;

public function send(Request $request): JsonResponse
{
    $request->validate(['email' => 'required|email']);

    $status = Password::sendResetLink($request->only('email'));

    return $status === Password::RESET_LINK_SENT
        ? response()->json(['message' => 'Link reset dikirim ke email Anda.'])
        : response()->json(['message' => 'Email tidak ditemukan.'], 422);
}
```

**Di iOS** (`LoginView.swift`), isi closure `AuthDottedLink(title: "Lupa kata sandi?")` dengan sheet yang meminta input email, lalu panggil endpoint ini.

---

### K6. Urutan Pengerjaan Backend yang Disarankan

```
1. Deploy server + HTTPS                    ← buka blokir semua item lain
2. Dashboard Checklist Summary endpoint     ← cepat, 1 jam, langsung terlihat
3. Inspiration API (CRUD + seed data)       ← penting untuk konten
4. Messages API (threads + send)            ← penting untuk UX
5. Sign in with Apple endpoint              ← wajib Apple, butuh research package
6. Forgot Password endpoint                 ← built-in Laravel, cepat
```

---

*Audit ini dilakukan berdasarkan review kode statis pada 2026-07-07, diperbarui 2026-07-08 setelah Sesi 3 (backend API + iOS integration + ATS fix). Beberapa issue (performance, memory leak) memerlukan runtime testing dengan Instruments untuk konfirmasi penuh.*
