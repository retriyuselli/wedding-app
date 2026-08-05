# Master Audit — Wedding App

**Tanggal audit:** 17 Juli 2026  
**Scope:** iOS app (`ios-app/`) + Laravel API (`wedding-app/`)  
**Target:** Production App Store, puluhan ribu user  
**Verdict:** **READY WITH ISSUES** — submit setelah Critical/High terbuka diselesaikan; jangan scale publik sebelum pagination + privacy manifest.

> **Dokumen ini adalah satu-satunya source of truth** untuk audit, App Store readiness, dan checklist submit.  
> Menggantikan: `audit.md`, `auditxcode.md`, `reviewapp.md`.

---

## Nilai Akhir

| Kategori | Skor | Ringkasan |
|---|---:|---|
| Keamanan | **68/100** | JWS verify + rate limit + 2FA lockout sudah di-push (`f239b21`); privacy manifest & premium bypass API masih open |
| Performa | **58/100** | Tab eager-load, AsyncImage tanpa cache, view 1.000+ baris |
| SwiftUI | **65/100** | `@MainActor` VM ada; singleton + nested NavigationStack |
| UI/UX | **72/100** | Tema ivory/sage kuat; dark mode & VoiceOver belum konsisten |
| Maintainability | **55/100** | Mega-view, coupling singleton, tidak ada test target iOS |
| Scalability | **52/100** | API tanpa pagination, 20–30 request saat launch |
| **App Store Readiness** | **72/100** | Core flow siap; IAP ASC + entitlements push masih manual |

---

## Perbaikan Terbaru (sudah di production repo)

Commit **`f239b21`** — *Harden billing verification and API auth security.*

| Item | Status |
|---|---|
| Verifikasi kriptografis StoreKit JWS + `storage/certs/AppleRootCA-G3.pem` | ✅ |
| Rate limiting API (auth 10/min, 2FA 10/min, billing 15/min, api 120/min) | ✅ |
| 2FA brute-force lockout (5 gagal → lockout 15 menit) | ✅ |
| iOS: `auth/two-factor/verify` tidak kirim Bearer token lama | ✅ |
| Filament Wedding Pro (toggle, filter, bulk activate/revoke) | ✅ |
| Partner shared Premium (Option A) + privacy visibility | ✅ |
| Paywall: pesan IAP lebih jelas + tombol Muat ulang produk | ✅ |
| Privacy manifest (`PrivacyInfo.xcprivacy`) — collected data types | ✅ |
| Photo/camera/contacts usage strings di `project.yml` | ✅ |
| Guest: sembunyikan Share undangan & QR Coming Soon | ✅ |
| Help FAQ: hapus tombol "Lihat semua" Coming Soon | ✅ |

**Production `.env` wajib:**
```env
APPLE_JWS_VERIFICATION_BYPASS=false
APPLE_BUNDLE_ID=com.weddingapp.ios
APPLE_ROOT_CA_PATH=storage/certs/AppleRootCA-G3.pem
```

---

## Temuan Utama

| Prioritas | Lokasi | Masalah | Dampak | Cara Memperbaiki |
|---|---|---|---|---|
| **Critical** | App Store Connect | IAP `wedding_pro_unlock` belum Ready / belum attach | Paywall: "Produk belum tersedia" | Lengkapi metadata IAP + Paid Apps Agreement (lihat § IAP Troubleshooting) |
| **Critical** | `WeddingApp.entitlements` | `aps-environment = development` on-disk | Push TestFlight/App Store gagal | Archive Release → verifikasi entitlements = `production` |
| **High** | `DashboardView` + TabView | Semua tab load sekaligus (`.task`) | 20–30 API call saat launch | Lazy tab + shared data store |
| **High** | 10+ view | `AsyncImage` tanpa cache | Scroll jank, bandwidth boros | `CachedAsyncImage` + thumbnail URL |
| **High** | Semua list API | `->get()` tanpa pagination | Timeout 500+ tamu | `paginate()` + infinite scroll di iOS |
| **High** | `PremiumStore.swift` | `localEntitled` unlock UI tanpa server sync | UI Pro tapi API 403 | Server = source of truth; `finish()` setelah sync sukses |
| **High** | `WeddingInfoController` | `couple_photo` via `PUT wedding-info` bypass premium | Fitur Pro bisa diakses free | Gate premium pada update dengan file |
| **Medium** | `WeddingAppApp.swift` | `.id("appearance-...")` remount tree | Reload API storm saat ganti tema | Hapus blanket `.id()` |
| **Medium** | `GuestView` (1.782 baris) | Monolithic view, filter tanpa debounce | Re-render berat | Split subview + debounce 300ms |
| **Medium** | iOS (9 file) | VoiceOver hampir tidak dilabeli | Accessibility buruk | `accessibilityLabel` di icon buttons |
| **Medium** | `config/sanctum.php` | Token tidak expire | Token curian valid selamanya | Set expiration 30 hari |
| **Medium** | `PushNotificationManager` | APNs token di UserDefaults | Identifier tidak terenkripsi | Pindah ke Keychain |
| **Low** | `AboutContent.swift` | `appStoreID = nil` | Share tidak ke App Store | Set ID setelah publish |
| **Low** | `InfoTabView.swift` | Tidak pernah dinavigasi | Dead code | Hapus atau wire |

---

## Top 20 Masalah Paling Kritis (open)

1. IAP belum Ready di App Store Connect
2. Push entitlements mungkin masih `development` di Archive
3. TabView eager-load → API storm saat launch
4. AsyncImage tanpa cache di grid image-heavy
5. API list tanpa pagination (guests, vendors, messages)
6. Client premium UI via `localEntitled` sebelum server sync
7. `transaction.finish()` sebelum server verify sukses
8. Premium bypass: `couple_photo` via `PUT wedding-info`
9. Sanctum token tidak expire
10. Session restore timeout → orphaned Keychain token
11. Error body server bisa tampil ke user (info disclosure)
12. Tidak ada unit/UI test target iOS
13. Nested NavigationStack di child views
14. Appearance `.id()` remount seluruh app
15. Budget route inconsistency (sebagian gated, sebagian tidak)
16. Dark mode: `Color.white` hardcoded di banyak view
17. Demo accounts belum dibuat di production API

---

## Top 20 Peningkatan Performa Terbesar

1. Lazy-load TabView — **−2–5 s launch**
2. Cached image layer — **−40–70% scroll CPU**
3. Hapus appearance `.id()` remount — **−1–3 s** saat ganti tema
4. Server-side pagination guests — **−500 ms–3 s** untuk 500+ tamu
5. Dedupe API calls (wedding-info, guests, entitlement) — **−60–80%** request awal
6. Debounce search Guest/Inspiration/Vendor — **−30–150 ms/keystroke**
7. Offload image compress ke background thread — **−100 ms–2 s** freeze
8. Stale-while-revalidate foreground reload (TTL 60s)
9. Debounce Vendor filter API
10. Split `GuestView` / `VendorView` ke subviews Equatable
11. Fix nested NavigationStack
12. Thumbnail URLs dari server
13. Batch parallel API dengan `async let` terpusat
14. Cancel in-flight tasks on tab switch
15. Lazy load More tab data
16. Memoize filtered guest rows
17. Reduce `@Published` churn di singleton stores
18. Pagination inspirations/vendors catalog
19. Compress JSON response (gzip) di Laravel
20. CDN untuk static vendor/inspiration images

---

## Top 20 Peningkatan Keamanan (open)

1. Lengkapi PrivacyInfo.xcprivacy + ASC App Privacy labels
2. Sanctum token expiration
3. Server-authoritative premium gating di iOS (`PremiumStore`)
4. Close premium bypass routes (`couple_photo`, budget policy)
5. Rate limit data export (1/jam/user)
6. Disable `device-tokens/test` di production
7. Move APNs token dari UserDefaults ke Keychain
8. Keychain write error handling
9. Sanitize API error messages di Release
10. Authenticated download untuk budget proof images
11. Audit Required Reason APIs (Keychain, FileManager, IDFV)
12. Clear Keychain on fresh login + session restore failure
13. Tighten Excel MIME validation
14. Audit log vendor contact requests
15. Optional: certificate pinning untuk `weddingapp.co.id`
16. Pagination untuk mencegah data exfiltration via bulk export
17. Premium test assertions di CI (403 untuk free user)
18. Idempotency + audit log billing verify
19. Secure temp export files (`PrivacyRepository`)
20. `DeviceIdentity` fallback UUID di Keychain

---

## Top 20 Penyebab Kemungkinan Ditolak App Store

1. IAP product tidak tersedia di TestFlight/production
2. Privacy manifest tidak sesuai data aktual
3. App Privacy labels tidak match manifest
4. Fitur Coming Soon visible (Guest share/QR)
5. Demo account tidak disediakan di Review Notes
6. Login wajib tapi API production down
7. Push entitlements `development` di build Release
8. Missing usage description (photos/camera)
9. Incomplete functionality di Help FAQ
10. Privacy Policy URL broken
11. Account deletion tidak berfungsi
12. Misleading App Store description (fitur belum ada)
13. Crash on cold launch (API storm timeout)
14. Restore Purchases tidak jalan
15. Export compliance salah di questionnaire
16. Third-party SDK privacy (GoogleSignIn manifest)
17. Age rating tidak sesuai
18. Screenshot tidak match fitur aktual
19. External payment mention
20. Broken support URL

---

## Yang Sudah Baik

| Area | Status |
|---|---|
| Token auth di Keychain (`WhenUnlockedThisDeviceOnly`) | ✅ |
| Debug logging gated `#if DEBUG` | ✅ |
| Release ATS: no arbitrary loads | ✅ |
| 401 → clear token + session expired | ✅ |
| StoreKit rejects unverified transactions (client) | ✅ |
| Sign in with Apple + Google | ✅ |
| Account deletion dengan konfirmasi `HAPUS` | ✅ |
| Forgot password flow | ✅ |
| Privacy Policy & Terms in-app | ✅ |
| Privacy visibility gate + shared premium (Option A) | ✅ |
| Filament Wedding Pro admin | ✅ |
| Soft-lock Pro (bukan blank screen) | ✅ |
| Wedding documents largely functional | ✅ |
| Language selection enabled | ✅ |
| Notifications sheet API-backed | ✅ |
| Apple JWS cryptographic verification (server) | ✅ |
| API rate limiting + 2FA lockout | ✅ |
| Export compliance flag (`ITSAppUsesNonExemptEncryption: false`) | ✅ |

---

## App Review Notes (copy-paste ke App Store Connect)

```text
Wedding App — App Review Notes

=== DEMO ACCOUNTS ===

1) Free account (soft-locked Pro features):
   Email: review.free@weddingapp.co.id
   Password: ReviewFree2026!

2) Wedding Pro account (already unlocked on server):
   Email: review.pro@weddingapp.co.id
   Password: ReviewPro2026!

Please use email/password login (not Google/Apple) for the fastest review path.

=== HOW TO TEST FREE → PRO UNLOCK ===

1. Sign in with the Free demo account.
2. Open tabs: Checklist / Tamu / Budget — content is visible behind a soft lock (blur + unlock card).
3. Or open: Lainnya → Wedding Pro.
4. Tap “Buka Pro” / “Unlock Pro” and complete the In-App Purchase.
5. After purchase, Pro features unlock for that account.
6. “Pulihkan Pembelian” / “Restore Purchases” restores a previous purchase.

Product ID: wedding_pro_unlock (Non-Consumable, one-time purchase)

=== WHAT IS FREE VS PRO ===

Free (no purchase required):
- Sign in / register
- Home/Dashboard basics
- Vendor catalog browse
- Account, privacy settings, help, appearance
- Soft-locked previews of Pro screens (visible but actions gated)

Wedding Pro unlocks:
- Preparation checklist
- Guest / VIP / family lists (+ Excel export/import)
- Full budget tools (schedules, allocations, incoming)
- Wedding documents
- Couple photo upload
- Inspiration save/like
- Reminders (premium-gated preferences)
- Partner sharing: a linked free partner can access shared Pro data owned by a Pro account when visibility is set to Couple

=== ACCOUNT DELETION ===

Lainnya → Privasi & Keamanan → Hapus Akun

Backend: `UserObserver::deleting` → `UserStorageCleanup` menghapus file di storage
(couple photos, wedding documents, payment proofs, preparation attachments, exports, avatar lokal)
sebelum row user di-cascade, agar tidak ada file yatim.

=== PRIVACY POLICY ===

https://www.weddingapp.co.id/privacy-policy

=== NOTES FOR REVIEWER ===

- Soft locks intentionally show preview content + unlock CTA (not blank screens).
- IAP is Non-Consumable; restore is available on the paywall.
- Vendor browsing is free and does not require Pro.
- Sign-in with Google/Apple is optional; email/password demo accounts are provided above.
```

---

## Demo Accounts (production server)

### Buat user free

```bash
php artisan tinker --execute '
$user = App\Models\User::query()->updateOrCreate(
    ["email" => "review.free@weddingapp.co.id"],
    [
        "name" => "App Review Free",
        "password" => "ReviewFree2026!",
        "email_verified_at" => now(),
        "is_premium" => false,
        "premium_product_id" => null,
        "premium_activated_at" => null,
        "apple_original_transaction_id" => null,
    ]
);
echo "Free user id={$user->id}\n";
'
```

### Buat user Pro

```bash
php artisan tinker --execute '
$user = App\Models\User::query()->updateOrCreate(
    ["email" => "review.pro@weddingapp.co.id"],
    [
        "name" => "App Review Pro",
        "password" => "ReviewPro2026!",
        "email_verified_at" => now(),
        "is_premium" => true,
        "premium_product_id" => "wedding_pro_unlock",
        "premium_activated_at" => now(),
        "apple_original_transaction_id" => "app-review-demo-pro",
    ]
);
echo "Pro user id={$user->id} premium=".($user->is_premium ? "yes" : "no")."\n";
'
```

**Alternatif:** Filament Admin → Users → **Aktifkan Pro** (toggle Wedding Pro).

> Ganti password sebelum production live jika perlu. Jangan commit password asli ke repo publik.

---

## IAP Troubleshooting: "Produk belum tersedia"

Pesan ini = StoreKit **tidak menemukan** `wedding_pro_unlock` di App Store (bukan error API). Tombol tanpa harga (`Buka Wedding Pro` bukan `Buka Pro · Rp…`).

Cek berurutan di [App Store Connect](https://appstoreconnect.apple.com):

1. **Agreements, Tax, and Banking** → Paid Applications Agreement **Active**
2. **Monetization → In-App Purchases** → Non-Consumable `wedding_pro_unlock`, localization + harga + availability Indonesia, status **Ready to Submit**
3. App ID `com.weddingapp.ios` → **In-App Purchase** capability enabled
4. Saat submit versi → attach IAP di **In-App Purchases and Subscriptions**
5. TestFlight → Sandbox Apple ID (Settings → Developer → Sandbox Account)
6. Xcode lokal pakai `Products.storekit`; TestFlight **tidak** — TF gagal = masalah ASC

Workaround review: aktifkan Pro manual di Filament / akun `review.pro@…`.

---

## Checklist Sebelum Archive

- [ ] `APPLE_JWS_VERIFICATION_BYPASS=false` di production `.env`
- [ ] Archive **Release** → entitlements `aps-environment = production`
- [ ] `APIConfig.productionURL` = domain API live yang benar
- [ ] Build 0 warning (Release)
- [ ] Sign in with Apple + Google smoke test di device fisik
- [ ] Paywall load product (harga muncul) di TestFlight
- [ ] Push notification test di TestFlight build
- [ ] Sembunyikan atau implement Guest Coming Soon actions — **selesai (kode)**
- [ ] Demo accounts free + Pro di production API
- [ ] Privacy manifest review (minimal: collected data types) — **selesai (kode)**

---

## Checklist Sebelum Upload App Store Connect

- [ ] IAP `wedding_pro_unlock` Ready + attached ke versi
- [ ] Paid Applications Agreement Active
- [ ] Screenshots iPhone (6.7", 6.5", 5.5" atau set ASC terbaru)
- [ ] App Privacy questionnaire completed
- [ ] Privacy Policy URL live: `https://www.weddingapp.co.id/privacy-policy`
- [ ] Terms URL live
- [ ] Support URL
- [ ] Paste **App Review Notes** (§ di atas)
- [ ] Centang "Sign-in required" + demo credentials
- [ ] TestFlight: sandbox purchase + restore + delete account
- [ ] Deskripsi app tidak claim fitur Coming Soon
- [ ] Export compliance: No (non-exempt encryption)

---

## Checklist Sebelum Release Publik

- [ ] Pagination API guests/vendors/messages
- [ ] iOS image cache + lazy tabs
- [ ] Privacy manifest + ASC labels aligned
- [ ] Sanctum token expiration
- [ ] Server-authoritative premium di iOS
- [ ] Monitoring crash (Sentry/Crashlytics atau setara)
- [ ] Load test API
- [ ] Accessibility pass minimum (VoiceOver)
- [ ] App Store ID di `AboutContent.swift`
- [ ] Customer support channel di ASC

---

## Rekomendasi Prioritas

| Fase | Durasi | Fokus |
|---|---|---|
| **Pre-submit** (wajib) | 1–2 hari | IAP ASC, entitlements push, privacy manifest, demo accounts, sembunyikan Coming Soon |
| **Pre-scale** | 3–5 hari | Pagination API, lazy tabs, image cache, premium iOS sync |
| **Post-launch v1.1** | 1–2 minggu | Accessibility, iOS tests, dark mode audit, split mega-views |

---

## Key Paths

| Area | Path |
|---|---|
| iOS app | `ios-app/WeddingApp/Sources/` |
| API client | `ios-app/WeddingApp/Sources/Networking/APIClient.swift` |
| Billing iOS | `ios-app/WeddingApp/Sources/Features/Billing/` |
| Apple JWS verify | `app/Services/Billing/AppleStoreKitJwsVerifier.php` |
| Rate limiting | `app/Providers/AppServiceProvider.php`, `routes/api.php` |
| Privacy gate | `app/Services/Privacy/PrivacyVisibilityGate.php` |
| Filament Pro admin | `app/Filament/Resources/Users/` |
| Apple Root CA | `storage/certs/AppleRootCA-G3.pem` |
| StoreKit local test | `ios-app/WeddingApp/Sources/Resources/Products.storekit` |
| Dev/deploy ops | `.info.md` |

---

## Ringkas untuk Reviewer (1 paragraf)

Wedding App is a freemium wedding planner. Core browsing (home, vendors, account) works without purchase. Advanced planning tools are soft-locked behind a one-time Non-Consumable IAP (`wedding_pro_unlock`) with Restore Purchases. Two demo accounts are provided: free (to test locks + purchase) and Pro (already unlocked on the server).


