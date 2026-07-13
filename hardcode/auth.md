# Auth (Login / Register / Lupa Password) — Migrasi L10n

Terakhir dicek: 12 Juli 2026.

## Scope

| Layar | File |
|-------|------|
| Login | `LoginView.swift` |
| Lupa Password (sheet) | `LoginView.swift` → `ForgotPasswordSheet` |
| Register | `RegisterView.swift` |
| Hero branding | `AuthLoginReference.swift` |
| Error Google/Apple | `GoogleSignInService.swift`, `AppleSignInService.swift` |

## Status

**Status migrasi L10n Auth (Login + Forgot + Register UI): DONE** (12 Juli 2026)

## Key baru (selain yang sudah ada)

| Key | ID | EN |
|-----|----|----|
| `auth.hero_tagline` | Rencanakan hari bahagiamu... | Plan your special day... |
| `auth.welcome` | Selamat datang! | Welcome! |
| `auth.login_subtitle` | Masuk untuk melanjutkan... | Sign in to continue... |
| `auth.create_account` | Buat akun baru | Create new account |
| `auth.login_cta` | Masuk ke akun saya | Sign in to my account |
| `auth.email_required` | Email wajib diisi. | Email is required. |
| `auth.forgot_title` | Atur ulang kata sandi | Reset password |
| `auth.forgot_subtitle` | Masukkan email akun Anda... | Enter your account email... |
| `auth.forgot_send` | Kirim instruksi reset | Send reset instructions |
| `auth.forgot_resend` | Kirim ulang instruksi | Resend instructions |
| `auth.forgot_back_to_login` | Kembali ke login | Back to login |
| `auth.forgot_sent` | Jika email terdaftar... | If the email is registered... |
| `auth.back` | Kembali | Back |
| `auth.google_*` / `auth.apple_*` | Pesan error social | Social error messages |

## Sengaja tidak diubah

- Brand label tombol social `Apple` / `Google` (nama provider)
- Glyph `G` pada tombol Google
- Path API `auth/forgot-password`
- SF Symbol names
