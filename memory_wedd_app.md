# Wedding App — Memory & Model Reference

> Dibuat: 2026-07-01 | Sumber: `copy_model/` (22 file PHP)
> **File ini adalah pusat pengetahuan (single source of truth) aplikasi.** Semua informasi, keputusan, dan catatan pengembangan diletakkan di sini.

---

## Prinsip & Konteks Pengembangan

- **Bahasa:** Semua informasi, dokumentasi, dan komunikasi yang keluar **wajib menggunakan Bahasa Indonesia**.
- **Backend:** Aplikasi ini menggunakan **Filament (v5)** sebagai backend / panel admin. Pengelolaan data, konfirmasi, verifikasi, dan operasi administratif dilakukan melalui Filament.
- **Target aplikasi:** Pengembangan diarahkan untuk **aplikasi iOS (`ios-app/`)**. Folder sudah tersedia dan bisa diakses.
- **Tooling iOS:** Pengembangan `ios-app` saat ini menggunakan **Xcode** (dengan `xcodegen` untuk generate project). Harapannya backend (Filament + REST API) dan iOS app bisa **bersinergi** — pengembangan lebih baik, lebih cepat, dan memudahkan pengguna di sisi iOS.
- **Alur kerja ideal:** Backend Filament mengelola data & fitur admin → REST API v1 (Sanctum) menjadi jembatan → iOS app mengonsumsi API tersebut untuk pengalaman pengguna native.
- **Alur kerja Cursor + Xcode:** Perubahan kode dilakukan di **Cursor**; di sisi **Xcode cukup tekan Run (⌘R)** untuk melihat hasilnya. Tidak perlu setup ulang setiap kali ada perubahan kecil.
- **Pusat catatan:** Setiap ada perkembangan, keputusan teknis, atau pengetahuan baru tentang aplikasi, catat di file ini agar tidak tercecer.

### Alur Kerja Harian: Cursor → Xcode (Run Saja)

| Jenis perubahan di Cursor | Di Xcode | Catatan |
|---|---|---|
| Edit file Swift yang sudah ada di `Sources/` | **Run (⌘R) saja** | Xcode otomatis membaca perubahan dari disk |
| Perubahan backend (PHP, API, model) | **Run (⌘R) saja** di iOS | Pastikan `php artisan serve --host=0.0.0.0` masih jalan |
| Tambah file Swift **baru** di `Sources/` | Run setelah regenerate | Jalankan `cd ios-app/WeddingApp && xcodegen generate` sekali, lalu Run |
| Ubah `project.yml` (target, signing, Info.plist) | Run setelah regenerate | Sama: `xcodegen generate` lalu Run |
| Tambah asset/font baru | Run setelah regenerate | Daftarkan di `project.yml` jika perlu, lalu `xcodegen generate` |

**Prinsip:** Untuk pekerjaan sehari-hari (edit view, model, networking, styling), Cursor mengubah file → buka Xcode → **Run**. Itu saja.

**Prasyarat sebelum Run:**
1. Backend Laravel jalan (`php artisan serve --host=0.0.0.0` untuk device fisik, atau default untuk Simulator).
2. Xcode sudah buka project `ios-app/WeddingApp/WeddingApp.xcodeproj`.
3. Scheme `WeddingApp` + target device (Simulator atau iPhone fisik) sudah dipilih.

---

## Stack Teknologi

| Layer | Package | Versi |
|---|---|---|
| Backend | Laravel | v13 |
| PHP | PHP | 8.4 |
| Admin UI | Filament | v5 |
| Frontend reactive | Livewire | v4 |
| CSS | Tailwind CSS | v4 |
| Auth token | Laravel Sanctum | — |
| Roles & permissions | Spatie Permission | — |
| Activity log | Spatie Activitylog | — |

---

## Daftar Model (`App\Models`)

### 1. `User`
File: `copy_model/User.php`

- Extends `Authenticatable`, implements `FilamentUser`, `HasAvatar`, `MustVerifyEmail`
- Traits: `HasApiTokens`, `HasFactory`, `HasRoles`, `Notifiable`, `LogsActivity`
- **Fillable:** `name`, `email`, `password`, `avatar_url`, `apple_id`, `theme_color`, `email_verified_at`, `whatsapp`, `notification_settings`
- **Hidden:** `password`, `remember_token`
- **Casts:** `email_verified_at` → datetime, `password` → hashed, `notification_settings` → array
- **Methods:** `isAdmin()`, `isVendor()`, `avatarUrl()`, `canAccessPanel()`
- **Relasi HasOne:** `weddingInfo`, `weddingBudget`
- **Relasi HasMany:** `vendorReviews`, `vendorBookings`, `wishlists`, `deviceTokens`, `familyMembers`, `paymentMethods`, `paymentSchedules` (order by due_date), `incomingPayments` (order desc transfer_date), `customerNotifications`, `preparationSections` (order by sort_order), `weddingEvents` (order by tgl_acara), `vipGuests`
- **Relasi BelongsToMany:** `likedVendors` (via `vendor_user_likes`), `wishlistedPackages` (via `wishlists`)
- **Catatan:** setter `whatsapp` memanggil `VendorBooking::normalizeWhatsappNumber()`

---

### 2. `WeddingInfo`
File: `copy_model/WeddingInfo.php`

- **Fillable:** `user_id`, `groom_name`, `bride_name`, `budaya`, `songlist`
- **Casts:** `songlist` → array
- **Relasi:** `user` (BelongsTo), `events` (HasMany WeddingEvent via user_id), `familyMembers` (HasMany via user_id), `budget` (HasOne WeddingBudget via user_id)
- **HasManyThrough:** `preparationTasks` → CustomerPreparationTask via WeddingEvent (FK: user_id → wedding_event_id)

---

### 3. `WeddingEvent`
File: `copy_model/WeddingEvent.php`

- **Fillable:** `user_id`, `jenis_acara`, `tgl_acara`, `lokasi_acara`, `vendor_booking_id`, `catatan`
- **Casts:** `tgl_acara` → date
- **Static:** `$jenisOptions` → `['lamaran', 'pengajian', 'akad', 'resepsi']`
- **Relasi:** `user`, `vendorBooking` (BelongsTo), `preparationTasks` (HasMany, order by sort_order)
- **Accessor:** `getJenisLabelAttribute()`

---

### 4. `VendorBooking`
File: `copy_model/VendorBooking.php`

- Traits: `HasFactory`, `LogsActivity`
- **Fillable:** `vendor_id`, `user_id`, `vendor_package_id`, `agreed_total`, `dp_required_amount`, `promo_code`, `promo_discount`, `event_date`, `phone`, `notes`, `status`, `payment_status`
- **Casts:** `event_date` → date
- **Static method:** `normalizeWhatsappNumber($value)` — normalisasi nomor HP ke format `62xxx` (dipakai juga di User::setWhatsappAttribute)
- **Relasi:** `vendor`, `user`, `vendorPackage` (BelongsTo), `payments` (HasMany VendorBookingPayment)
- **Activity log:** mencatat `status`, `vendor_package_id`, `event_date`, `agreed_total`

---

### 5. `VendorBookingPayment`
File: `copy_model/VendorBookingPayment.php`

- **Fillable:** `vendor_booking_id`, `type`, `due_date`, `amount`, `method`, `sender_name`, `sender_bank`, `paid_at`, `proof_path`, `status`, `verified_by`, `verified_at`, `note`
- **Casts:** `amount` → integer, `due_date` → date, `paid_at` / `verified_at` → datetime
- **Relasi:** `booking` (BelongsTo VendorBooking), `verifiedBy` (BelongsTo User)
- **Accessor:** `getProofUrlAttribute()` — generate URL dari `proof_path`, support storage atau URL eksternal

---

### 6. `VendorReview`
File: `copy_model/VendorReview.php`

- **Fillable:** `vendor_id`, `user_id`, `reviewer_name`, `reviewer_avatar`, `rating`, `body`, `photo`, `admin_reply`, `admin_reply_by`, `admin_replied_at`, `reviewed_at`, `is_approved`, `reviewer_ip`
- **Casts:** `rating` → integer, `admin_replied_at` → datetime, `reviewed_at` → date, `is_approved` → boolean
- **Relasi:** `vendor`, `user`, `adminReplyBy` (BelongsTo User via `admin_reply_by`)

---

### 7. `ChatSession`
File: `copy_model/ChatSession.php`

- **Fillable:** `user_id`, `guest_name`, `session_token`, `status`, `type`, `vendor_id`, `vendor_package_id`
- **Relasi:** `messages` (HasMany ChatMessage), `vendor`, `vendorPackage`, `user` (BelongsTo), `latestMessage` (HasOne, latestOfMany)

---

### 8. `ChatMessage`
File: `copy_model/ChatMessage.php`

- **Fillable:** `chat_session_id`, `sender`, `message`, `admin_user_id`, `vendor_package_id`
- **Relasi:** `vendorPackage`, `session` (BelongsTo ChatSession), `adminUser` (BelongsTo User via `admin_user_id`)

---

### 9. `VipGuest`
File: `copy_model/VipGuest.php`

- **Fillable:** `user_id`, `no`, `name`, `jabatan`, `instansi`, `phone`, `kategori`, `rsvp_status`, `rsvp_updated_by_name`, `rsvp_updated_at`, `catatan`
- **Static:** `$kategoriOptions` → `vip`, `keluarga_besar`, `pejabat`, `tokoh_masyarakat`, `rekan_bisnis`, `teman`
- **Static:** `$rsvpOptions` → `menunggu`, `hadir`, `tidak_hadir`
- **Relasi:** `user` (BelongsTo)

---

### 10. `VipGuestDelegate`
File: `copy_model/VipGuestDelegate.php`

- **Fillable:** `user_id`, `claimed_by_user_id`, `name`, `token`, `expires_at`, `last_accessed_at`
- **Casts:** `expires_at`, `last_accessed_at` → datetime
- **Static method:** `generateToken()` — generate random 48-char unique token
- **Methods:** `isExpired()`, `isActive()`
- **Relasi:** `user`, `claimedBy` (BelongsTo User via `claimed_by_user_id`)

---

### 11. `WeddingBudget`
File: `copy_model/WeddingBudget.php`

- **Fillable:** `user_id`, `total_budget`, `currency`, `notes`
- **Casts:** `total_budget` → decimal:2
- **Relasi:** `user` (BelongsTo)

---

### 12. `WeddingPaymentSchedule`
File: `copy_model/WeddingPaymentSchedule.php`

- **Fillable:** `user_id`, `wedding_event_id`, `source_template_id`, `title`, `vendor_name`, `category`, `amount`, `due_date`, `status`, `paid_at`, `customer_payment_method_id`, `proof_url`, `notes`, `sort_order`
- **Casts:** `amount` → decimal:2, `due_date` → date, `paid_at` → datetime
- **Boot hook:** saat `retrieved`, jika `status = pending` dan `due_date` sudah lewat → auto-update ke `overdue` (via `updateQuietly`)
- **Kategori:** `venue`, `catering`, `decoration`, `photo_video`, `entertainment`, `makeup`, `transport`, `wo`
- **Accessor:** `getCategoryLabelAttribute()`, `getCategoryIconAttribute()` (SF Symbols icons)
- **Relasi:** `user`, `weddingEvent`, `sourceTemplate` (BelongsTo WeddingPaymentScheduleTemplate), `paymentMethod` (BelongsTo CustomerPaymentMethod)

---

### 13. `WeddingPaymentScheduleTemplate`
File: `copy_model/WeddingPaymentScheduleTemplate.php`

- **Fillable:** `jenis_acara`, `title`, `vendor_name`, `category`, `amount`, `due_days_before_event`, `notes`, `sort_order`, `is_active`
- **Casts:** `amount` → decimal:2, `due_days_before_event` / `sort_order` → integer, `is_active` → boolean
- **Static:** `$jenisOptions` (sama dengan WeddingEvent)
- **Relasi:** `schedules` (HasMany WeddingPaymentSchedule via `source_template_id`)

---

### 14. `WeddingIncomingPayment`
File: `copy_model/WeddingIncomingPayment.php`

- **Fillable:** `user_id`, `bank_name`, `amount`, `transfer_date`, `sender_name`, `description`, `reference_number`, `proof_url`, `status`, `confirmed_at`, `confirmed_by`, `rejection_reason`, `notes`
- **Casts:** `amount` → decimal:2, `transfer_date` → date, `confirmed_at` → datetime
- **Status:** `confirmed` = Dikonfirmasi | `rejected` = Ditolak | default = Menunggu
- **Accessor:** `getStatusLabelAttribute()`
- **Relasi:** `user` (BelongsTo)

---

### 15. `CustomerPreparationSection`
File: `copy_model/CustomerPreparationSection.php`

- **Fillable:** `user_id`, `title`, `icon`, `sort_order`
- **Relasi:** `user` (BelongsTo), `tasks` (HasMany CustomerPreparationTask via `section_id`, order by sort_order)

---

### 16. `CustomerPreparationTask`
File: `copy_model/CustomerPreparationTask.php`

- **Fillable:** `wedding_event_id`, `section_id`, `label`, `user_id`, `title`, `status`, `due_date`, `sort_order`
- **Casts:** `due_date` → date
- **Relasi:** `weddingEvent` (BelongsTo WeddingEvent), `user` (BelongsTo)

---

### 17. `CustomerNotification`
File: `copy_model/CustomerNotification.php`

- **Fillable:** `user_id`, `group`, `title`, `message`, `icon`, `destination`, `tint`, `is_unread`
- **Casts:** `is_unread` → boolean
- **Relasi:** `user` (BelongsTo)

---

### 18. `CustomerPaymentMethod`
File: `copy_model/CustomerPaymentMethod.php`

- **Fillable:** `user_id`, `name`, `logo_icon`, `account_number`, `account_name`, `is_primary`, `type`
- **Casts:** `is_primary` → boolean
- **Relasi:** `user` (BelongsTo)

---

### 19. `FamilyMember`
File: `copy_model/FamilyMember.php`

- **Fillable:** `user_id`, `no`, `name`, `role`, `phone`, `rsvp_status`, `rsvp_updated_by_name`, `rsvp_updated_at`
- **Casts:** `rsvp_updated_at` → datetime
- **Static:** `$rsvpOptions` → `menunggu`, `hadir`, `tidak_hadir`
- **Relasi:** `user` (BelongsTo)

---

### 20. `DeviceToken`
File: `copy_model/DeviceToken.php`

- **Fillable:** `user_id`, `token`, `platform`
- **Relasi:** `user` (BelongsTo)
- **Fungsi:** menyimpan push notification token per device per user

---

### 21. `UserBlock`
File: `copy_model/UserBlock.php`

- **Fillable:** `blocker_id`, `blocked_id`
- **Relasi:** `blocker` (BelongsTo User), `blocked` (BelongsTo User)

---

### 22. `Wishlist`
File: `copy_model/Wishlist.php`

- **Fillable:** `user_id`, `vendor_package_id`
- Traits: `LogsActivity`
- **Relasi:** `user`, `vendorPackage` (BelongsTo)

---

## Peta Relasi Utama

```
User
 ├── hasOne  → WeddingInfo
 │              └── hasManyThrough → CustomerPreparationTask (via WeddingEvent)
 ├── hasOne  → WeddingBudget
 ├── hasMany → WeddingEvent
 │              └── hasMany → CustomerPreparationTask
 ├── hasMany → VendorBooking
 │              └── hasMany → VendorBookingPayment
 ├── hasMany → VendorReview
 ├── hasMany → WeddingPaymentSchedule
 ├── hasMany → WeddingIncomingPayment
 ├── hasMany → CustomerPreparationSection
 │              └── hasMany → CustomerPreparationTask
 ├── hasMany → CustomerNotification
 ├── hasMany → CustomerPaymentMethod
 ├── hasMany → FamilyMember
 ├── hasMany → VipGuest
 ├── hasMany → DeviceToken
 ├── hasMany → Wishlist
 ├── belongsToMany → Vendor (via vendor_user_likes)
 └── belongsToMany → VendorPackage (via wishlists)

ChatSession
 ├── hasMany → ChatMessage
 ├── hasOne  → ChatMessage (latestMessage)
 └── belongsTo → User, Vendor, VendorPackage

VipGuestDelegate
 └── belongsTo → User (user + claimedBy)

WeddingPaymentScheduleTemplate
 └── hasMany → WeddingPaymentSchedule
```

---

## Update Log — 2026-07-01

### 1. Seeder & Factory (semua model saat ini)

- Factory dibuat untuk 11 model yang belum punya (`User` sudah ada sebelumnya): `WeddingInfo`, `WeddingEvent`, `WeddingBudget`, `CustomerPaymentMethod`, `WeddingPaymentSchedule`, `WeddingIncomingPayment`, `CustomerPreparationSection`, `CustomerPreparationTask`, `FamilyMember`, `VipGuest`, `Guest`, `CustomerNotification`.
- Trait `HasFactory` ditambahkan ke `WeddingBudget`, `WeddingPaymentSchedule`, `WeddingIncomingPayment` (belum ada sebelumnya).
- 13 seeder dibuat di `database/seeders/`, dipanggil berurutan dari `DatabaseSeeder` sesuai dependency FK: `UserSeeder` (3 user) → `WeddingInfoSeeder` → `WeddingEventSeeder` → `WeddingBudgetSeeder` → `CustomerPaymentMethodSeeder` → `WeddingPaymentScheduleSeeder` → `WeddingIncomingPaymentSeeder` → `CustomerPreparationSectionSeeder` → `CustomerPreparationTaskSeeder` → `FamilyMemberSeeder` → `VipGuestSeeder` → `GuestSeeder` → `CustomerNotificationSeeder`.
- Sudah dites jalan (`php artisan db:seed`) tanpa error.

### 2. REST API v1 — untuk aplikasi iOS (dibangun di Xcode)

**Catatan penting:** model yang di-expose lewat API ini hanya 12 model yang sudah *live* di `app/Models` sekarang (lihat daftar di atas, model no. 2, 3, 11, 12, 14–19). Model-model dari referensi `copy_model/` yang **belum diimplementasikan** di app ini (jadi **belum ada endpoint-nya**): `VendorBooking`, `VendorBookingPayment`, `VendorReview`, `ChatSession`, `ChatMessage`, `VipGuestDelegate`, `WeddingPaymentScheduleTemplate`, `DeviceToken`, `UserBlock`, `Wishlist`. Kalau fitur-fitur itu mau dibangun di iOS app, backend-nya harus dibuat dulu.

#### Setup backend

- Auth pakai **Laravel Sanctum** (token, bukan session) — diinstall via `php artisan install:api`.
- Trait `HasApiTokens` ditambahkan ke model `User`.
- Semua controller ada di `app/Http/Controllers/Api/V1/`, resource transformer di `app/Http/Resources/V1/`.
- Semua query di-scope otomatis ke user yang login (`where('user_id', $request->user()->id)` / relasi `$request->user()->xxx()`) — user A tidak bisa baca/ubah/hapus data user B (sudah dites → 404, bukan data bocor).

#### Base URL

```
http://127.0.0.1:8000/api/v1
```

- Dari **iOS Simulator**: `127.0.0.1` bisa langsung dipakai.
- Dari **device fisik**: ganti host dengan IP LAN Mac (mis. `192.168.1.x`), karena device fisik tidak bisa resolve `127.0.0.1` ke Mac kamu.
- Server ini masih **HTTP**, bukan HTTPS. iOS App Transport Security (ATS) akan menolak request HTTP secara default. Untuk development, tambahkan di `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

  (Untuk production nanti, backend harus di-deploy dengan HTTPS supaya exception ini tidak dipakai.)

- Tidak perlu setup CORS — itu cuma berlaku untuk browser/JS, `URLSession` di iOS tidak kena CORS.

#### Auth flow

1. `POST /auth/register` atau `POST /auth/login` — body wajib sertakan `device_name` (string bebas, mis. `"iPhone 17 milik Budi"`) selain `name`/`email`/`password` (register) atau `email`/`password` (login).
2. Response: `{ "user": {...}, "token": "1|xxxxx..." }`. Simpan `token` di **Keychain** (jangan UserDefaults — token setara password).
3. Semua request setelah itu wajib header: `Authorization: Bearer <token>` + `Accept: application/json`.
4. `POST /auth/logout` — revoke token yang sedang dipakai (device itu saja, bukan semua device).
5. `GET /auth/me` — ambil profil user yang lagi login (dipakai buat cek token masih valid saat app dibuka).
6. Request tanpa token / token invalid → `401`.

#### Format response

- Single resource: `{ "data": { ...field } }`
- Collection: `{ "data": [ {...}, {...} ] }`
- Error validasi (422): `{ "message": "...", "errors": { "field_name": ["pesan error"] } }`
- Delete berhasil: `204 No Content` (tanpa body)
- Akses data user lain / record tidak ditemukan: `404`

#### Daftar endpoint

| Resource | Method & Path | Body fields (create/update) | Aksi tambahan |
|---|---|---|---|
| Auth | `POST /auth/register` | `name, email, password, password_confirmation, device_name` | — |
| Auth | `POST /auth/login` | `email, password, device_name` | — |
| Auth | `POST /auth/logout`, `GET /auth/me` | — | butuh token |
| Wedding Info (singleton) | `GET/PUT /wedding-info` | `groom_name, bride_name, budaya, songlist[]` (semua nullable) | — |
| Wedding Budget (singleton) | `GET/PUT /wedding-budget` | `total_budget (required), currency, notes` | — |
| Wedding Events | `GET/POST /wedding-events`, `GET/PUT/DELETE /wedding-events/{id}` | `jenis_acara (required, in: lamaran/pengajian/akad/resepsi), tgl_acara, lokasi_acara, catatan` | — |
| Payment Methods | `GET/POST /customer-payment-methods`, `GET/PUT/DELETE /customer-payment-methods/{id}` | `name (required), logo_icon, account_number, account_name, is_primary, type` | set `is_primary=true` otomatis un-primary-kan yang lain |
| Payment Schedules | `GET/POST /wedding-payment-schedules`, `GET/PUT/DELETE /wedding-payment-schedules/{id}` | `title (required), vendor_name, category, amount (required), due_date, status, notes, sort_order, wedding_event_id, customer_payment_method_id` | `PATCH .../{id}/mark-paid` |
| Incoming Payments | `GET/POST /wedding-incoming-payments`, `GET/PUT/DELETE /wedding-incoming-payments/{id}` | `bank_name, amount (required), transfer_date (required), sender_name (required), description, reference_number, notes` | status selalu `menunggu` saat dibuat lewat API (konfirmasi/tolak hanya dari panel admin Filament) |
| Preparation Sections | `GET/POST /customer-preparation-sections`, `GET/PUT/DELETE /customer-preparation-sections/{id}` | `title (required), icon, sort_order` | response include `tasks[]` |
| Preparation Tasks | `GET/POST /customer-preparation-tasks`, `GET/PUT/DELETE /customer-preparation-tasks/{id}` | `title (required), label, status, due_date, sort_order, wedding_event_id, section_id` | `PATCH .../{id}/toggle` (pending ↔ done); filter index via `?wedding_event_id=` / `?section_id=` |
| Family Members | `GET/POST /family-members`, `GET/PUT/DELETE /family-members/{id}` | `name (required), no, role, phone, rsvp_status` | `PATCH .../{id}/rsvp` body `{rsvp_status}` |
| VIP Guests | `GET/POST /vip-guests`, `GET/PUT/DELETE /vip-guests/{id}` | `name (required), no, jabatan, instansi, phone, kategori, rsvp_status, catatan` | `PATCH .../{id}/rsvp` |
| Guests (umum) | `GET/POST /guests`, `GET/PUT/DELETE /guests/{id}` | `name (required), phone, email, table_number, rsvp_status, catatan` | `PATCH .../{id}/rsvp` |
| Notifications | `GET /customer-notifications`, `GET/DELETE /customer-notifications/{id}` | — (read-only, dibuat sistem) | `PATCH .../{id}/mark-read`; filter `?unread_only=1` |

`rsvp_status` valid values: `menunggu`, `hadir`, `tidak_hadir`.

#### Tips implementasi Swift/Xcode

- Semua response pakai `snake_case` key (`groom_name`, `rsvp_status`, dst) — set `JSONDecoder().keyDecodingStrategy = .convertFromSnakeCase`, atau definisikan `CodingKeys` manual kalau nama field di Swift beda jauh dari Indonesia (mis. `jenis_acara`).
- Tanggal (`tgl_acara`, `due_date`, `transfer_date`) dikirim sebagai string `YYYY-MM-DD`; timestamp (`created_at`, `paid_at`, `confirmed_at`, `rsvp_updated_at`) pakai format ISO8601 dengan microseconds (`2026-07-01T15:19:52.000000Z`) — pakai custom `DateFormatter`/`ISO8601DateFormatter` dengan `.withFractionalSeconds`, formatter bawaan Swift `.iso8601` strategy default **tidak** langsung cocok karena ada microseconds.
- Field numerik seperti `amount`, `total_budget` dikirim sebagai JSON number (bukan string) — decode sebagai `Double` di Swift.
- Struct request "create/update" tidak perlu semua field wajib diisi — banyak yang nullable, cukup omit key yang tidak dipakai (jangan kirim `null` eksplisit kalau tidak perlu).
- Simpan token di Keychain (mis. pakai `KeychainAccess` package atau `Security` framework langsung), bukan `UserDefaults`.
- Cek token valid saat app dibuka dengan hit `GET /auth/me`; kalau `401`, arahkan balik ke layar login.

---

## Update Log — 2026-07-01 (lanjutan): iOS App (Xcode) Scaffold

Dibuat aplikasi iOS skeleton di folder baru **`ios-app/WeddingApp/`** (root repo, sejajar dengan `app/`, `routes/`, dll — bukan bagian dari struktur Laravel) yang mengonsumsi REST API v1 di atas. Sudah **berhasil di-build & dijalankan** di iOS Simulator (Xcode 26.6, target iOS 17, device iPhone 17).

### Struktur folder

```
ios-app/WeddingApp/
├── project.yml                  ← spec untuk xcodegen (generate .xcodeproj)
├── WeddingApp.xcodeproj          ← di-generate otomatis, JANGAN edit manual — edit project.yml lalu `xcodegen generate` ulang
└── Sources/
    ├── App/
    │   ├── WeddingAppApp.swift       (entry point @main)
    │   └── RootView.swift            (switch Login ⇄ Dashboard berdasar session)
    ├── Networking/
    │   ├── APIConfig.swift           (base URL: http://127.0.0.1:8000/api/v1)
    │   ├── APIClient.swift           (URLSession wrapper, generic request<T:Decodable>, Bearer token, decode snake_case + tanggal ISO8601/simple date)
    │   ├── KeychainStore.swift       (simpan/hapus token di Keychain)
    │   └── APIError.swift
    ├── Models/
    │   ├── Envelope.swift            (decode wrapper `{"data": ...}` bawaan Laravel JsonResource)
    │   ├── User.swift                (+ AuthResponse untuk register/login)
    │   ├── WeddingInfo.swift
    │   ├── WeddingBudget.swift
    │   ├── WeddingEvent.swift
    │   └── Guest.swift
    └── Features/
        ├── Auth/  → SessionStore.swift (ObservableObject state auth), LoginView.swift, RegisterView.swift
        ├── Dashboard/ → DashboardView.swift (TabView), InfoTabView.swift (wedding info + budget, editable + tombol Keluar)
        ├── Events/ → EventListView.swift (list + tambah + hapus wedding event)
        └── Guests/ → GuestListView.swift (list + tambah + hapus + ubah RSVP tamu)
```

**Model & screen yang BELUM dibuat di app iOS** (endpoint API-nya sudah ada, tinggal ditambah View-nya kalau perlu): `CustomerPaymentMethod`, `WeddingPaymentSchedule`, `WeddingIncomingPayment`, `CustomerPreparationSection/Task`, `FamilyMember`, `VipGuest`, `CustomerNotification`. Pola yang dipakai di `EventListView.swift` / `GuestListView.swift` (load via `Envelope<[Model]>`, tambah via POST, hapus via `onDelete` + `requestNoContent`) bisa dicontek langsung untuk resource-resource ini.

### Cara menjalankan ulang / lanjutkan development

1. Pastikan backend jalan: `php artisan serve` (sudah auto-jalan di port 8000 di sesi ini — cek dengan `lsof -iTCP:8000`).
2. Kalau ubah `project.yml` (nambah file baru, dsb): `cd ios-app/WeddingApp && xcodegen generate` untuk regenerate `.xcodeproj`. **File Swift baru harus ditambahkan lewat folder `Sources/` — xcodegen otomatis mendeteksi semua file di situ**, tidak perlu edit project.yml kecuali menambah target/setting baru.
3. Buka `ios-app/WeddingApp/WeddingApp.xcodeproj` di Xcode, pilih scheme `WeddingApp`, pilih simulator (mis. iPhone 17), tekan Run (⌘R). Atau via CLI:
   ```
   xcodebuild -project WeddingApp.xcodeproj -scheme WeddingApp -destination 'platform=iOS Simulator,name=iPhone 17' build
   xcrun simctl boot "iPhone 17"; open -a Simulator
   xcrun simctl install "iPhone 17" <path-.app-hasil-build-di-DerivedData>
   xcrun simctl launch "iPhone 17" com.weddingapp.ios
   ```
4. Login test pakai user hasil seeder: `test@example.com` / `password` (sudah di-prefill di LoginView untuk mempercepat testing).

### Keputusan teknis penting

- **Code signing dimatikan** (`CODE_SIGNING_ALLOWED: NO`, `CODE_SIGNING_REQUIRED: NO` di `project.yml`) supaya bisa di-build tanpa Apple Developer account — cukup untuk run di Simulator. Kalau nanti mau run di **device fisik**, wajib set `DEVELOPMENT_TEAM` ke Team ID asli dan aktifkan code signing lagi.
- **Base URL `127.0.0.1`** hanya jalan di Simulator (share network stack dengan Mac). Untuk device fisik ganti ke IP LAN Mac di `APIConfig.swift`.
- **ATS** (`NSAllowsArbitraryLoads: true`) di-set di `project.yml` → auto masuk ke Info.plist yang di-generate xcodegen, supaya HTTP (bukan HTTPS) diizinkan selama development.
- Verifikasi dilakukan 2 lapis: (1) `xcodebuild` build sukses + app ke-install & launch di simulator + screenshot menunjukkan LoginView tampil benar; (2) `curl` langsung ke endpoint `auth/login`, `wedding-info`, `guests` dari terminal untuk memastikan bentuk JSON persis cocok dengan model Swift (`Envelope<T>`, `AuthResponse`, dst) — **tap manual tombol "Masuk" di Simulator belum otomatis diverifikasi** karena automation UI (AppleScript/System Events) butuh izin Accessibility yang belum diberikan ke terminal; tinggal klik manual di window Simulator yang sudah terbuka untuk cek end-to-end.

---

## Update Log — 2026-07-01 (lanjutan 2): Run di iPhone Fisik

Awalnya project di-set `CODE_SIGNING_ALLOWED: NO` (Simulator-only, tanpa akun Apple Developer). User memilih device fisik di Xcode → error `LaunchExecutableValidationErrorDomain` ("The executable is not codesigned") karena device fisik **selalu** wajib code signing, beda dengan Simulator.

### Perubahan yang dibuat

1. **`project.yml`** — ganti dari signing manual/off ke `CODE_SIGN_STYLE: Automatic` (hapus override `CODE_SIGNING_ALLOWED/REQUIRED`, `CODE_SIGN_IDENTITY`, `DEVELOPMENT_TEAM`). Xcode akan otomatis sign pakai Apple ID yang login — **user tetap harus pilih Team-nya sendiri secara manual** di tab *Signing & Capabilities* karena Team ID Apple ID personal tidak bisa diketahui/diisi dari sini.
2. **`APIConfig.swift`** — base URL sekarang otomatis berbeda tergantung environment pakai `#if targetEnvironment(simulator)`: Simulator tetap `127.0.0.1:8000`, device fisik pakai `192.168.1.3:8000` (LAN IP Mac saat ini — **akan berubah kalau Mac pindah jaringan WiFi**, cek ulang dengan `ipconfig getifaddr en0` dan update `lanHost` di file itu kalau IP-nya berbeda).
3. **`php artisan serve` di-restart** dengan `--host=0.0.0.0` (sebelumnya default `127.0.0.1` yang cuma bisa diakses dari Mac itu sendiri, tidak bisa diakses device lain di jaringan yang sama). Sudah dites `curl http://192.168.1.3:8000/up` dari Mac → 200 OK.

### Langkah yang HARUS dilakukan manual oleh user di Xcode (tidak bisa diotomatisasi dari sini)

1. Colokkan iPhone via kabel (atau pairing WiFi), pastikan sudah **Trust This Computer** di iPhone.
2. Di iPhone: **Settings → Privacy & Security → Developer Mode** → aktifkan (device akan restart).
3. Di Xcode: klik target `WeddingApp` → tab **Signing & Capabilities** → centang "Automatically manage signing" → pilih **Team** (Apple ID personal juga bisa, gratis; kalau belum ada, tambah dulu di Xcode → Settings → Accounts).
4. Pilih device fisik itu di dropdown scheme (bukan Simulator), tekan Run (⌘R).
5. Kalau muncul error "Untrusted Developer" di iPhone saat pertama kali run: **Settings → General → VPN & Device Management** di iPhone → pilih profile developer-nya → Trust.
6. **Wajib: iPhone dan Mac harus terhubung ke WiFi yang sama** supaya `192.168.1.3:8000` bisa diakses dari iPhone. Kalau beda jaringan (mis. iPhone pakai data seluler), request API akan gagal/timeout.

### Catatan tambahan

- Signing "Automatic" ini **tidak mengganggu build ke Simulator** — sudah dites ulang, `xcodebuild ... -destination 'platform=iOS Simulator,...'` tetap **BUILD SUCCEEDED** (Simulator pakai signing "Sign to Run Locally" otomatis, tidak butuh Team).
- Kalau `php artisan serve` di-restart lagi manual (mis. setelah reboot Mac), ingat pakai `--host=0.0.0.0`, bukan default, supaya device fisik tetap bisa akses.

---

## Update Log — 2026-07-03: Home iOS Dibuat Sesuai Desain Referensi

Tampilan **Home** iOS (`Sources/Features/Dashboard/DashboardView.swift`) disamakan 100% dengan mockup desain (gambar referensi dari user). Semua perubahan hanya mengedit file yang sudah ada → **cukup Run (⌘R) di Xcode**, tidak perlu `xcodegen generate`.

### Perubahan

1. **Wedding Progress card** — `ProgressStatRow` ditambah chevron `>` di kanan tiap baris (Completed / In Progress / To Do), sesuai desain.
2. **Quote card** — didesain ulang: teks rata tengah, tanda kutip emas di tengah atas, ornamen daun di kiri & kanan pakai SF Symbols `laurel.leading` / `laurel.trailing` (opacity emas), 3 dot indikator di bawah tengah. (Sebelumnya rata kiri + 1 daun di kanan.)
3. **Quick Actions card** (BARU) — kartu putih berisi 5 tombol bulat: `Tasks` (list.clipboard → tab Checklist), `Vendors` (storefront → More), `Inspiration` (heart → More), `Budget` (creditcard → tab Budget), `Messages` (bubble.left → More). Struct baru `QuickActionButton` + section `quickActionsCard`.
4. **Next Up** — ikon "Venue Meeting" diganti ke `person.2`; background badge "In X days" diubah dari gold tint ke `lightSage` (abu-hijau muda) sesuai desain.
5. **Tab bar** — label `Guests` → `Guest`; ikon Budget `dollarsign.circle` → `creditcard`, ikon More `ellipsis.circle` → `ellipsis` (titik tiga polos).

### Verifikasi

- `xcodebuild ... -destination 'platform=iOS Simulator,name=iPhone 17' build` → **BUILD SUCCEEDED**.
- SF Symbols yang dipakai tersedia di target iOS 17: `laurel.leading/trailing`, `list.clipboard`, `storefront`, `person.2`, `birthday.cake`, `figure.dress.line.vertical.figure`.
- Data card (nama pasangan, tanggal, lokasi, hitung mundur hari) tetap **data-driven dari API**; angka progress (68% / 34 / 12 / 14) & item "Next Up"/quote masih **placeholder statis** — belum ada endpoint progress/checklist khusus, jadi ini yang perlu di-wire ke API berikutnya.

---

## Update Log — 2026-07-03 (lanjutan): Kalibrasi Ukuran Teks Home iOS

User membandingkan render iOS dengan mockup → teks di app terasa **terlalu besar** dan proporsinya beda ("Wedding App" hampir selebar layar, di mockup ~53%).

### Diagnosis font

- Font **Poppins TERMUAT dengan benar** — file `.ttf` ada di `Sources/Resources/Fonts/`, ter-bundle ke `WeddingApp.app`, dan terdaftar di `UIAppFonts` (Info.plist). Jadi app memang sudah render Poppins (bukan fallback ke SF).
- Mockup juga bergaya geometric sans (Poppins-like), jadi **Poppins dipertahankan** — mengganti ke font sistem justru akan makin beda dari mockup. (`CormorantGaramond.ttf` ada di folder tapi belum didaftarkan di `UIAppFonts`, jadi belum bisa dipakai.)
- Kesimpulan: masalah utama = **ukuran teks & tinggi header**, bukan jenis font.

### Perubahan ukuran (semua di `DashboardView.swift`)

| Elemen | Lama → Baru |
|---|---|
| Header "Welcome to" | 21 → 17 |
| Judul "Wedding App" | 48 → 38 |
| "Plan beautifully..." | 22 → 15 |
| Tinggi frame header | 268 → 210, padding top 58 → 50 |
| Nama pasangan | 36 → 24 (medium) |
| Label tanggal/lokasi | 15 → 13 |
| Angka "days to go" | 30 → 25, teks 16 → 13 |
| Tinggi kartu ringkasan + foto | 270 → 232, offset -38 → -30 |
| "Wedding Progress" | 20 → 18 |
| ProgressRing | 128 → 108, "68%" 34 → 27, lineWidth 16 → 13 |
| Baris stat (Completed dll) | 17 → 15 |
| Quote text | 16 → 14, laurel 62 → 52 |
| "Next Up" | 20 → 18 |
| NextUpCard | ikon 24→20, judul 14→13, tinggi 166→146 |
| QuickAction | ikon 21→19, label 12→11 |

- Build diverifikasi: `xcodebuild ... 'platform=iOS Simulator,name=iPhone 17' build` → **BUILD SUCCEEDED**.
- Hanya edit file existing → cukup **Run (⌘R)** di Xcode, tidak perlu `xcodegen generate`.

---

## Update Log — 2026-07-03 (lanjutan 2): Perbaikan Layout Home Agar Sesuai Referensi

Perbandingan render iOS vs mockup menunjukkan 3 masalah; diperbaiki di `DashboardView.swift`:

1. **Foto pasangan mengambang** → diperbaiki jadi **flush**. Sebelumnya foto pakai `ZStack` + stroke emas `offset(-8,-9)` + tinggi berbeda dari kartu sehingga foto keluar/menggantung di atas kartu. Sekarang foto = 1 `Image` setinggi penuh kartu (`cardHeight`), `clipShape(UnevenRoundedRectangle topLeading:72)` menempel rata kanan/atas/bawah, dengan garis emas tipis `overlay(stroke)` mengikuti lengkung (tanpa offset).
2. **Layout terlalu tinggi/renggang** → dipadatkan agar semua muat 1 layar:
   - Spacing antar kartu `20 → 16`, scroll padding top `54 → 8`, bottom `24 → 20`.
   - Header: frame `210 → 128`, padding top `50 → 8` (mengurangi celah atas yang besar).
   - Kartu ringkasan: tinggi dipatok `182` (sebelumnya 232 dengan GeometryReader + `offset -30` yang menyisakan ruang kosong). Nama pasangan `24 → 22`, hilangkan `offset/padding -30`.
   - Progress card: ring `108 → 100`, padding `20 → 18`, spacing dirapatkan.
3. **Tab bar hijau mengambang** → dikembalikan ke **tab bar standar**. Hapus branch `LatestNativeDashboardTabs` + `.tabViewStyle(.sidebarAdaptable)` (gaya iOS 18 yang bikin kapsul hijau). `DashboardView` sekarang selalu pakai `NativeDashboardTabs` (TabView klasik) dengan `.tint(AppTheme.sageDark)` → item terpilih hijau, background putih/blur seperti referensi.

- Build: **BUILD SUCCEEDED** (iPhone 17 Simulator). Cukup **Run (⌘R)**, tanpa `xcodegen generate`.

---

## Update Log — 2026-07-03 (lanjutan 3): Quote Card Jadi Carousel Auto-Slide

Quote card di Home iOS diubah dari 1 kutipan statis menjadi **carousel 3 slide yang bergerak otomatis** (`DashboardView.swift`):

- Isi kutipan carousel (3 slide, auto-slide 4 detik) pakai **Bahasa Indonesia**:
  1. "Pernikahan yang sempurna bukan soal detailnya, melainkan tentang merayakan cinta kalian."
  2. "Pernikahan bukan hanya tentang hari pernikahan, tapi tentang semua hari setelahnya."
  3. "Dua jiwa, satu hati — awal dari kebersamaan yang indah selamanya."
- Isi tengah pakai `TabView(selection: $quoteIndex)` gaya `.page(indexDisplayMode: .never)` (tinggi 62) → bisa di-swipe manual + geser otomatis.
- Auto-slide via `.onReceive(quoteTimer)` → `quoteIndex = (quoteIndex + 1) % quotes.count` dengan `withAnimation(.easeInOut(duration: 0.6))`. Ganti tiap **4 detik**.
- Ornamen daun (`laurel.leading/trailing`) dipindah ke `.overlay` (tetap diam di sisi kiri/kanan, `allowsHitTesting(false)`) sementara teks-nya yang bergeser. Konten diberi `padding(.horizontal, 52)` agar tidak menabrak daun.
- 3 dot indikator di bawah kini reaktif: dot aktif = `opacity 1`, lainnya `0.4`, mengikuti `quoteIndex`.
- Build **BUILD SUCCEEDED**. Cukup **Run (⌘R)**.

---

## Update Log — 2026-07-03 (lanjutan 4): Halaman Checklist iOS

Home dikonfirmasi user **sudah benar**. Dibuat halaman **Checklist** sesuai mockup.

### File baru (perlu `xcodegen generate` — sudah dijalankan)

- `Sources/App/AppTheme.swift` — `enum AppTheme` **diekstrak** dari `DashboardView.swift` (dulu `private`) jadi file bersama (internal) agar bisa dipakai lintas view. Enum privat di DashboardView dihapus.
- `Sources/Models/PreparationTask.swift` — model `Codable` untuk `customer-preparation-tasks` (id, weddingEventId, sectionId, title, label, status, dueDate, sortOrder) + enum `Status` (pending/in_progress/done) + `statusValue`.
- `Sources/Features/Checklist/ChecklistView.swift` — halaman utama.

### Perubahan lain

- `DashboardView.swift`: `ChecklistView()` menggantikan placeholder `ChecklistTabView` (struct lama dihapus).

### Struktur ChecklistView (mengikuti mockup)

- **Header**: judul "Checklist" + subtitle 2 baris + 2 tombol bulat (search `magnifyingglass`, filter `slider.horizontal.3`), di atas `LuxuryWeddingBackground`.
- **Summary card**: ring "Total Progress / xx% / Selesai" + 3 stat (Selesai=done hijau `checkmark.circle.fill`, Berjalan=in_progress emas `clock.fill`, Belum Mulai=pending abu `circle`), masing-masing "N Tugas".
- **Filter chips** (horizontal): "Semua" + nama tiap acara + "Lainnya". Chip aktif = `sageDark` isi putih; non-aktif = `lightSage`.
- **Section card** per acara (expand/collapse via chevron): ikon acara + judul + persen + progress bar + "X dari Y tugas selesai". Saat expanded → daftar `TaskRow` (maks 5, sisanya via "Lihat semua (N)").
- **TaskRow**: `StatusIcon` (done=lingkaran hijau centang, in_progress=lingkaran emas jam, pending=lingkaran kosong) + judul + subtitle ("Selesai pada d MMM yyyy" / "In Progress" / "Belum Mulai") + chevron.

### Data

- Ambil dari API: `wedding-events` + `customer-preparation-tasks` (digroup per `wedding_event_id`; task tanpa event → grup "Lainnya"). Tanggal "Selesai pada" pakai locale `id_ID`.
- **Fallback contoh data** (`ChecklistGroup.samples`: Akad Nikah, Resepsi) saat akun kosong/API gagal — supaya tampilan tetap penuh seperti mockup. Statistik (Selesai/Berjalan/Belum Mulai + %) dihitung dari data aktual.
- Endpoint `customer-preparation-tasks` mendukung `in_progress` (statusOptions: pending/in_progress/done), tapi endpoint `toggle` hanya pending↔done — untuk set `in_progress` pakai PUT `status`.

- Build: **BUILD SUCCEEDED**. Karena ada file baru, `.xcodeproj` di-regenerate → **jika Xcode sudah terbuka, Xcode akan reload project otomatis**, lalu Run (⌘R).

---

## Update Log — 2026-07-03 (lanjutan 5): Halaman Guest iOS

Dibuat halaman **Guest** sesuai mockup (`Sources/Features/Guests/GuestView.swift`, file baru → `xcodegen generate` sudah dijalankan). Tab Guest di `DashboardView` diarahkan dari `GuestListView()` → `GuestView()` (GuestListView lama dibiarkan, tidak dipakai lagi di tab).

### Struktur (mengikuti mockup)

- **Header**: "Guest" + subtitle 2 baris + tombol search & filter, di atas `LuxuryWeddingBackground`.
- **Stats card**: 4 kolom — Total Tamu (Orang), Konfirmasi (%), Pending (%, emas), Tidak Hadir (%). Ikon dalam lingkaran.
- **RSVP Overview card**: donut chart 3 segmen (`DonutChart` pakai `trim` kumulatif) + legend (Konfirmasi/Pending/Tidak Hadir) dengan bar + "N (xx%)" + link "Lihat detail".
- **Filter chips**: Semua / Konfirmasi / Pending / Tidak Hadir (`selectedFilter: RsvpKind?`).
- **Search row**: TextField "Cari nama, grup atau kontak..." + tombol hijau "+ Tambah Tamu" (buka `AddGuestSheet`).
- **List header**: "Semua Tamu (N)" + "Urutkan: Nama A-Z" (emas).
- **GuestRow**: avatar `person.2.fill` + nama + subtitle (grup + jumlah orang) + ikon kontak (phone/envelope) + badge RSVP + chevron.
- **Action bar**: 3 aksi (Bagikan Undangan, QR Check-in, Export Data) dipisah divider — saat ini tampilan saja (belum ada aksi).

### Data & mapping

- Ambil `guests` dari API; kalau kosong → **fallback contoh grup** (`GuestRowItem.samples`: Keluarga Besar Pratama dll) agar mirip mockup.
- **Penting soal grup:** mockup berbasis *grup tamu* (mis. "Grup Keluarga · 25 orang"), tapi model `Guest` backend masih **per individu** (belum ada kolom grup/jumlah). Untuk data asli, tiap guest = 1 baris (count 1). Kalau nanti mau fitur grup betulan, perlu tambah kolom `group_name`/`group_type` + relasi jumlah di backend & API.
- Mapping RSVP: `hadir`→Konfirmasi (hijau), `menunggu`→Pending (emas), `tidak_hadir`→Tidak Hadir (abu). Enum `RsvpKind` (internal, dipakai lintas struct).
- Statistik (total/konfirmasi/pending/tidak hadir + %) dihitung dari data aktual (`count` per baris).

- Build: **BUILD SUCCEEDED**. Ada file baru → `.xcodeproj` regenerate; Xcode reload otomatis lalu Run (⌘R).

---

## Update Log — 2026-07-03 (lanjutan 6): Halaman Budget iOS

Dibuat halaman **Budget** sesuai mockup (`Sources/Features/Budget/BudgetView.swift` + model baru `Sources/Models/PaymentSchedule.swift`, file baru → `xcodegen generate` sudah dijalankan). Tab Budget di `DashboardView` diarahkan dari `BudgetTabView()` (Form editor lama, struct dihapus) → `BudgetView()`.

### Struktur (mengikuti mockup)

- **Header**: "Budget" + subtitle 2 baris + search & filter, di atas `LuxuryWeddingBackground`.
- **Total card**: Total Anggaran (Rp besar) + "100% dari rencana"; kanan-atas "Pengeluaran Terpakai" (persen + bar + nominal). Bawah: `BudgetDonut` 3 segmen (Terpakai hijau, Sisa Anggaran emas, Komitmen abu) + legend (nominal + %) + box "Sisa Anggaran".
- **Stats row**: 4 kartu — Total Anggaran, Terpakai (%), Komitmen (%), Sisa Anggaran (%).
- **Ringkasan Anggaran** + "Lihat detail".
- **BudgetCategoryRow** per kategori: ikon + nama + "Rp… | xx%" (alokasi) + bar + kanan "Rp… / xx% terpakai" + chevron.
- **Action bar**: Tambah Expense, Kategori Budget, Laporan Budget (tampilan saja).

### Data & mapping

- Ambil dari API: `wedding-budget` (total) + `wedding-payment-schedules` (per kategori). Group per `category`: allocated=Σamount, spent=Σ(status `paid`), commitment=Σ(status ≠ paid). Sisa = total − terpakai − komitmen.
- **Fallback contoh** (`BudgetCategory.samples`: Venue, Catering, Dekorasi, Fotografi & Videografi, Busana, Entertainment, Lainnya — angka persis mockup) saat kosong/gagal.
- Ikon kategori dipetakan dari key backend (venue/catering/decoration/photo_video/makeup/entertainment/transport/wo) via `BudgetCategory.icon(for:)`.
- **`CurrencyFormatter`** (enum, internal) — format Rupiah `Rp120.000.000` pakai locale `id_ID`, tanpa desimal. Bisa dipakai ulang di halaman lain.
- Catatan mapping: mockup punya "alokasi per kategori" DAN "terpakai per kategori". Backend `WeddingPaymentSchedule` = daftar pembayaran (amount + status), jadi "alokasi" = total amount kategori, "terpakai" = yang `paid`. Kalau mau alokasi & realisasi terpisah betulan, perlu tambah kolom di backend.

- Build: **BUILD SUCCEEDED**. Ada file baru → `.xcodeproj` regenerate; Xcode reload otomatis lalu Run (⌘R).

---

## Update Log — 2026-07-03 (lanjutan 7): Tab More iOS

Dibuat tab **More** sesuai mockup (`Sources/Features/More/MoreView.swift`, file baru → `xcodegen generate` sudah dijalankan). Tab More di `DashboardView` diarahkan dari `MoreTabView()` (List sederhana, struct dihapus) → `MoreView()`.

### Struktur (mengikuti mockup)

- **Header**: "More" + subtitle 2 baris (tanpa dekorasi tombol), di atas `LuxuryWeddingBackground`.
- **Profile card**: foto (CouplePortrait, lingkaran bingkai emas) + nama pasangan + tanggal + lokasi, tombol "Edit Profil" (→ `InfoTabView`).
- **Grup "Perencanaan Saya"**: Detail Pernikahan, Pasangan, Vendor Tersimpan, Inspirasi & Ide, Dokumen. (Detail Pernikahan & Pasangan → `InfoTabView`; sisanya placeholder tanpa destination.)
- **Grup "Akun & Pengaturan"**: Pengaturan, Privasi & Keamanan, Pengingat, Bahasa (Indonesia), Bantuan & FAQ, Tentang Wedding App (Versi 1.0.0). Semua placeholder.
- **Share card**: "Bagikan Wedding App" + tombol `ShareLink` (share URL paketpernikahan.co.id).
- **Logout**: tombol "Keluar dari Akun" (merah, outline) → `session.logout()`.

### Data

- `coupleName`/tanggal/lokasi diambil dari `wedding-info` + `wedding-events` (fallback ke `currentUser.name` / teks default kalau kosong). Baris menu selain profil sebagian besar **placeholder** (belum ada halaman tujuan) — tinggal isi `destination` saat halaman dibuat.
- Row punya enum `Destination` (weddingInfo/events); yang `nil` tampil tanpa navigasi.

- Build: **BUILD SUCCEEDED**. Semua 5 tab (Home, Checklist, Guest, Budget, More) kini sesuai desain mockup. Ada file baru → `.xcodeproj` regenerate; Xcode reload otomatis lalu Run (⌘R).

---

## Update Log — 2026-07-03 (lanjutan 8): Blur Status Bar di Semua Halaman

Ditambahkan lapisan blur di area status bar (jam, sinyal, baterai) agar tetap terbaca saat konten menggulung — perilaku standar iOS.

- File baru `Sources/App/StatusBarBlur.swift`: `ViewModifier` + extension `.statusBarBlur()`. Teknik: `.overlay(alignment: .top)` berisi `GeometryReader { Rectangle().fill(.ultraThinMaterial).frame(height: proxy.safeAreaInsets.top) }` dengan `.ignoresSafeArea()` + `.allowsHitTesting(false)`. Tinggi otomatis = inset atas tiap device.
- Diterapkan di 5 halaman (tepat sebelum `.toolbar(.hidden, for: .navigationBar)` pada ZStack): Home (`DashboardView`), `ChecklistView`, `GuestView`, `BudgetView`, `MoreView`.
- Build: **BUILD SUCCEEDED**. Ada file baru → `.xcodeproj` regenerate; Xcode reload otomatis lalu Run (⌘R).

---

## Update Log — 2026-07-03 (lanjutan 9): Checklist Persiapan per Acara + Seeder

Dibuat checklist persiapan detail untuk 4 jenis acara (`wedding-event/lamaran.md`, `pengajian.md`, `akad.md`, `resepsi.md`) lalu di-seed ke database.

- **Markdown sumber**: tiap file berisi section bertimeline (H-X) + task berupa checkbox. Ini jadi acuan konten seeder.
- **Seeder baru** `database/seeders/WeddingPreparationChecklistSeeder.php`: untuk tiap user, ambil `WeddingEvent` berdasarkan `jenis_acara`, buat `CustomerPreparationSection` (title + icon SF Symbol + sort_order) dan `CustomerPreparationTask` (status `pending`, sort_order) yang tertaut ke `wedding_event_id` + `section_id`.
- **Catatan model**: `CustomerPreparationSection` tidak punya `wedding_event_id` (section global per user). Pengelompokan per acara di iOS (`ChecklistView`) memakai `wedding_event_id` pada task, jadi seeder membuat baris section terpisah untuk tiap acara (judul boleh berulang antar-acara).
- **`DatabaseSeeder`**: `CustomerPreparationSectionSeeder` + `CustomerPreparationTaskSeeder` (data acak factory) diganti oleh `WeddingPreparationChecklistSeeder` (data checklist nyata). File seeder lama tetap ada namun tidak dipanggil.
- **Hasil `migrate:fresh --seed`** (3 user): per user → lamaran 48, pengajian 50, akad 77, resepsi 82 task.

---

## Update Log — 2026-07-03 (lanjutan 10): Detail Task di Halaman Checklist

Saat baris task di halaman Checklist diklik (termasuk area `>`), kini muncul detail task.

- **`ChecklistView.swift`**: baris task dibungkus `Button { selectedTask = task }`; ditambahkan `@State selectedTask: PreparationTask?`.
- **Sinkron API**: perubahan status update optimistik pada state lokal lalu `PUT customer-preparation-tasks/{id}` (kirim `title` + `status`, karena validasi controller mewajibkan `title`). Endpoint `toggle` hanya pending↔done, jadi dipakai `update` untuk 3 status.
- **Section title**: `ChecklistView` kini juga load `customer-preparation-sections` untuk memetakan `section_id → title` (struct `PreparationSection` baru). Detail view tidak butuh file baru → tanpa `xcodegen generate`.

---

## Update Log — 2026-07-03 (lanjutan 11): Halaman "Detail Tugas" Sesuai Mockup

Detail task diubah dari sheet menjadi **halaman penuh** (push navigation) meniru mockup.

- **Navigasi**: `PreparationTask` kini `Hashable` (+ field `createdAt: String? = nil`). `ChecklistView` memakai `.navigationDestination(item: $selectedTask)` menggantikan `.sheet`.
- **`TaskDetailView` (redesign penuh halaman)**:
  - Header: tombol back (arrow.left → `dismiss()`), ikon pencil + ellipsis (dekoratif), judul "Detail Tugas" (system serif) + subtitle, di atas `LuxuryWeddingBackground` (floral top-right).
  - Info card: `StatusIcon` + judul + subtitle status + badge status; grid 2×2 → Kategori (nama acara), Prioritas (diturunkan dari jarak `due_date`), Tanggal Dibuat (`created_at`), Target Selesai (`due_date`).
  - Deskripsi (dari `task.label`, fallback teks default), Sub Tugas, Catatan, Lampiran.
  - Bottom bar tetap (`safeAreaInset(.bottom)`) tombol "Tandai Selesai / Tandai Belum Selesai".
- **Catatan data**: hanya judul, status, kategori, tanggal dibuat, dan target yang dari API. **Prioritas** diturunkan dari due date. **Sub Tugas, Catatan, Lampiran** masih konten placeholder (backend belum punya field-nya) — perlu penambahan field/relasi bila ingin nyata.
- Build: **BUILD SUCCEEDED** (iPhone 17 simulator), tanpa lint error.

---

## Update Log — 2026-07-03 (lanjutan 12): Data Nyata Detail Tugas (Backend + iOS)

Field dan relasi detail tugas ditambahkan di backend, lalu di-wire ke halaman Detail Tugas iOS.

### Backend (Laravel)

- **Migrasi** `customer_preparation_tasks`: kolom `description`, `notes`, `priority` (default `medium`).
- **Tabel baru** `customer_preparation_sub_tasks` (title, status, due_date, completed_at, sort_order).
- **Tabel baru** `customer_preparation_task_attachments` (file_name, file_path, file_size, mime_type).
- **Model**: `CustomerPreparationSubTask`, `CustomerPreparationTaskAttachment`; relasi `subTasks()` & `attachments()` di `CustomerPreparationTask`.
- **API**: `CustomerPreparationTaskResource` mengembalikan `description`, `notes`, `priority`, `sub_tasks`, `attachments`; controller eager-load relasi di index/show/update.
- **Filament**: form task ditambah deskripsi, catatan, prioritas, repeater sub tugas.
- **Seeder** `WeddingPreparationTaskDetailsSeeder`: **dua tahap** — (1) auto-enrich **semua 257 task/user** (deskripsi dari section+judul, prioritas dari kata kunci section, 2–3 sub tugas dari pola judul task, lampiran PDF otomatis untuk task dokumen/berkas); (2) manual override **12 task penting** dengan data lebih kaya (status bervariasi, catatan, sub tugas bertahap, lampiran khusus). Total per user: ~774 sub tugas + lampiran dokumen otomatis.
- `php artisan storage:link` diperlukan agar URL lampiran bisa diakses.

### iOS

- **`PreparationTask.swift`**: struct `PreparationSubTask`, `PreparationTaskAttachment`; field `description`, `notes`, `priority`, `subTasks`, `attachments`.
- **`TaskDetailView`**: deskripsi/catatan/sub tugas/lampiran dari API; section disembunyikan jika kosong; prioritas dari field `priority`; lampiran punya link unduh (`url` dari API).

### Verifikasi

- `migrate:fresh --seed` sukses.
- `PreparationChecklistApiTest` lulus (task contoh punya priority `high`, 5 sub tugas, 1 lampiran).
- Build iOS: **BUILD SUCCEEDED**.

### Cara cek di app

1. Login `test@example.com` / `password`.
2. Checklist → Akad Nikah → buka task **"Menentukan tanggal dan jam akad"**.
3. Halaman Detail Tugas menampilkan data lengkap dari API (bukan placeholder).

---

## Update Log — 2026-07-03 (lanjutan 13): Interaksi Sub Tugas + Sinkron Status Induk

Tiga fitur sub tugas diimplementasikan end-to-end.

### Backend
- **`PATCH /api/v1/customer-preparation-sub-tasks/{id}/toggle`**: siklus status `pending → in_progress → done → pending`; set `completed_at` saat selesai.
- **`CustomerPreparationTask::syncStatusFromSubTasks()`**: semua sub selesai → induk `done`; semua pending → induk `pending`; selain itu → `in_progress`.
- Response: `{ data: sub_task, parent_task_status: "..." }`.

### iOS
- Baris **Sub Tugas** bisa di-tap untuk toggle status (optimistic UI + sinkron API).
- Status task induk & ringkasan Checklist otomatis update saat sub tugas berubah.
- `SubTaskToggleResponse` + helper `PreparationTask.status(from:)` / `nextStatus(after:)`.

### Test
- `PreparationSubTaskToggleTest` (siklus status, sinkron induk saat semua sub selesai, isolasi user).
- Build iOS: **BUILD SUCCEEDED**.

---

## Update Log — 2026-07-03 (lanjutan 14): Tombol Edit di "Detail Tugas"

Tombol pencil di header "Detail Tugas" (sejajar tombol back) kini aktif.

### iOS
- Tap ikon pencil membuka sheet **`TaskEditSheet`** untuk edit: judul, prioritas (Tinggi/Sedang/Rendah), target selesai (toggle + `DatePicker`), deskripsi, dan catatan.
- Simpan → `PUT /api/v1/customer-preparation-tasks/{id}` (title, priority, description, notes, due_date). `due_date` dikirim `null` bila toggle target selesai dimatikan.
- Setelah sukses, `TaskDetailView` update `@State` lokal dan mem-propagate ke `ChecklistView` via callback `onTaskEdited` (daftar task + grup ikut ter-update).
- Field detail tugas diubah dari `let` menjadi `@State` agar bisa reflektif setelah edit.
- `TaskEditResult` (struct hasil edit) ditambahkan di `PreparationTask.swift`.
- Build iOS: **BUILD SUCCEEDED**.

---

## Update Log — 2026-07-12: Login iOS + Forgot Password End-to-End

Update ini berfokus pada halaman login iOS sesuai referensi desain dan perbaikan alur **Lupa Kata Sandi** dari iOS sampai backend Laravel.

### iOS — Halaman Login

- **`LoginView.swift`** didesain ulang mengikuti referensi visual yang diberikan:
  - Hero bagian atas memakai gambar pasangan.
  - Area form memakai shape putih melengkung.
  - Dekorasi floral di bagian bawah.
  - Tombol login, Apple, Google, link daftar, dan link lupa kata sandi disusun agar muat dalam satu layar tanpa perlu scroll normal.
- Semua teks di halaman login menggunakan **Poppins** via `AppFont`, bukan Cormorant.
- Gambar pasangan diganti memakai asset **`CouplePortrait`** dari gambar pasangan berhijab yang diberikan.
- Asset pasangan dikompresi menjadi sekitar **828 KB** agar tidak terlalu besar untuk bundle aplikasi.
- Posisi gambar pasangan beberapa kali disesuaikan:
  - Diturunkan agar tidak terlalu menempel ke atas.
  - Badan pasangan dibuat tetap terlihat sampai bawah.
  - Shape putih tetap berada di atas gambar sesuai referensi.
- Bagian brand atas (`Wedding App`, logo hati, tagline) diturunkan agar tidak bertabrakan dengan status bar.
- `DashboardView.swift` ditambahkan `import Combine` untuk mengatasi warning/error `Timer.publish(...).autoconnect()` terkait `Publishers` / `Autoconnect`.

### iOS — Lupa Kata Sandi

- Tombol **“Lupa kata sandi?”** tidak lagi menampilkan alert `Coming Soon`.
- Ditambahkan sheet **Atur ulang kata sandi** di `LoginView.swift`:
  - Email dari form login otomatis terbawa.
  - Validasi email dilakukan sebelum request.
  - Menampilkan loading state.
  - Menampilkan pesan sukses/error.
- Request iOS diarahkan ke:
  - `POST /api/v1/auth/forgot-password`
  - Payload: `{ "email": "..." }`
- **`APIClient.swift`** diperbarui agar endpoint `auth/forgot-password` tidak mengirim Authorization token dan tidak memicu session-expired broadcast.

### Backend — API Forgot Password

- **`routes/api.php`**
  - Ditambahkan route publik:
    - `POST api/v1/auth/forgot-password`
- **`App\Http\Controllers\Api\V1\AuthController`**
  - Ditambahkan method `forgotPassword()`.
  - Validasi email.
  - Menggunakan `Password::sendResetLink()`.
  - Response selalu generik agar tidak membocorkan apakah email terdaftar:
    - `Jika email terdaftar, instruksi reset kata sandi sudah dikirim.`
- Endpoint ini memperbaiki error awal:
  - `404` karena route belum ada.

### Backend — Web Reset Password

Setelah API ditambahkan, muncul error `500` karena Laravel membutuhkan route bernama `password.reset` saat membuat link reset password.

- Penyebab `500` dari log:
  - `Route [password.reset] not defined.`
- **`routes/web.php`**
  - Ditambahkan route guest:
    - `GET /reset-password/{token}` → name `password.reset`
    - `POST /reset-password` → name `password.update`
- **`App\Http\Controllers\AuthController`**
  - Ditambahkan `showResetPassword(Request $request, string $token)`.
  - Ditambahkan `resetPassword(Request $request)`.
  - Reset password memakai `Password::reset()`.
  - Password baru di-hash dengan `Hash::make()`.
  - `remember_token` diperbarui dengan `Str::random(60)`.
  - Setelah sukses diarahkan ke halaman login dengan pesan:
    - `Kata sandi berhasil diatur ulang. Silakan masuk dengan kata sandi baru.`
- **`resources/views/auth/reset-password.blade.php`**
  - View baru untuk form reset password web:
    - Email
    - Kata sandi baru
    - Konfirmasi kata sandi
- **`resources/views/auth/login.blade.php`**
  - Ditambahkan tampilan `session('status')` agar pesan sukses reset password terlihat di halaman login.

### Test & Verifikasi

- **`tests/Feature/Api/AccountSecurityApiTest.php`** ditambah coverage:
  - User bisa request instruksi reset password.
  - Email tidak terdaftar tetap mendapat response generik dan tidak mengirim notifikasi.
  - Email invalid ditolak validasi.
  - User bisa membuka link reset password dan mengganti password dari form web.
- Verifikasi route:
  - `POST api/v1/auth/forgot-password` terdaftar.
  - `GET reset-password/{token}` dan `POST reset-password` terdaftar.
- Pint:
  - `vendor/bin/pint --dirty --format agent` → **passed**.
- Test:
  - `php artisan test --compact tests/Feature/Api/AccountSecurityApiTest.php` dengan `LOG_CHANNEL=stderr` dan `VIEW_COMPILED_PATH=/tmp/wedding-app-views`.
  - Hasil: **15 passed, 62 assertions**.
- Catatan test:
  - Ada warning `.phpunit.result.cache` tidak bisa ditulis karena izin sandbox, tetapi test tetap lulus.
  - `VIEW_COMPILED_PATH=/tmp/wedding-app-views` dipakai saat test karena sandbox membatasi penulisan compiled Blade ke folder `storage/framework/views`.
- Cache Laravel sudah dibersihkan:
  - `php artisan route:clear`
  - `php artisan config:clear`

### Catatan Operasional

- Untuk device iOS yang memakai local base URL:
  - Pastikan backend Laravel jalan dan dapat diakses dari jaringan lokal, contoh:
    - `php artisan serve --host=0.0.0.0 --port=8000`
  - iOS log yang diharapkan:
    - `POST http://192.168.1.3:8000/api/v1/auth/forgot-password`
    - Response sukses seharusnya bukan `404` atau `500`.
- Mailer default project adalah `log` jika `MAIL_MAILER` tidak diubah, sehingga email reset bisa masuk ke log Laravel pada mode lokal.

---

## Catatan Penting

- **Multi-tenant by `user_id`:** Hampir semua model terikat ke `user_id`. Pastikan selalu scope query per user.
- **Normalisasi nomor WA:** `VendorBooking::normalizeWhatsappNumber()` dipakai di dua tempat — setter `phone` di VendorBooking dan setter `whatsapp` di User.
- **Auto-overdue:** `WeddingPaymentSchedule` otomatis update status ke `overdue` saat di-retrieve jika `pending` + `due_date` sudah lewat.
- **Icon set:** `WeddingPaymentSchedule::getCategoryIconAttribute()` menggunakan SF Symbols (kemungkinan untuk iOS app).
- **Model di `copy_model/`:** Folder ini berisi copy dari model aktif (`app/Models/`). Tidak langsung dipakai oleh framework — hanya referensi.
- **Filament roles:** Admin panel (`canAccessPanel`) hanya untuk role `super_admin` dan `admin`.
- **Activity log:** Model yang log aktivitas: User, VendorBooking, VendorBookingPayment, VendorReview, ChatSession, ChatMessage, Wishlist.
