# Login Error Cleanup

## Masalah

Login API sempat mengembalikan `200` dan log menunjukkan autentikasi sukses, tetapi aplikasi tetap berada di layar login. Masalah muncul setelah pemasangan splash screen dan perubahan alur root/auth.

## Keputusan

Auth dihapus sementara sesuai permintaan:

- Halaman login/register dihapus.
- `SessionStore` dihapus.
- Apple/Google sign-in service dihapus.
- Keychain token store dihapus.
- Root app langsung membuka dashboard.
- Logout, edit profile auth, change password, active sessions, dan delete account dilepas dari UI.
- API client tidak lagi menyisipkan bearer token.

## Status

Build Xcode berhasil setelah cleanup.
