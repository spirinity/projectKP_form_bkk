import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/inspection_model.dart';

/// PDF Generator untuk Form 1 menggunakan pendekatan overlay.
/// Gambar template `form_1.png` digunakan sebagai background,
/// lalu data diposisikan secara absolut di atasnya.
class _DocCoords {
  final double y;                // Posisi Y default untuk kolom KONDISI (Sehat, Tidak Sehat)
  final double colAda;           // X untuk kolom "Ada"
  final double? colAdaY;         // Y untuk kolom "Ada" (jika berbeda dari y)
  final double? colSehat;        // X untuk kolom "Sehat/Berlaku/Sesuai" (nullable)
  final double? colSehatY;       // Y untuk kolom "Sehat/Berlaku/Sesuai"
  final double? colTidakSehat;   // X untuk kolom "Tidak Sehat/Tidak Berlaku" (nullable)
  final double? colTidakSehatY;  // Y untuk kolom "Tidak Sehat/Tidak Berlaku" (garis pertama)
  final double? colTidakSehatY2; // Y untuk garis kedua kolom "Tidak Berlaku"
  final double colTidakAda;      // X untuk kolom "Tidak Ada" (KETERANGAN)
  final double? colTidakAdaY;    // Y untuk kolom "Tidak Ada" (jika berbeda dari y)
  
  // Panjang garis strip per kolom (default = 10)
  final double stripWidthAda;        // Panjang strip untuk kolom Ada
  final double stripWidthSehat;      // Panjang strip untuk kolom Sehat
  final double stripWidthTidakSehat; // Panjang strip untuk kolom Tidak Sehat (garis pertama)
  final double? stripWidthTidakSehat2; // Panjang strip untuk garis kedua kolom Tidak Sehat
  final double stripWidthTidakAda;   // Panjang strip untuk kolom Tidak Ada
  final double gapBetweenLines;      // Gap antara 2 garis untuk double strikethrough
  
  // Koordinat untuk teks tambahan (tempat, tanggal, kadaluarsa)
  final double? extraTextX;
  final double? extraTextY1Offset;  // Offset Y dari y untuk baris 1
  final double? extraTextY2Offset;  // Offset Y dari y untuk baris 2
  final double? extraTextY3Offset;  // Offset Y dari y untuk baris 3
  
  const _DocCoords({
    required this.y,
    required this.colAda,
    this.colAdaY,       // Y terpisah untuk kolom Ada
    this.colSehat,
    this.colSehatY,     // Y terpisah untuk kolom Sehat
    this.colTidakSehat,
    this.colTidakSehatY, // Y terpisah untuk kolom Tidak Sehat (garis pertama)
    this.colTidakSehatY2, // Y untuk garis kedua
    required this.colTidakAda,
    this.colTidakAdaY,  // Y terpisah untuk kolom Tidak Ada
    // Panjang strip (default 10 jika tidak diisi)
    this.stripWidthAda = 15,
    this.stripWidthSehat = 18,
    this.stripWidthTidakSehat = 40,
    this.stripWidthTidakSehat2,
    this.stripWidthTidakAda = 35,
    this.gapBetweenLines = 4,
    this.extraTextX,
    this.extraTextY1Offset,
    this.extraTextY2Offset,
    this.extraTextY3Offset,
  });
  
  /// Apakah dokumen ini memiliki kolom kondisi (Sehat/Tidak Sehat)
  bool get hasStatusColumn => colSehat != null && colTidakSehat != null;
  
  /// Mendapatkan Y untuk kolom Ada (gunakan colAdaY jika ada, jika tidak gunakan y)
  double get adaY => colAdaY ?? y;
  
  /// Mendapatkan Y untuk kolom Sehat (gunakan colSehatY jika ada, jika tidak gunakan y)
  double get sehatY => colSehatY ?? y;
  
  /// Mendapatkan Y untuk kolom Tidak Sehat (gunakan colTidakSehatY jika ada, jika tidak gunakan y)
  double get tidakSehatY => colTidakSehatY ?? y;
  
  /// Mendapatkan Y untuk kolom Tidak Ada (gunakan colTidakAdaY jika ada, jika tidak gunakan y)
  double get tidakAdaY => colTidakAdaY ?? y;
}

/// ============================================================
/// KOORDINAT FORM 1 - EDIT DI SINI SAJA!
/// ============================================================
class _Form1Coords {
  // ⚙️ DEBUG MODE - Set ke true untuk menampilkan grid merah
  static const bool DEBUG_GRID = true;
  static const double gridSpacing = 10; // Jarak antar garis dalam points
  static const double defaultLetterSpacing = 0.1; // Jarak antar huruf (Negatif = Rapat)
  
  // I. DATA UMUM - Posisi Y (vertikal dari atas)
  static const double dataUmumY1 = 177;  // Nama Kapal / Nama Nahkoda
  static const double dataUmumY2 = 188;  // Bendera / No. IMO
  static const double dataUmumY3 = 198;  // Besar Kapal / Lokasi Sandar
  static const double dataUmumY4 = 208;  // Datang Dari / Jumlah ABK
  static const double dataUmumY5 = 218;  // Tanggal / Jumlah Penumpang
  static const double dataUmumY6 = 228;  // Tujuan / Penumpang Tdk Terdaftar
  static const double dataUmumY7 = 238;  // Tanggal / Keagenan
  
  // I. DATA UMUM - Posisi X (horizontal dari kiri)
  static const double leftValueX = 155;   // Kolom kiri (setelah ":")
  static const double rightValueX = 390;  // Kolom kanan (setelah ":")
  
  // II.A. PELANGGARAN KARANTINA
  static const double quarantineY = 277;
  static const double quarantineRowGap = 10;  // Jarak antar baris checkbox
  static const double isyaratX = 104;
  static const double aktivitasX = 284;
  
  // ==========================================================
  // II.B. DOKUMEN KESEHATAN KAPAL - Koordinat Per Dokumen
  // ==========================================================
  
  // 1. MDH (Maritime Declaration of Health)
  static const _DocCoords mdh = _DocCoords(
    y: 340,                   // Y untuk kolom KONDISI (Sehat, Tidak Sehat)
    colAda: 298,
    colAdaY: 330,
    colSehat: 275,
    colTidakSehat: 313,
    colTidakSehatY2: null,    // MDH hanya 1 garis
    colTidakAda: 361,         // X untuk kolom Tidak Ada (KETERANGAN) - diperbaiki
    colTidakAdaY: 335,        // Y untuk kolom Tidak Ada
  );

  // 2. SSCEC (Ship Sanitation Control Exemption Certificate)
  static const _DocCoords sscec = _DocCoords(
    y: 350,
    colAda: 298,
    colAdaY: 349,         // Y untuk kolom Ada
    colSehat: 274,        // Berlaku
    colSehatY: 369,       // Y untuk kolom Berlaku
    colTidakSehat: 316,   // Tidak Berlaku (X)
    colTidakSehatY: 364,  // Y untuk garis pertama Tidak Berlaku
    colTidakSehatY2: 375, // Y untuk garis kedua Tidak Berlaku
    colTidakAda: 361,     // X untuk kolom Tidak Ada (KETERANGAN) - diperbaiki
    colTidakAdaY: 364,
    stripWidthSehat: 28,
    stripWidthTidakSehat: 18,      // Panjang garis pertama
    stripWidthTidakSehat2: 27,     // Panjang garis kedua (lebih panjang)
    gapBetweenLines: 11,  // Gap khusus untuk SSCEC
    // Posisi teks tambahan: tempat, tanggal, kadaluarsa
    extraTextX: 148,
    extraTextY1Offset: 8,   // Tempat Terbit
    extraTextY2Offset: 18,   // Tanggal Terbit
    extraTextY3Offset: 28,   // Berlaku sampai
  );

  // 3. Crew List / Daftar ABK
  static const _DocCoords crewList = _DocCoords(
    y: 390,
    colAda: 298,          // X untuk kolom Ada
    colAdaY: 389,         // Y untuk kolom Ada
    colSehat: null, // tidak memiliki kolom sehat
    colTidakSehat: null,
    colTidakSehatY2: null,
    colTidakAda: 361,     // X untuk kolom Tidak Ada
    colTidakAdaY: 389,    // Y untuk kolom Tidak Ada
    stripWidthTidakAda: 33,
  );

  // 4. Buku Kuning (ICV) / Profilaksis
  static const _DocCoords icv = _DocCoords(
    y: 400,                   // Y untuk kolom KONDISI (Sesuai, Tidak Sesuai)
    colAda: 298,
    colAdaY: 398.5,           // Y untuk kolom Ada
    colSehat: 274,            // Sesuai
    colSehatY: 408,           // Y untuk kolom Sesuai
    colTidakSehat: 315,       // Tidak Sesuai
    colTidakSehatY: 408,      // Y untuk kolom Tidak Sesuai
    colTidakSehatY2: null,    // ICV hanya 1 garis
    colTidakAda: 361,         // X untuk kolom Tidak Ada (KETERANGAN)
    colTidakAdaY: 403.5,        // Y untuk kolom Tidak Ada
    stripWidthAda: 15,
    stripWidthSehat: 24,
    stripWidthTidakSehat: 42,
    stripWidthTidakAda: 35,
  );

  // 5. P3K Kapal
  static const _DocCoords p3k = _DocCoords(
    y: 500,                   // Y untuk kolom KONDISI (Berlaku, Tidak Berlaku)
    colAda: 298,
    colAdaY: 418,             // Y untuk kolom Ada
    colSehat: 274,            // Berlaku
    colSehatY: 437.5,         // Y untuk kolom Berlaku
    colTidakSehat: 316,       // Tidak Berlaku (X)
    colTidakSehatY: 433,      // Y untuk garis pertama Tidak Berlaku
    colTidakSehatY2: 443,     // Y untuk garis kedua Tidak Berlaku
    colTidakAda: 361,         // X untuk kolom Tidak Ada (KETERANGAN)
    colTidakAdaY: 433,        // Y untuk kolom Tidak Ada
    stripWidthAda: 15,
    stripWidthSehat: 28,
    stripWidthTidakSehat: 18,      // Panjang garis pertama
    stripWidthTidakSehat2: 27,     // Panjang garis kedua (lebih panjang)
    stripWidthTidakAda: 35,
    gapBetweenLines: 10,      // Gap antara 2 garis
    extraTextX: 148,
    extraTextY1Offset: -73,   // Tempat Terbit
    extraTextY2Offset: -63,   // Tanggal Terbit
    extraTextY3Offset: -53,   // Berlaku sampai
  );

  // 6. Buku Kesehatan Kapal
  static const _DocCoords healthBook = _DocCoords(
    y: 435,
    colAda: 298,
    colAdaY: 457,            // Y untuk kolom Ada
    colSehat: 274,           // Sesuai
    colSehatY: 472,          // Y untuk kolom Sesuai
    colTidakSehat: 316,      // Tidak Sesuai
    colTidakSehatY: 472,     // Y untuk kolom Tidak Sesuai
    colTidakSehatY2: null,
    colTidakAda: 361,
    colTidakAdaY: 467,       // Y untuk kolom Tidak Ada
    stripWidthSehat: 28,
    extraTextX: 148,
    extraTextY1Offset: 31,   // Tempat Terbit
    extraTextY2Offset: 41,   // Tanggal Terbit
  );

  // 7. Voyage Memo / Last Port o Call
  static const _DocCoords voyageMemo = _DocCoords(
    y: 491.5,
    colAda: 298,
    colSehat: null,
    colTidakSehat: null,
    colTidakSehatY2: null,
    colTidakAda: 361,
  );

  // 8. Ship Particular
  static const _DocCoords shipParticular = _DocCoords(
    y: 511,
    colAda: 298,
    colSehat: null,
    colTidakSehat: null,
    colTidakSehatY2: null,
    colTidakAda: 361,
  );

  // 9. Manifest Cargo
  static const _DocCoords manifestCargo = _DocCoords(
    y: 530.5,
    colAda: 298,
    colSehat: null,
    colTidakSehat: null,
    colTidakSehatY2: null,
    colTidakAda: 361,
  );
  
  // II.C. FAKTOR RISIKO PHEIC
  static const double risikoY = 551;
  static const double risikoAdaX = 242;
  static const double risikoTidakAdaX = 446;
  
  // III. KESIMPULAN
  static const double kesimpulanY = 455;
  static const double kesimpulanBebasX = 160;
  static const double kesimpulanTidakBebasX = 260;
  
  // IV. REKOMENDASI A
  static const double rekA_Y = 600;
  static const double rekA_X = 85;
  static const double rekA_TanggalX = 415;
  static const double rekA_JamX = 475;
  
  // IV. REKOMENDASI B
  static const double rekB_Y = 640;
  static const double rekB_X = 85;
  static const double rekB_NoX = 250;
  static const double rekB_TanggalX = 350;
  static const double rekB_JamX = 440;
  
  // TANDA TANGAN
  static const double signatureY = 600;
  static const double signatureWidth = 80;
  static const double signatureHeight = 35;
  static const double nameY = signatureY + 40;
  static const double masterX = 320;
  static const double petugas1X = 420;
  
  /// Helper untuk membuat grid debug
  static List<pw.Widget> buildDebugGrid() {
    if (!DEBUG_GRID) return [];
    
    List<pw.Widget> gridLines = [];
    const double pageWidth = 595.0;
    const double pageHeight = 842.0;
    
    // Garis horizontal (dari atas ke bawah)
    for (double y = 0; y <= pageHeight; y += gridSpacing) {
      gridLines.add(
        pw.Positioned(
          left: 0,
          top: y,
          child: pw.Container(
            width: pageWidth,
            height: 0.5,
            color: PdfColors.red,
          ),
        ),
      );
      // Label Y
      gridLines.add(
        pw.Positioned(
          left: 2,
          top: y + 1,
          child: pw.Text(
            '${y.toInt()}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.red),
          ),
        ),
      );
    }
    
    // Garis vertikal (dari kiri ke kanan)
    for (double x = 0; x <= pageWidth; x += gridSpacing) {
      gridLines.add(
        pw.Positioned(
          left: x,
          top: 0,
          child: pw.Container(
            width: 0.5,
            height: pageHeight,
            color: PdfColors.red,
          ),
        ),
      );
      // Label X
      gridLines.add(
        pw.Positioned(
          left: x + 1,
          top: 2,
          child: pw.Text(
            '${x.toInt()}',
            style: pw.TextStyle(fontSize: 6, color: PdfColors.red),
          ),
        ),
      );
    }
    
    return gridLines;
  }
}

class PdfGeneratorForm1 {
  // A4 dimensions at 72 DPI
  static const double pageWidth = 595.0;
  static const double pageHeight = 842.0;
  
  static Future<Uint8List> generatePdf(InspectionModel data) async {
    // 1. Load template overlay image on Main Thread
    final Uint8List overlayBytes = (await rootBundle.load(
      'lib/pdf/form_1.png',
    )).buffer.asUint8List();
    
    // 2. Load font Calibri from Assets (Offline)
    final Uint8List fontBytes = (await rootBundle.load(
      'lib/fonts/calibri.ttf',
    )).buffer.asUint8List();

    // 3. Run PDF generation in a background isolate
    return await compute(_generatePdfTask, {
      'data': data,
      'overlayBytes': overlayBytes,
      'fontBytes': fontBytes,
    });
  }

  /// Combined PDF Generator helper (if needed to be called from outside)
  static Future<void> addPageToDocument(
    pw.Document pdf,
    InspectionModel data,
    Uint8List overlayBytes,
    pw.Font font,
  ) async {
    // Re-using the logic inside _generatePdfTask structure but adapted for adding a page
    // Actually, to avoid code duplication, it's better if the task calling this passes the font.
    // Ensure this matches the signature expected by generator_combined.dart
    
    final ttf = font;
    final overlayImage = pw.MemoryImage(overlayBytes);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    List<pw.Widget> overlays = [];

    // Local helper
    pw.Widget _buildText(double x, double y, String text, {double fontSize = 8, pw.Font? font, double? letterSpacing}) {
      return pw.Positioned(
        left: x,
        top: y,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: fontSize, 
            font: font ?? ttf, 
            letterSpacing: letterSpacing ?? _Form1Coords.defaultLetterSpacing
          ),
        ),
      );
    }

    // Reuse the content generation logic...
    // To proceed cleanly, I will implement the content generation in a shared method or just inline it here 
    // since this class structure is a bit monolithic.
    
    // ... Copying the content logic from below ...
    
    _buildPageContent(overlays, data, dateFormat, timeFormat, ttf, _buildText);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(overlayImage),
              ),
              ...overlays,
            ],
          );
        },
      ),
    );
  }

  /// Internal task to run in isolate
  static Future<Uint8List> _generatePdfTask(Map<String, dynamic> params) async {
    final InspectionModel data = params['data'] as InspectionModel;
    final Uint8List overlayBytes = params['overlayBytes'] as Uint8List;
    final Uint8List fontBytes = params['fontBytes'] as Uint8List;
    
    final ttf = pw.Font.ttf(fontBytes.buffer.asByteData());
    final pdf = pw.Document();
    
    // We can just call addPageToDocument here
    await addPageToDocument(pdf, data, overlayBytes, ttf);

    return pdf.save();
  }

  // Refactored content builder to avoid duplication between generatePdf and addPageToDocument
  static void _buildPageContent(
    List<pw.Widget> overlays,
    InspectionModel data,
    DateFormat dateFormat,
    DateFormat timeFormat,
    pw.Font ttf,
    Function(double, double, String, {double fontSize, pw.Font? font}) _buildText,
  ) {
    if (_Form1Coords.DEBUG_GRID) {
      overlays.addAll(_Form1Coords.buildDebugGrid());
    }

    // Row 1: Nama Kapal | Nama Nahkoda
    if (data.shipName != null) {
      overlays.add(_buildText(_Form1Coords.leftValueX, _Form1Coords.dataUmumY1, data.shipName!));
    }
    if (data.captainName != null) {
      overlays.add(_buildText(_Form1Coords.rightValueX, _Form1Coords.dataUmumY1, data.captainName!));
    }

    // Row 2: Bendera | No. IMO
    if (data.flag != null) {
      overlays.add(_buildText(_Form1Coords.leftValueX, _Form1Coords.dataUmumY2, data.flag!));
    }
    if (data.imoNumber != null) {
      overlays.add(_buildText(_Form1Coords.rightValueX, _Form1Coords.dataUmumY2, data.imoNumber!));
    }

    // Row 3: Besar Kapal (GT) | Lokasi Sandar
    if (data.grossTonnage != null) {
      overlays.add(_buildText(_Form1Coords.leftValueX, _Form1Coords.dataUmumY3, data.grossTonnage!));
    }
    if (data.dockLocation != null) {
      overlays.add(_buildText(_Form1Coords.rightValueX, _Form1Coords.dataUmumY3, data.dockLocation!));
    }

    // Row 4: Datang Dari | Jumlah ABK
    if (data.lastPort != null) {
      overlays.add(_buildText(_Form1Coords.leftValueX, _Form1Coords.dataUmumY4, data.lastPort!));
    }
    if (data.crewCount != null) {
      overlays.add(_buildText(_Form1Coords.rightValueX, _Form1Coords.dataUmumY4, data.crewCount.toString()));
    }

    // Row 5: Tanggal (Kedatangan) | Jumlah Penumpang
    if (data.arrivalDate != null) {
      overlays.add(_buildText(_Form1Coords.leftValueX, _Form1Coords.dataUmumY5, dateFormat.format(data.arrivalDate!)));
    }
    if (data.passengerCount != null) {
      overlays.add(_buildText(_Form1Coords.rightValueX, _Form1Coords.dataUmumY5, data.passengerCount.toString()));
    }

    // Row 6: Tujuan | Penumpang Tdk Terdaftar
    if (data.nextPort != null) {
      overlays.add(_buildText(_Form1Coords.leftValueX, _Form1Coords.dataUmumY6, data.nextPort!));
    }
    if (data.unregisteredPassengers != null) {
      overlays.add(_buildText(_Form1Coords.rightValueX, _Form1Coords.dataUmumY6, data.unregisteredPassengers.toString()));
    }

    // Row 7: Tanggal (Keberangkatan) | Keagenan
    if (data.departureDate != null) {
      overlays.add(_buildText(_Form1Coords.leftValueX, _Form1Coords.dataUmumY7, dateFormat.format(data.departureDate!)));
    }
    if (data.agency != null) {
      overlays.add(_buildText(_Form1Coords.rightValueX, _Form1Coords.dataUmumY7, data.agency!));
    }

    // II.A. PELANGGARAN KARANTINA
    if (data.quarantineSignal == 'Pasang') {
      overlays.add(_buildCheckmark(_Form1Coords.isyaratX, _Form1Coords.quarantineY));
    } else if (data.quarantineSignal == 'Tidak Pasang') {
      overlays.add(_buildCheckmark(_Form1Coords.isyaratX, _Form1Coords.quarantineY + _Form1Coords.quarantineRowGap));
    }

    if (data.shipActivity != null) {
      if (data.shipActivity!.contains('bongkar muat')) {
        overlays.add(_buildCheckmark(_Form1Coords.aktivitasX, _Form1Coords.quarantineY));
      } else if (data.shipActivity!.contains('Naik/turun') || data.shipActivity!.contains('naik turun')) {
        overlays.add(_buildCheckmark(_Form1Coords.aktivitasX, _Form1Coords.quarantineY + _Form1Coords.quarantineRowGap));
      } else if (data.shipActivity!.contains('Tidak ada')) {
        overlays.add(_buildCheckmark(_Form1Coords.aktivitasX, _Form1Coords.quarantineY + _Form1Coords.quarantineRowGap * 2));
      }
    }

    // II.B. DOKUMEN KESEHATAN KAPAL
    _addDocWithCoords(overlays, _Form1Coords.mdh, data.mdhStatus);
    
    _addDocWithCoords(overlays, _Form1Coords.sscec, data.sscecStatus);
    _addDocExtraText(overlays, _Form1Coords.sscec, dateFormat,
      text1: data.sscecPlace,
      date1: data.sscecDate,
      date2: data.sscecExpiry,
      font: ttf,
    );
    
    // DEBUG: Cek status Crew List
    if (kDebugMode) {
      print('Crew List Status from data: ${data.crewListStatus}');
    }
    _addDocWithCoords(overlays, _Form1Coords.crewList, data.crewListStatus);
    
    _addDocWithCoords(overlays, _Form1Coords.icv, data.icvStatus);
    
    _addDocWithCoords(overlays, _Form1Coords.p3k, data.p3kStatus);
    _addDocExtraText(overlays, _Form1Coords.p3k, dateFormat,
      text1: data.p3kPlace,
      date1: data.p3kDate,
      date2: data.p3kExpiry,
      font: ttf,
    );
    
    _addDocWithCoords(overlays, _Form1Coords.healthBook, data.healthBookStatus);
    _addDocExtraText(overlays, _Form1Coords.healthBook, dateFormat,
      text1: data.healthBookPlace,
      date1: data.healthBookDate,
      font: ttf,
    );
    
    _addDocWithCoords(overlays, _Form1Coords.voyageMemo, data.voyageMemoStatus);
    _addDocWithCoords(overlays, _Form1Coords.shipParticular, data.shipParticularStatus);
    _addDocWithCoords(overlays, _Form1Coords.manifestCargo, data.manifestCargoStatus);

    // II.C. FAKTOR RISIKO PHEIC
    if (data.sanitationRisk == true) {
      overlays.add(_buildCheckmark(_Form1Coords.risikoAdaX, _Form1Coords.risikoY));
    } else {
      overlays.add(_buildCheckmark(_Form1Coords.risikoTidakAdaX, _Form1Coords.risikoY));
    }
    
    if (data.healthRisk == true) {
      overlays.add(_buildCheckmark(_Form1Coords.risikoAdaX, _Form1Coords.risikoY + 11));
    } else {
      overlays.add(_buildCheckmark(_Form1Coords.risikoTidakAdaX, _Form1Coords.risikoY + 11));
    }

    // III. KESIMPULAN
    if (data.isPHEICFree == true) {
      overlays.add(_buildCheckmark(_Form1Coords.kesimpulanBebasX, _Form1Coords.kesimpulanY));
    } else {
      overlays.add(_buildCheckmark(_Form1Coords.kesimpulanTidakBebasX, _Form1Coords.kesimpulanY));
    }

    // IV. REKOMENDASI
    // A. Kapal dalam Karantina
    if (data.quarantineRecommendation != null) {
      if (data.quarantineRecommendation == 'Free Pratique') {
        overlays.add(_buildCheckmark(_Form1Coords.rekA_X, _Form1Coords.rekA_Y));
      } else if (data.quarantineRecommendation == 'Free Pratique dengan Syarat') {
        overlays.add(_buildCheckmark(_Form1Coords.rekA_X, _Form1Coords.rekA_Y + 10));
      } else if (data.quarantineRecommendation == 'No Free Pratique') {
        overlays.add(_buildCheckmark(_Form1Coords.rekA_X, _Form1Coords.rekA_Y + 20));
      }
      
      if (data.quarantineRecommendationDate != null) {
        overlays.add(_buildText(_Form1Coords.rekA_TanggalX, _Form1Coords.rekA_Y, dateFormat.format(data.quarantineRecommendationDate!), fontSize: 8));
        overlays.add(_buildText(_Form1Coords.rekA_JamX, _Form1Coords.rekA_Y, timeFormat.format(data.quarantineRecommendationDate!), fontSize: 8));
      }
    }
    
    // B. Kapal dalam Negeri
    if (data.sibGiven == true) {
      overlays.add(_buildCheckmark(_Form1Coords.rekB_X, _Form1Coords.rekB_Y));
      if (data.sibNumber != null) {
        overlays.add(_buildText(_Form1Coords.rekB_NoX, _Form1Coords.rekB_Y, data.sibNumber!, fontSize: 8));
      }
      if (data.sibDate != null) {
        overlays.add(_buildText(_Form1Coords.rekB_TanggalX, _Form1Coords.rekB_Y, dateFormat.format(data.sibDate!), fontSize: 8));
        overlays.add(_buildText(_Form1Coords.rekB_JamX, _Form1Coords.rekB_Y, timeFormat.format(data.sibDate!), fontSize: 8));
      }
    } else {
      overlays.add(_buildCheckmark(_Form1Coords.rekB_X, _Form1Coords.rekB_Y + 10));
    }
    
    overlays.add(_buildText(450, _Form1Coords.rekB_Y + 10, 'Balikpapan,', fontSize: 8));

    // TANDA TANGAN
    if (data.captainSignature != null) {
      overlays.add(pw.Positioned(
        left: _Form1Coords.masterX, top: _Form1Coords.signatureY,
        child: pw.Container(
          width: _Form1Coords.signatureWidth, height: _Form1Coords.signatureHeight,
          alignment: pw.Alignment.center,
          child: pw.Image(pw.MemoryImage(data.captainSignature!)),
        ),
      ));
    }
    
    if (data.captainName != null && data.captainName!.isNotEmpty) {
      overlays.add(pw.Positioned(
        left: _Form1Coords.masterX, top: _Form1Coords.nameY,
        child: pw.Container(
          width: _Form1Coords.signatureWidth, height: 12, alignment: pw.Alignment.center,
          child: pw.Text(data.captainName!, style: pw.TextStyle(fontSize: 8, font: ttf), textAlign: pw.TextAlign.center),
        ),
      ));
    }

    if (data.officerSignature != null) {
      overlays.add(pw.Positioned(
        left: _Form1Coords.petugas1X, top: _Form1Coords.signatureY,
        child: pw.Container(
          width: _Form1Coords.signatureWidth, height: _Form1Coords.signatureHeight,
          alignment: pw.Alignment.center,
          child: pw.Image(pw.MemoryImage(data.officerSignature!)),
        ),
      ));
    }

    if (data.officerName != null && data.officerName!.isNotEmpty) {
      overlays.add(pw.Positioned(
        left: _Form1Coords.petugas1X, top: _Form1Coords.nameY,
        child: pw.Container(
          width: _Form1Coords.signatureWidth, height: 12, alignment: pw.Alignment.center,
          child: pw.Text(data.officerName!, style: pw.TextStyle(fontSize: 8, font: ttf), textAlign: pw.TextAlign.center),
        ),
      ));
    }
  }

  // ============================================================
  // HELPER FUNCTIONS
  // ============================================================

  static void _addDocWithCoords(
    List<pw.Widget> overlays,
    _DocCoords coords,
    String? status,
  ) {
    if (status == null) return;
    
    final double adaY = coords.adaY;
    final double sehatY = coords.sehatY;
    final double tidakSehatY = coords.tidakSehatY;
    final double tidakAdaY = coords.tidakAdaY;
    
    switch (status) {
      case 'Ada':
        overlays.add(_buildStrikethrough(coords.colTidakAda, tidakAdaY, width: coords.stripWidthTidakAda));
        break;
      case 'Sehat':
      case 'Berlaku':
      case 'Sesuai':
        if (coords.hasStatusColumn) {
          // Coret kolom "Tidak Sehat/Tidak Berlaku/Tidak Sesuai"
          // Garis pertama
          overlays.add(_buildStrikethrough(coords.colTidakSehat!, tidakSehatY, width: coords.stripWidthTidakSehat));
          // Garis kedua (jika ada)
          if (coords.colTidakSehatY2 != null && coords.stripWidthTidakSehat2 != null) {
            overlays.add(_buildStrikethrough(coords.colTidakSehat!, coords.colTidakSehatY2!, width: coords.stripWidthTidakSehat2!));
          }
        }
        // Coret kolom "Tidak Ada" karena dokumen Ada dan Berlaku
        overlays.add(_buildStrikethrough(coords.colTidakAda, tidakAdaY, width: coords.stripWidthTidakAda));
        break;
      case 'Tidak Sehat':
      case 'Tidak Berlaku':
      case 'Tidak Sesuai':
        if (coords.hasStatusColumn) {
          // Coret kolom "Sehat/Berlaku/Sesuai" dengan 1 garis
          overlays.add(_buildStrikethrough(coords.colSehat!, sehatY, width: coords.stripWidthSehat));
        }
        // Coret kolom "Tidak Ada" karena dokumen Ada tapi Tidak Sehat/Tidak Berlaku
        overlays.add(_buildStrikethrough(coords.colTidakAda, tidakAdaY, width: coords.stripWidthTidakAda));
        break;
      case 'Tidak Ada':
        overlays.add(_buildStrikethrough(coords.colAda, adaY, width: coords.stripWidthAda));
        if (coords.hasStatusColumn) {
          overlays.add(_buildStrikethrough(coords.colSehat!, sehatY, width: coords.stripWidthSehat));
          // Coret kolom "Tidak Sehat/Tidak Berlaku/Tidak Sesuai"
          // Garis pertama
          overlays.add(_buildStrikethrough(coords.colTidakSehat!, tidakSehatY, width: coords.stripWidthTidakSehat));
          // Garis kedua (jika ada)
          if (coords.colTidakSehatY2 != null && coords.stripWidthTidakSehat2 != null) {
            overlays.add(_buildStrikethrough(coords.colTidakSehat!, coords.colTidakSehatY2!, width: coords.stripWidthTidakSehat2!));
          }
        }
        break;
    }
  }

  static void _addDocExtraText(
    List<pw.Widget> overlays,
    _DocCoords coords,
    DateFormat dateFormat, {
    String? text1,
    DateTime? date1,
    DateTime? date2,
    pw.Font? font,
  }) {
    final double? x = coords.extraTextX;
    if (x == null) return;
    
    // Default font size matched to 9 for consistency
    const double smallFontSize = 8;

    if (text1 != null && coords.extraTextY1Offset != null) {
      overlays.add(_buildStaticText(x, coords.y + coords.extraTextY1Offset!, text1, fontSize: smallFontSize, font: font));
    }
    
    if (date1 != null && coords.extraTextY2Offset != null) {
      overlays.add(_buildStaticText(x, coords.y + coords.extraTextY2Offset!, dateFormat.format(date1), fontSize: smallFontSize, font: font));
    }
    
    if (date2 != null && coords.extraTextY3Offset != null) {
      overlays.add(_buildStaticText(x, coords.y + coords.extraTextY3Offset!, dateFormat.format(date2), fontSize: smallFontSize, font: font));
    }
  }

  static pw.Widget _buildStrikethrough(double x, double y, {double width = 10}) {
    const double height = 1;
    return pw.Positioned(
      left: x - width / 2,
      top: y + 3,
      child: pw.Container(
        width: width,
        height: height,
        color: PdfColors.black,
      ),
    );
  }
  
  /// Membuat dua garis paralel (atas dan bawah) dengan gap di tengah
  /// width1 = panjang garis pertama (atas), width2 = panjang garis kedua (bawah)
  static List<pw.Widget> _buildDoubleStrikethroughList(double x, double y, {double width1 = 10, double? width2, double gap = 4}) {
    const double height = 1;
    final double secondWidth = width2 ?? width1; // Jika width2 tidak diisi, gunakan width1
    
    return [
      // Garis atas
      pw.Positioned(
        left: x - width1 / 2,
        top: y + 3,
        child: pw.Container(
          width: width1,
          height: height,
          color: PdfColors.black,
        ),
      ),
      // Garis bawah
      pw.Positioned(
        left: x - secondWidth / 2,
        top: y + 3 + gap,
        child: pw.Container(
          width: secondWidth,
          height: height,
          color: PdfColors.black,
        ),
      ),
    ];
  }
  
  static pw.Widget _buildCheckmark(double x, double y) {
    const double size = 10;
    return pw.Positioned(
      left: x - size / 2,
      top: y,
      child: pw.CustomPaint(
        size: const PdfPoint(size, size),
        painter: (PdfGraphics canvas, PdfPoint size) {
          canvas
            ..setStrokeColor(PdfColors.black)
            ..setLineWidth(1.5)
            ..moveTo(0, size.y * 0.5)
            ..lineTo(size.x * 0.35, size.y * 0.15)
            ..lineTo(size.x, size.y * 0.85)
            ..strokePath();
        },
      ),
    );
  }

  static pw.Widget _buildStaticText(double x, double y, String text, {double fontSize = 8, pw.Font? font, double? letterSpacing}) {
    return pw.Positioned(
      left: x,
      top: y,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize, 
          font: font, 
          letterSpacing: letterSpacing ?? _Form1Coords.defaultLetterSpacing
        ),
      ),
    );
  }
}
