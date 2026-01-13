import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/inspection_model.dart';

/// PDF Generator menggunakan pendekatan overlay.
/// Gambar template `sanitasi.png` digunakan sebagai background,
/// lalu data (tanda centang ✓) diposisikan secara absolut di atasnya.
class PdfGenerator {
  static Future<Uint8List> generatePdf(InspectionModel data) async {
    final pdf = pw.Document();

    // Load template overlay image
    final Uint8List overlayBytes = (await rootBundle.load(
      'lib/pdf/form_2.png',
    )).buffer.asUint8List();
    final overlayImage = pw.MemoryImage(overlayBytes);

    // --- KOORDINAT CHECKBOX ---
    // Koordinat ini diukur berdasarkan posisi kolom pada gambar overlay.
    // Format: (left, top) dalam points dari sudut kiri atas halaman.
    //
    // Kolom checkbox (dari kiri ke kanan):
    // - Kolom 1: Memenuhi Syarat (Qualify)
    // - Kolom 2: Tidak Memenuhi Syarat (Unqualify)
    // - Kolom 3: Tampak Tanda-tanda (Visible Signs)
    // - Kolom 4: Tidak Tampak (No Signs)

    // Posisi X untuk masing-masing kolom checkbox (center of column)
    // Kolom checkbox TIDAK memiliki lebar yang sama!
    // Kolom 1 & 2 (Kondisi Sanitasi) lebih sempit
    // Kolom 3 & 4 (Vektor) lebih lebar
    const double col1X = 285; // Memenuhi Syarat (kolom sempit)
    const double col2X = 368; // Tidak Memenuhi Syarat (kolom medium)
    const double col3X = 454; // Tampak Tanda-tanda (kolom medium-lebar)
    const double col4X = 525; // Tidak Tampak (kolom paling lebar)

    // Posisi Y untuk setiap baris (dari atas)
    // Baris dimulai setelah header tabel
    const double rowStartY = 274; // Baris pertama (Dapur/Galley)
    const double rowHeight = 14.9; // Tinggi setiap baris (lebih rapat)

    // Map row indices to SanitationAreaKeys
    // Index 0 = Galley, 1 = Pantry, dst.
    final List<String?> rowKeys = [
      SanitationAreaKeys.galley, // Row 1: Dapur (Galley)
      SanitationAreaKeys.pantry, // Row 2: Ruang Rakit Makanan (Pantry)
      SanitationAreaKeys.store, // Row 3: Gudang (Store)
      SanitationAreaKeys.cargo, // Row 4: Palka (Cargo)
      null, // Row 5: Ruang Tidur (Quarter) - Parent header, no checkbox
      SanitationAreaKeys.quarterCrew, // Row 6: - ABK (Crew)
      SanitationAreaKeys.quarterOfficer, // Row 7: - Perwira (Officer)
      SanitationAreaKeys.quarterPassenger, // Row 8: - Penumpang (Passenger)
      SanitationAreaKeys.deck, // Row 9: - Geladak (Deck)
      SanitationAreaKeys.potableWater, // Row 10: Air Minum (Potable Water)
      SanitationAreaKeys.sewage, // Row 11: Limbah Cair (Sewage)
      SanitationAreaKeys.waterBallast, // Row 12: Air Balast (Water Balast)
      SanitationAreaKeys.medicalWaste, // Row 13: Limbah Medis/Padat
      SanitationAreaKeys.standingWater, // Row 14: Air Tergenang/Permukaan
      SanitationAreaKeys.engineRoom, // Row 15: Ruang Mesin (Engine Room)
      SanitationAreaKeys.medicalFacilities, // Row 16: Fasilitas Medik
      SanitationAreaKeys.otherArea, // Row 17: Area Lainnya
    ];

    // Build checkmark widgets
    List<pw.Widget> checkmarks = [];

    for (int i = 0; i < rowKeys.length; i++) {
      final key = rowKeys[i];
      if (key == null) continue; // Skip parent header rows

      final areaData = data.sanitationAreas[key];
      if (areaData == null) continue;

      final double rowY = rowStartY + (i * rowHeight);

      // Add checkmarks for each column if true
      if (areaData.qualify) {
        checkmarks.add(_buildCheckmark(col1X, rowY));
      }
      if (areaData.unqualify) {
        checkmarks.add(_buildCheckmark(col2X, rowY));
      }
      if (areaData.visibleSigns) {
        checkmarks.add(_buildCheckmark(col3X, rowY));
      }
      if (areaData.noSigns) {
        checkmarks.add(_buildCheckmark(col4X, rowY));
      }
    }

    // --- SIGNATURE AREA (CONTAINER) ---
    // Definisi area kotak tanda tangan
    // Signature akan otomatis di-center dalam kotak ini

    // Area tanda tangan Nahkoda (kiri)
    const double captainBoxX = 76; // X awal kotak
    const double captainBoxY = 604; // Y awal kotak
    const double captainBoxWidth = 150; // Lebar kotak (sesuai panjang garis)
    const double captainBoxHeight = 30; // Tinggi kotak

    // Area tanda tangan Pemeriksa (kanan)
    const double officerBoxX = 397; // X awal kotak
    const double officerBoxY = 604; // Y awal kotak
    const double officerBoxWidth = 150; // Lebar kotak
    const double officerBoxHeight = 30; // Tinggi kotak

    // Posisi nama (di bawah garis tanda tangan)
    const double nameY = 640; // Y untuk nama (di bawah tanda tangan)
    const double nameHeight = 15;

    // Build signature and name widgets
    List<pw.Widget> signatures = [];

    // === NAHKODA (Kiri) ===
    if (data.captainSignature != null) {
      signatures.add(
        pw.Positioned(
          left: captainBoxX,
          top: captainBoxY,
          child: pw.Container(
            width: captainBoxWidth,
            height: captainBoxHeight,
            alignment: pw.Alignment.center,
            child: pw.Image(
              pw.MemoryImage(data.captainSignature!),
              fit: pw.BoxFit.contain,
            ),
          ),
        ),
      );
    }

    // Nama Nahkoda (centered di bawah garis)
    if (data.captainName != null && data.captainName!.isNotEmpty) {
      signatures.add(
        pw.Positioned(
          left: captainBoxX,
          top: nameY,
          child: pw.Container(
            width: captainBoxWidth,
            height: nameHeight,
            alignment: pw.Alignment.center,
            child: pw.Text(
              data.captainName!,
              style: const pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),
      );
    }

    // === PEMERIKSA (Kanan) ===
    if (data.officerSignature != null) {
      signatures.add(
        pw.Positioned(
          left: officerBoxX,
          top: officerBoxY,
          child: pw.Container(
            width: officerBoxWidth,
            height: officerBoxHeight,
            alignment: pw.Alignment.center,
            child: pw.Image(
              pw.MemoryImage(data.officerSignature!),
              fit: pw.BoxFit.contain,
            ),
          ),
        ),
      );
    }

    // Nama Pemeriksa (centered di bawah garis)
    if (data.officerName != null && data.officerName!.isNotEmpty) {
      signatures.add(
        pw.Positioned(
          left: officerBoxX,
          top: nameY,
          child: pw.Container(
            width: officerBoxWidth,
            height: nameHeight,
            alignment: pw.Alignment.center,
            child: pw.Text(
              data.officerName!,
              style: const pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),
      );
    }

    // --- BUILD PDF PAGE ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Background overlay image
              pw.Positioned.fill(
                child: pw.Image(overlayImage, fit: pw.BoxFit.fill),
              ),

              // Checkmarks overlay
              ...checkmarks,

              // Signatures overlay
              ...signatures,
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Helper widget untuk membuat tanda centang (✓) yang digambar
  static pw.Widget _buildCheckmark(double x, double y) {
    const double size = 10;
    return pw.Positioned(
      left: x - size / 2,
      top: y,
      child: pw.CustomPaint(
        size: const PdfPoint(size, size),
        painter: (PdfGraphics canvas, PdfPoint size) {
          // Gambar checkmark dengan 2 garis
          // PDF Y=0 di bawah, jadi kita flip koordinatnya
          canvas
            ..setStrokeColor(PdfColors.black)
            ..setLineWidth(1.5)
            // Garis pendek dari kiri atas ke tengah bawah
            ..moveTo(0, size.y * 0.5)
            ..lineTo(size.x * 0.35, size.y * 0.15)
            // Garis panjang dari tengah bawah ke kanan atas
            ..lineTo(size.x, size.y * 0.85)
            ..strokePath();
        },
      ),
    );
  }

  /// Generate PDF untuk form Sanitasi dengan data overlay
  /// Ini adalah method alternatif yang bisa dipanggil langsung
  static Future<Uint8List> generateSanitationPdf(InspectionModel data) async {
    return generatePdf(data);
  }
}
