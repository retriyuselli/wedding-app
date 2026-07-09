# Audit Final iOS App Store - Wedding App

Tanggal audit: 9 Juli 2026  
Terakhir diperbarui: 9 Juli 2026 (setelah perbaikan empty state Guest/Checklist)

## A. Executive Summary

| Severity | Count |
|---|---:|
| Critical | 1 |
| High | 1 |
| Medium | 5 |
| Low | 3 |

Build Xcode berhasil setelah perbaikan menggunakan `BuildProject`: 0 error dan 0 warning. Release build via `xcodebuild` tidak berhasil divalidasi dari terminal karena sandbox tidak punya akses ke SwiftPM/Xcode cache di `~/Library`, sehingga Archive Release tetap perlu diverifikasi manual dari Xcode.

## B. App Store Submission Verdict

**READY WITH MINOR ISSUES**

Catatan utama sebelum Archive: pastikan entitlement push notification untuk Release/App Store memakai `aps-environment = production`.

## C. Critical Rejection Risks

| Severity | Lokasi | Masalah | Risiko Apple | Solusi | Status |
|---|---|---|---|---|---|
| Critical | `WeddingApp.entitlements:5` | `aps-environment` masih `development` di file entitlements aktual | Archive/App Store distribution bisa gagal atau push production tidak valid | Pastikan archived app memakai `aps-environment = production`. `project.yml` sudah punya Release override, tetapi harus diverifikasi di Xcode Archive Organizer atau exported entitlements | Needs Manual Action |
| High | `Sources/App/RootView.swift:11` | App masuk ke `LoginView` jika belum login | Reviewer bisa dead-end jika tidak punya akun | Siapkan demo/review account di App Review Notes | Needs Manual Action |

## D. Fixed Issues

- `Sources/App/WeddingAppApp.swift:9`: permission notification tidak lagi diminta saat app launch; sekarang hanya configure delegate.
- `Sources/Features/Auth/LoginView.swift:61`: tombol Phone Sign In dead-end dihapus.
- `Sources/Features/Auth/LoginView.swift:34`: Forgot Password dead-end/comment "coming soon" dihapus dari UI.
- `Sources/Features/Auth/RegisterView.swift:101`: tombol register via Phone kosong dihapus.
- `Sources/Features/Events/EventListView.swift:90`: `WeddingEvent.jenisOptions.first!` diganti fallback aman.
- `Sources/Resources/PrivacyInfo.xcprivacy:1`: privacy manifest ditambahkan untuk penggunaan `UserDefaults`.
- `project.yml`: `PrivacyInfo.xcprivacy` ditambahkan ke daftar resources agar tetap ikut saat project digenerate ulang.
- `WeddingApp.entitlements` + `project.yml`: entitlement `aps-environment` ditambahkan (development di Debug, production di Release config).
- `Sources/Features/Guests/GuestView.swift`: sample tamu dummy dihapus; diganti empty state asli + CTA tambah tamu.
- `Sources/Features/Checklist/ChecklistView.swift`: sample checklist dummy dihapus; diganti empty state asli.

## E. Manual Actions Required

1. Archive dengan Release dari Xcode dan cek exported entitlements: `aps-environment` harus `production`.
2. Siapkan demo account/review account karena app membutuhkan login.
3. Pastikan production API aktif: `https://api.weddingapp.co.id/api/v1`.
4. Isi App Privacy sesuai data nyata: account data, wedding data, guest/contact-like data yang user input, payment/budget records, push token, dan device/session info.
5. Pastikan Privacy Policy URL dan Terms URL hidup: `https://www.weddingapp.co.id/privacy-policy` dan `https://www.weddingapp.co.id/terms`.

## F. App Store Connect Checklist

- App Name: Wedding App
- Category: Lifestyle
- Support URL: wajib tersedia
- Privacy Policy URL: wajib tersedia
- Review Notes: sertakan demo account, alur delete account, dan catatan login Google/Apple
- Screenshots: iPhone sizes utama
- App Privacy: data akun, user content, identifiers/device token jika dipakai
- Age Rating: kemungkinan 4+ jika tidak ada konten sensitif
- Sign in with Apple: entitlement ada dan tombol Apple tersedia

## G. Archive Checklist

| Item | Status |
|---|---|
| Debug/active build | Passed, 0 warning |
| Release build | Needs Manual Action karena terminal sandbox blocked |
| Bundle ID | `com.weddingapp.ios` |
| Version | `1.0` |
| Build Number | `1` |
| Signing | Automatic, Team `LHH9LVRYVY` |
| Capabilities | Push + Sign in with Apple |
| App Icon | 1024x1024 PNG RGB, present |
| Privacy Manifest | Added |
| Production API | Release uses HTTPS production URL |
| Critical Warning | None from Xcode build |
| Guest/Checklist dummy data | Fixed — empty state asli |

## H. Additional Findings (Medium/Low)

Temuan tambahan dari review kode yang belum memblokir submit, tetapi perlu diketahui reviewer:

| Severity | Lokasi | Masalah | Catatan |
|---|---|---|---|
| Medium | `Sources/Features/Vendor/VendorView.swift` | Carousel promo `VendorPromo.samples` selalu hardcoded | Bukan dari API; copy marketing statis |
| Medium | `Sources/Features/Guests/GuestView.swift` | Bagikan undangan, QR check-in, Export data | Tombol memunculkan alert "Coming Soon" |
| Medium | `Sources/Features/More/WeddingDocumentsView.swift` | Filter, upload, scan, share, delete | Mayoritas aksi masih Coming Soon |
| Medium | `Sources/Features/More/PrivacySecurityView.swift` | 2FA, download data, trusted devices | UI ada tetapi belum fungsional penuh |
| Medium | `Sources/Features/Auth/LoginView.swift` | Label masih `Email or Phone` | Validasi hanya email; tidak ada flow OTP telepon |
| Low | `Sources/Features/Dashboard/DashboardView.swift` | `NotificationsSheet` kosong/statik | Bell notifikasi tidak menampilkan riwayat nyata |
| Low | `Sources/Features/Dashboard/InfoTabView.swift`, `SavedInspirationView.swift` | View ter-compile tetapi tidak dinavigasi | Wiring belum selesai |
| Low | `Sources/App/Localization` | `LanguageFeature.isSelectionEnabled = false` | Pilihan bahasa English dinonaktifkan |

## I. Final Recommendation

Boleh lanjut ke **Product -> Archive**, tetapi sebelum **Distribute App -> App Store Connect**:

1. Verifikasi entitlement production push.
2. Siapkan demo account di App Review Notes.
3. Reviewer sebaiknya tidak lagi melihat data tamu/checklist palsu pada akun kosong.

Jangan submit sebelum poin 1 dan 2 beres.

## Validation Performed

- Xcode `BuildProject`: sukses, 0 error, 0 warning.
- Live diagnostics untuk file yang diubah: sukses, tidak ada issue.
- Static search: TODO/FIXME/Coming Soon, insecure URL, force unwrap, fatalError, hardcoded secret, UserDefaults/privacy manifest.
- App icon check: `AppIcon.png` 1024x1024 PNG RGB tersedia.
- Test target: tidak ditemukan test target/unit/UI tests di project, jadi test suite tidak dijalankan.
- Verifikasi ulang: `GuestRowItem.samples` dan `ChecklistGroup.samples` sudah dihapus dari kode.

## Known Limitations

- Simulasi UI manual semua screen tidak dijalankan dari simulator dalam sesi ini.
- Release build via shell gagal karena permission sandbox terhadap cache Xcode/SwiftPM, bukan karena error kompilasi project.
- Third-party SDK privacy manifest perlu diverifikasi saat Archive final dari Xcode/App Store Connect, terutama GoogleSignIn dan dependency transitive.
