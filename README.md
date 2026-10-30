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
