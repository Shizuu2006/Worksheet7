# Course Explorer

Aplikasi Flutter untuk menjelajahi mata kuliah, melihat detail, dan mengelola
favorit. Project ini mendemonstrasikan pemisahan model, service, repository,
Provider, screen, dan widget, dengan navigasi yang menyesuaikan ukuran layar.

## Fitur

- Memuat data mata kuliah dari asset JSON.
- Menampilkan state loading, error dengan aksi coba lagi, dan daftar mata kuliah.
- Mencari dan memfilter daftar berdasarkan kategori atau favorit.
- Mengelola favorit bersama dari daftar, halaman detail, dan halaman Favorit.
- Menampilkan navigasi bawah pada layout sempit dan NavigationRail pada layout
  lebar.
- Menampilkan nama dan NIM mahasiswa pada UI.

Favorit dikelola di memori oleh `CourseProvider`; statusnya tidak disimpan
permanen setelah aplikasi ditutup.

## Arsitektur dan Struktur Folder

Alur pemuatan data:

```text
CoursesPage
    -> CourseProvider
        -> CourseRepository
            -> CourseService
                -> assets/data/student_data.json
```

| Lokasi | Tanggung jawab |
| --- | --- |
| `lib/models/` | Model bertipe kuat, termasuk parsing JSON ke `Course`. |
| `lib/services/` | Mengakses sumber data, seperti asset JSON, dan mengubahnya menjadi model. |
| `lib/repositories/` | Menyediakan kontrak akses data antara Provider dan service. |
| `lib/providers/` | Menyimpan shared state dan async state; memberi tahu UI melalui `notifyListeners()`. |
| `lib/screens/` | Halaman aplikasi seperti Home, Courses, Favorit, Profile, dan detail. |
| `lib/widgets/` | Komponen UI yang dapat digunakan ulang, seperti kartu mata kuliah dan banner identitas. |
| `lib/experiments/` | Halaman demo untuk konsep state management dan arsitektur dari tahapan worksheet. |
| `assets/data/` | Data mata kuliah dalam format JSON. |
| `assets/images/` | Gambar yang digunakan aplikasi. |
| `test/` | Unit test, widget test, dan test integrasi. |
| `docs/catatan-tahap.md` | Catatan pengerjaan dan hasil pembelajaran setiap tahap. |

`CourseProvider` dibuat di atas `MaterialApp` pada `lib/main.dart`, sehingga
screen dan halaman detail dapat membaca state yang sama. Widget yang
menampilkan perubahan menggunakan `watch` atau `Consumer`; aksi mengubah state
menggunakan `read`. Halaman daftar menampilkan indikator loading, pesan error
beserta tombol coba lagi, atau daftar hasil ketika pemuatan berhasil.

## Menjalankan Project

Pastikan Flutter SDK tersedia, lalu jalankan dari root project:

```sh
flutter pub get
flutter run
```

Data mata kuliah dimuat dari `assets/data/student_data.json`, yang sudah
didaftarkan pada bagian `assets` di `pubspec.yaml`.

## Menjalankan Test dan Analisis

```sh
flutter test
flutter analyze
```

Test mencakup parsing service, repository, notifikasi Provider, state loading
dan error pada UI, navigasi Favorit, serta sinkronisasi favorit lintas screen.

## Repository

Project ini dikerjakan bertahap pada
[Shizuu2006/Worksheet7](https://github.com/Shizuu2006/Worksheet7).

   ## REST API
   - Base URL: https://course-api-pearl.vercel.app
   - GET /courses → 200, array of Course
   - Field: id (int), code (string), title (string), credits (int), status (planned|active|done)