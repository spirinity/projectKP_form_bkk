# Implementation Plan: Aplikasi Mobile Pemeriksaan Kapal (Balai Karantina Kesehatan)

## 1. Overview
Aplikasi mobile berbasis Flutter untuk membantu petugas Balai Karantina Kesehatan merekam data pemeriksaan kapal, sanitasi, dan kesehatan ABK/penumpang, serta menghasilkan output PDF resmi yang ditandatangani secara digital.

## 2. Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Provider (Simpel dan efektif untuk alur form sequential)
- **PDF Engines**: 
  - `pdf`: Untuk membuat dokumen PDF.
  - `printing`: Untuk preview dan sharing.
- **Form Handling**: `flutter_form_builder` (Opsional, untuk validasi mudah) atau widget `Form` standar.
- **Signature**: `signature` package untuk tanda tangan digital di layar.
- **Image Picker**: `image_picker` untuk upload foto tanda tangan.

## 3. Data Structure (Models)
Kita akan membagi data menjadi 3 model utama sesuai form:
1.  **ShipInspectionData (Form 1)**: Nama kapal, bendera, bobot, tanggal kedatangan, dermaga, dll.
2.  **SanitationData (Form 2)**: Hasil pemeriksaan dapur, ruang rakit, gudang, status vektor (tikus/kecoa), dll.
3.  **HealthData (Form 4)**: Jumlah kru, jumlah sakit, gejala yang terdeteksi, dll.
4.  **SignatureData**: Path gambar atau byte data dari tanda tangan Nahkoda dan Petugas.

## 4. Application Flow (User Experience)
Menggunakan konsep "Stepper" atau "Multi-page Form" agar petugas fokus pada satu bagian per satu waktu.

1.  **Home/Dashboard**: Tombol "Buat Pemeriksaan Baru".
2.  **Step 1: Data Kapal (Form 1)**
    - Input text fields, date pickers, dropdowns.
3.  **Step 2: Sanitasi (Form 2)**
    - Checkbox atau Radio buttons (Baik/Tidak Baik).
    - Catatan tambahan per item.
4.  **Step 3: Kesehatan (Form 4)**
    - Input angka (jumlah orang).
    - Checklist gejala.
5.  **Step 4: Tanda Tangan**
    - Canvas untuk tanda tangan langsung di layar.
    - Opsi upload gambar jika tanda tangan sudah ada di file.
6.  **Review & Export**
    - Halaman summary untuk mengecek data sebelum generate.
    - Tombol "Generate PDF".
    - Preview PDF.
    - Share/Print/Save PDF.

## 5. PDF Generation Strategy
Sesuai request "Mengisi pada template PDF resmi":
- **Metode A (Recreate)**: Membuat ulang layout PDF menggunakan widget dari package `pdf` agar hasil tajam dan rapi. Ini lebih fleksibel untuk teks panjang.
- **Metode B (Overlay)**: Jika format aslinya sangat kompleks, kita bisa load gambar form asli sebagai background, lalu menimpa (draw text) di koordinat yang sesuai.

*Rekomendasi*: Metode A biasanya lebih profesional dan file size lebih kecil, tapi Metode B lebih cepat jika "look"-nya harus 100% persis scan kertas. Kita akan coba pendekatan hybrid (Recreate header/tabel semirip mungkin).

## 6. Step-by-Step Implementation
1.  **Setup Project**: `flutter create .`
2.  **Install Dependencies**: Menambahkan package di `pubspec.yaml`.
3.  **Create Models & Providers**: Membuat class data dan logic penyimpanan sementara.
4.  **UI Implementation**:
    - Membuat screen untuk setiap section.
    - Styling form agar mudah dibaca di lapangan (font besar, kontras jelas).
5.  **Signature Module**: Implementasi canvas tanda tangan.
6.  **PDF Service**: Coding layout PDF generation.
7.  **Testing**: Trial input data dan cek hasil PDF.

## 7. Next Action
Jika plan ini disetujui, saya akan mulai dengan:
1.  Inisialisasi project Flutter.
2.  Setup struktur folder dan dependensi.
