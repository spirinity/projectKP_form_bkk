# Quick Start Application

## 1. Menjalankan Aplikasi
Aplikasi ini sudah siap dijalankan. Gunakan perintah berikut di terminal:
```bash
flutter run
```
Pilih device (Chrome atau Emulator) jika diminta.

## 2. Mengaktifkan Overlay PDF (Format Asli)
Saat ini aplikasi menggunakan mode "Generated Layout" (re-kreasi) dengan placeholder. Untuk menggunakan format asli (scan form) sesuai permintaan:

1.  **Siapkan Gambar Form**:
    - Convert halaman 1 PDF Anda menjadi gambar (JPG/PNG). Beri nama `form1.png`.
    - Lakukan hal yang sama untuk halaman lain jika perlu.
    - Simpan gambar tersebut di folder: `d:\PROJEK\PROJEK KP\assets\images\`

2.  **Edit Code**:
    - Buka file `lib/utils/generator_form_2.dart`.
    - Cari bagian comment `// TODO: UNCOMMENT THIS BLOCK`.
    - Uncomment code tersebut dan sesuaikan path gambarnya.
    - Sesuaikan koordinat `top` dan `left` widget `pw.Positioned` agar teks pas di kolom isian form asli.

## 3. Struktur Project
- `lib/models`: Definisi data (Kapal, Sanitasi, Kesehatan).
- `lib/providers`: Logic penyimpanan data sementara.
- `lib/screens`: Layar input step-by-step.
- `lib/utils/generator_form_2.dart`: Logic pembuatan PDF.
