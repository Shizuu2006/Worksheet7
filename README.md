# Course Data Manager

**I Kadek Agus Mertha Kusuma - 2415051054 - PTI 5C**

Aplikasi Flutter untuk mengelola data mata kuliah (CRUD) dengan Supabase
sebagai backend aktif. Project ini dikembangkan dari Course Explorer v2 dan
mendemonstrasikan pemisahan data source, repository, provider, dan UI.

## Fitur

- Membaca daftar course dari tabel `courses` di Supabase.
- Menambah, mengedit, dan menghapus course; penghapusan memakai dialog
  konfirmasi.
- Menampilkan state loading, empty, dan error dengan aksi Retry.
- Menampilkan pesan hasil operasi melalui SnackBar.
- Mencari dan memfilter course serta mengelola favorites berdasarkan `code`.
- Menampilkan daftar dan detail course, serta identitas mahasiswa di UI.
- Menyesuaikan navigasi dengan ukuran layar: NavigationBar pada layar sempit
  dan NavigationRail pada layar lebar.

Favorites dikelola di memori oleh `CourseProvider`, sehingga tidak disimpan
permanen setelah aplikasi ditutup.

## Cara Menjalankan

Pastikan Flutter SDK tersedia dan project Supabase telah memiliki tabel
`courses` dengan kolom yang sesuai model. Kemudian:

1. Jalankan `flutter pub get`.
2. Isi `lib/config/supabase_config.dart` dengan Project URL dan publishable
   key atau anon key Supabase.
3. Jalankan `flutter run`.

Jangan masukkan database password atau `service_role` key ke aplikasi Flutter.
Publishable/anon key digunakan di client; akses data tetap harus dilindungi
dengan konfigurasi Row Level Security (RLS) dan policy yang sesuai.

## Worksheet 9 — Authentication, Role, RLS, dan FCM

Aplikasi menyediakan register/login Supabase dan memeriksa session saat dibuka.
Tahap E (`Praktik 1`) menggunakan email, password, konfirmasi password, dan
alur session langsung ke halaman utama. Pemeriksaan profile/role tidak menjadi
syarat untuk tahap ini; feature role dan database policy dijelaskan pada tahap
lanjut di bawah. Supabase tetap menjadi penegak izin yang sebenarnya; perubahan
role pada UI saja bukan pengamanan data.

Tahap F (`Praktik 2 — Logout dan Session`) menggunakan session Supabase yang
dipulihkan saat aplikasi dibuka. `AuthGate` menampilkan halaman login jika
session kosong dan aplikasi utama jika session tersedia, lalu mengikuti
perubahan status auth. Tombol Logout memanggil `signOut()`, sehingga session
dihapus dan aplikasi kembali ke halaman login. Pengujian end-to-end perilaku
session memerlukan project Supabase aktif dan akun untuk login.

### Supabase

1. Pastikan tabel `courses` sudah ada dan cocok dengan model aplikasi.
2. Jalankan isi `supabase/worksheet9.sql` melalui Supabase SQL Editor. Skrip ini
   membuat profil otomatis saat pendaftaran, menambahkan `owner_id`, serta
   mengaktifkan policy RLS untuk course dan token perangkat.
3. Skrip tersebut mengganti seluruh policy lama pada tabel `courses`, karena
   policy permissive lama dapat mengizinkan operasi yang dilarang policy baru.
   Tinjau efek ini sebelum menjalankannya pada database produksi.
4. Akun baru mendaftar sebagai `seeker` atau `owner`; role `admin` hanya dapat
   ditetapkan dari SQL Editor oleh administrator.
5. Untuk latihan, nonaktifkan konfirmasi email pada Supabase Auth agar akun
   dapat langsung login.

RLS hanya memberi pemilik izin mengubah/menghapus course dengan `owner_id`
yang cocok. Data course lama yang `owner_id`-nya masih kosong tetap dapat dibaca
oleh user login, tetapi tidak dapat dikelola owner sebelum kepemilikannya
diverifikasi dan diisi secara manual.

### Firebase Cloud Messaging

Dependensi Firebase, permission Android 13+, permission request, token device,
penyimpanan token ke Supabase, serta listener pesan foreground/background sudah
disiapkan. Sebelum FCM bisa berjalan, hubungkan project Firebase pribadi:

1. Jalankan `flutterfire configure` pada root project dan pilih project serta
   platform yang benar.
2. Ikuti petunjuk FlutterFire untuk memasang konfigurasi native, misalnya
   `google-services.json` untuk Android dan `GoogleService-Info.plist` untuk
   iOS. Project tidak menyertakan kredensial Firebase pribadi.
3. Jalankan SQL `supabase/worksheet9.sql` agar tabel token dan policy tersedia.
4. Jalankan aplikasi pada perangkat/emulator yang mendukung Google Play
   Services. Status permission dan FCM token tercetak di debug console.
5. Kirim pesan uji dari Firebase Console → Cloud Messaging menggunakan token
   terbaru. Token bersifat dinamis; jangan commit atau membagikannya.

Jika project Firebase belum dikonfigurasi, aplikasi tetap membuka fitur
Supabase dan menampilkan bahwa FCM perlu disiapkan.

### Pengujian

```sh
flutter test
flutter analyze
```

Uji juga dua akun berbeda: owner pertama harus dapat mengelola course miliknya,
sedangkan owner kedua harus mendapat operasi ditolak saat mencoba mengubah atau
menghapus data tersebut. Uji FCM memerlukan konfigurasi Firebase dan perangkat
yang mendukung push notification.

## Arsitektur

Alur data aplikasi:

```text
UI (screens/widgets)
    -> CourseProvider
        -> CourseRepository
            -> CourseDataSource
                -> CourseSupabaseService (aktif)
                -> CourseApiService (REST alternatif)
```

- `CourseDataSource`: kontrak untuk operasi baca, tambah, ubah, dan hapus.
- `CourseSupabaseService`: implementasi data source untuk tabel Supabase
  `courses`.
- `CourseApiService`: implementasi data source alternatif untuk REST API
  latihan.
- `CourseRepository`: perantara antara provider dan data source.
- `CourseProvider`: mengelola data course, favorites, loading/error state,
  dan operasi CRUD.
- Data source aktif dipilih di `lib/main.dart`; saat ini menggunakan
  `CourseSupabaseService`.

## Backend

- **Supabase:** PostgreSQL, tabel `courses`; URL dan key client dikonfigurasi
  secara lokal di `lib/config/supabase_config.dart`.
- **REST API latihan (alternatif):** `https://course-api-pearl.vercel.app`.
  Implementasi `CourseApiService` mengirim permintaan CRUD ke endpoint
  `/courses`.

RLS dan policy adalah kontrol akses di backend. Pastikan policy yang aktif
sesuai kebutuhan praktikum dan jangan menganggap satu policy saja sebagai
keseluruhan konfigurasi akses: pada pengujian, operasi insert masih berhasil
setelah policy `lab_insert` dihapus, yang menunjukkan kemungkinan ada policy
INSERT lain yang juga mengizinkan operasi.

## Struktur Project

| Lokasi | Tanggung jawab |
| --- | --- |
| `lib/models/` | Model bertipe kuat dan parsing JSON ke `Course`. |
| `lib/services/` | Kontrak data source dan implementasi Supabase/REST. |
| `lib/repositories/` | Perantara akses data antara provider dan service. |
| `lib/providers/` | Shared state, operasi asynchronous, dan notifikasi UI. |
| `lib/screens/` | Halaman Home, Courses, detail, form, Favorites, dan Profile. |
| `lib/widgets/` | Komponen UI reusable seperti course card dan error view. |
| `lib/config/` | Konfigurasi URL dan key client Supabase. |
| `test/` | Widget test dan test untuk alur pemuatan/operasi course. |

## Test dan Analisis

```sh
flutter test
flutter analyze
```

## Repository

Project ini dikerjakan bertahap pada
[Shizuu2006/Worksheet7](https://github.com/Shizuu2006/Worksheet7).
