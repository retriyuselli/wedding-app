# Audit Final iOS App Store - Wedding App

Tanggal audit: 9 Juli 2026  
Terakhir diperbarui: 9 Juli 2026

> Dokumen ini hanya mencantumkan **temuan yang masih terbuka**. Item yang sudah diperbaiki di kode tidak lagi ditulis di sini.

## A. Executive Summary

| Severity | Count (terbuka) |
|---|---:|
| Critical | 1 |
| High | 1 |
| Medium | 5 |
| Low | 3 |

Build Xcode: 0 error, 0 warning (Debug). Release Archive tetap perlu diverifikasi manual dari Xcode.

## B. App Store Submission Verdict

**READY WITH MINOR ISSUES**

## C. Open Issues

| Severity | Lokasi | Masalah | Solusi | Status |
|---|---|---|---|---|
| Critical | `WeddingApp.entitlements` | File dev masih `aps-environment = development` | Saat **Archive Release**, pastikan exported entitlements memakai `production` (override sudah ada di `project.yml`) | Needs Manual Action |
| High | `Sources/App/RootView.swift` | App wajib login | Siapkan demo/review account di App Review Notes | Needs Manual Action |
| Medium | `Sources/Features/Vendor/VendorView.swift` | Carousel promo `VendorPromo.samples` hardcoded | Ganti dengan data API atau sembunyikan jika kosong | Open |
| Medium | `Sources/Features/Guests/GuestView.swift` | Bagikan undangan, QR check-in, Export data | Masih alert "Coming Soon" | Open |
| Medium | `Sources/Features/More/WeddingDocumentsView.swift` | Filter, upload, scan, share, delete | Mayoritas aksi belum fungsional | Open |
| Medium | `Sources/Features/More/PrivacySecurityView.swift` | 2FA, download data, trusted devices | UI ada, belum fungsional penuh | Open |
| Medium | `Sources/Features/Auth/LoginView.swift` | Label masih `Email or Phone` | Ubah ke `Email` saja (validasi sudah email-only) | Open |
| Low | `Sources/Features/Dashboard/DashboardView.swift` | `NotificationsSheet` kosong/statik | Belum ada riwayat notifikasi in-app | Open |
| Low | `InfoTabView.swift`, `SavedInspirationView.swift` | View tidak dinavigasi | Wiring belum selesai | Open |
| Low | `LanguageFeature.isSelectionEnabled` | English dinonaktifkan | Aktifkan jika ingin dukung bilingual penuh | Open |

## D. Manual Actions Before Submit

1. **Archive Release** → cek exported entitlements: `aps-environment` harus `production`.
2. **Demo account** di App Review Notes (email + password).
3. Production API aktif: `https://api.weddingapp.co.id/api/v1`.
4. App Privacy di App Store Connect sesuai data nyata (akun, konten user, push token, dll.).
5. Privacy Policy & Terms URL hidup:
   - `https://www.weddingapp.co.id/privacy-policy`
   - `https://www.weddingapp.co.id/terms`

## E. App Store Connect Checklist

- App Name: Wedding App
- Category: Lifestyle
- Support URL, Privacy Policy URL: wajib tersedia
- Review Notes: demo account, alur delete account, login Google/Apple
- Screenshots: iPhone sizes utama
- App Privacy: akun, user content, device token
- Sign in with Apple: entitlement + tombol tersedia

## F. Archive Checklist

| Item | Status |
|---|---|
| Debug build | Passed |
| Release Archive | Needs Manual Action |
| Bundle ID | `com.weddingapp.ios` |
| Version / Build | `1.0` / `1` |
| Signing | Automatic, Team `LHH9LVRYVY` |
| Capabilities | Push + Sign in with Apple |
| Production API (Release) | HTTPS production URL |

## G. Final Recommendation

Boleh lanjut **Product → Archive**, tetapi **jangan submit** sebelum:

1. Entitlement push production terverifikasi di Archive Organizer.
2. Demo account disiapkan di App Review Notes.

## Known Limitations

- Release build via terminal tidak divalidasi (sandbox cache Xcode/SwiftPM).
- Tidak ada unit/UI test target di project.
- Privacy manifest SDK pihak ketiga (GoogleSignIn) perlu dicek saat Archive final.
