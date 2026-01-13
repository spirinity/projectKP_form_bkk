import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/inspection_model.dart';

/// PDF Generator untuk Form 1 menggunakan pendekatan overlay.
/// Gambar template `form_1.png` digunakan sebagai background,
/// lalu data diposisikan secara absolut di atasnya.
/// 
/// Layout Form 1 (A4 = 595 x 842 points at 72 DPI):
/// ================================================
/// I. DATA UMUM (baris 1-7)
///    Kolom kiri: Nama Kapal, Bendera, Besar Kapal, Datang Dari, Tanggal, Tujuan, Tanggal
///    Kolom kanan: Nama Nahkoda, No. IMO, Lokasi Sandar, Jumlah ABK, Jumlah Penumpang, Penumpang Tdk Terdaftar, Keagenan
/// 
/// II. DATA KHUSUS
///    A. Pelanggaran Karantina
///       1. Isyarat Karantina: [Pasang] [Tidak Pasang]
///       2. Aktivitas: [Bongkar muat] [Naik/turun] [Tidak ada]
///    B. Dokumen Kesehatan Kapal (Tabel 9 baris)
///       Kolom: NO, JENIS DOKUMEN, KONDISI (Ada/Sehat/TdkSehat/Berlaku/TdkBerlaku/Sesuai/TdkSesuai), KETERANGAN (Tidak Ada, alasan)
///    C. Faktor Risiko PHEIC
///       1. Sanitasi Kapal: [Ada] [Tidak ada]
///       2. Risiko Orang & P3K: [Ada] [Tidak ada]
/// 
/// III. KESIMPULAN
///    [✓] Kapal Bebas PHEIC / [✓] Tidak Bebas PHEIC
/// 
/// IV. REKOMENDASI
///    A. Kapal dalam Karantina: [Free Pratique] [FP+Syarat] [No FP] + Tanggal + Jam
///    B. Kapal dalam Negeri: [Diberikan SIB] [Tidak] + NO + Tanggal + Jam
/// 
/// Tanda Tangan: Master, Petugas 1, Petugas 2, Petugas 3
class PdfGeneratorForm1 {
  // A4 dimensions at 72 DPI
  static const double pageWidth = 595.0;
  static const double pageHeight = 842.0;
  
  static Future<Uint8List> generatePdf(InspectionModel data) async {
    final pdf = pw.Document();

    // Load template overlay image
    final Uint8List overlayBytes = (await rootBundle.load(
      'lib/pdf/form_1.png',
    )).buffer.asUint8List();
    final overlayImage = pw.MemoryImage(overlayBytes);

    // Date formatter
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    // DEBUG: Print data to console
    print('=== FORM 1 PDF DATA DEBUG ===');
    print('shipName: ${data.shipName}');
    print('flag: ${data.flag}');
    print('grossTonnage: ${data.grossTonnage}');
    print('captainName: ${data.captainName}');
    print('imoNumber: ${data.imoNumber}');
    print('dockLocation: ${data.dockLocation}');
    print('lastPort: ${data.lastPort}');
    print('nextPort: ${data.nextPort}');
    print('agency: ${data.agency}');
    print('crewCount: ${data.crewCount}');
    print('passengerCount: ${data.passengerCount}');
    print('arrivalDate: ${data.arrivalDate}');
    print('departureDate: ${data.departureDate}');
    print('quarantineSignal: ${data.quarantineSignal}');
    print('shipActivity: ${data.shipActivity}');
    print('mdhStatus: ${data.mdhStatus}');
    print('sscecStatus: ${data.sscecStatus}');
    print('isPHEICFree: ${data.isPHEICFree}');
    print('==============================');

    List<pw.Widget> overlays = [];

    // ============================================================
    // I. DATA UMUM - Row positions (measured from form image)
    // ============================================================
    // Y positions for each row (from top of page)
    const double dataUmumY1 = 116;  // Nama Kapal / Nama Nahkoda (+10)
    const double dataUmumY2 = 127;  // Bendera / No. IMO (+10)
    const double dataUmumY3 = 138;  // Besar Kapal / Lokasi Sandar (+10)
    const double dataUmumY4 = 149; // Datang Dari / Jumlah ABK (+10)
    const double dataUmumY5 = 160; // Tanggal / Jumlah Penumpang (+10)
    const double dataUmumY6 = 171; // Tujuan / Penumpang Tdk Terdaftar (+10)
    const double dataUmumY7 = 182; // Tanggal / Keagenan (+10)
    
    // X positions for value columns (after the ":" colon)
    const double leftValueX = 160;   // Left column values (+10)
    const double rightValueX = 425;  // Right column values (+10)
    const double rightValueX2 = 560; // Far right (Orang counts) (+10)

    // Row 1: Nama Kapal | Nama Nahkoda
    if (data.shipName != null) {
      overlays.add(_buildText(leftValueX, dataUmumY1, data.shipName!));
    }
    if (data.captainName != null) {
      overlays.add(_buildText(rightValueX, dataUmumY1, data.captainName!));
    }

    // Row 2: Bendera | No. IMO
    if (data.flag != null) {
      overlays.add(_buildText(leftValueX, dataUmumY2, data.flag!));
    }
    if (data.imoNumber != null) {
      overlays.add(_buildText(rightValueX, dataUmumY2, data.imoNumber!));
    }

    // Row 3: Besar Kapal (GT) | Lokasi Sandar
    if (data.grossTonnage != null) {
      overlays.add(_buildText(leftValueX, dataUmumY3, data.grossTonnage!));
    }
    if (data.dockLocation != null) {
      overlays.add(_buildText(rightValueX, dataUmumY3, data.dockLocation!));
    }

    // Row 4: Datang Dari | Jumlah ABK + "Orang"
    if (data.lastPort != null) {
      overlays.add(_buildText(leftValueX, dataUmumY4, data.lastPort!));
    }
    if (data.crewCount != null) {
      overlays.add(_buildText(rightValueX, dataUmumY4, data.crewCount.toString()));
      overlays.add(_buildText(rightValueX2, dataUmumY4, 'Orang', fontSize: 7));
    }

    // Row 5: Tanggal (Kedatangan) | Jumlah Penumpang + "Orang"
    if (data.arrivalDate != null) {
      overlays.add(_buildText(leftValueX, dataUmumY5, dateFormat.format(data.arrivalDate!)));
    }
    if (data.passengerCount != null) {
      overlays.add(_buildText(rightValueX, dataUmumY5, data.passengerCount.toString()));
      overlays.add(_buildText(rightValueX2, dataUmumY5, 'Orang', fontSize: 7));
    }

    // Row 6: Tujuan | Penumpang Tdk Terdaftar + "Orang"
    if (data.nextPort != null) {
      overlays.add(_buildText(leftValueX, dataUmumY6, data.nextPort!));
    }
    if (data.unregisteredPassengers != null) {
      overlays.add(_buildText(rightValueX, dataUmumY6, data.unregisteredPassengers.toString()));
      overlays.add(_buildText(rightValueX2, dataUmumY6, 'Orang', fontSize: 7));
    }

    // Row 7: Tanggal (Keberangkatan) | Keagenan
    if (data.departureDate != null) {
      overlays.add(_buildText(leftValueX, dataUmumY7, dateFormat.format(data.departureDate!)));
    }
    if (data.agency != null) {
      overlays.add(_buildText(rightValueX, dataUmumY7, data.agency!));
    }

    // ============================================================
    // II.A. PELANGGARAN KARANTINA
    // ============================================================
    const double quarantineY = 181; // +15
    
    // 1. Isyarat Karantina: checkbox positions
    const double isyaratPasangX = 115; // +20
    const double isyaratTidakPasangX = 115; // +20
    const double isyaratPasangY = quarantineY;
    const double isyaratTidakPasangY = quarantineY + 9;
    
    if (data.quarantineSignal == 'Pasang') {
      overlays.add(_buildCheckmark(isyaratPasangX, isyaratPasangY));
    } else if (data.quarantineSignal == 'Tidak Pasang') {
      overlays.add(_buildCheckmark(isyaratTidakPasangX, isyaratTidakPasangY));
    }

    // 2. Aktivitas di atas Kapal (right side column)
    const double aktivitasX = 320; // +20
    const double aktivitasY1 = quarantineY;      // Ada bongkar muat
    const double aktivitasY2 = quarantineY + 9;  // Naik/turun orang
    const double aktivitasY3 = quarantineY + 18; // Tidak ada aktivitas
    
    if (data.shipActivity != null) {
      if (data.shipActivity!.contains('bongkar muat')) {
        overlays.add(_buildCheckmark(aktivitasX, aktivitasY1));
      } else if (data.shipActivity!.contains('Naik/turun') || data.shipActivity!.contains('naik turun')) {
        overlays.add(_buildCheckmark(aktivitasX, aktivitasY2));
      } else if (data.shipActivity!.contains('Tidak ada')) {
        overlays.add(_buildCheckmark(aktivitasX, aktivitasY3));
      }
    }

    // ============================================================
    // II.B. DOKUMEN KESEHATAN KAPAL (Tabel 9 baris)
    // ============================================================
    // Table starts after the header row
    const double docTableY = 233; // First data row (MDH) (+15)
    const double docRowHeight = 19.0; // Height per row
    
    // Column X positions for checkboxes in KONDISI columns
    const double colAda = 268;        // "Ada" column (+20)
    const double colSehat = 300;      // "Sehat/Berlaku/Sesuai" column (+20)
    const double colTidakSehat = 332; // "Tidak Sehat/Berlaku/Sesuai" column (+20)
    const double colTidakAda = 375;   // "Tidak Ada" column (in KETERANGAN) (+20)
    
    // Row 1: MDH (Maritime Declaration of Health)
    _addDocumentRow(overlays, 0, docTableY, docRowHeight, 
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.mdhStatus, hasStatusColumn: true);
    
    // Row 2: SSCEC / SSCC (spans 4 sub-rows in form)
    _addDocumentRow(overlays, 1, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.sscecStatus, hasStatusColumn: true);
    // Add SSCEC details (Tempat Terbit, Tanggal, Berlaku sampai)
    if (data.sscecPlace != null) {
      overlays.add(_buildText(105, docTableY + docRowHeight * 1.3, data.sscecPlace!, fontSize: 6));
    }
    if (data.sscecDate != null) {
      overlays.add(_buildText(105, docTableY + docRowHeight * 1.6, dateFormat.format(data.sscecDate!), fontSize: 6));
    }
    if (data.sscecExpiry != null) {
      overlays.add(_buildText(105, docTableY + docRowHeight * 1.9, dateFormat.format(data.sscecExpiry!), fontSize: 6));
    }
    
    // Row 3: Crew List / Daftar ABK
    _addDocumentRow(overlays, 2, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.crewListStatus, hasStatusColumn: false);
    
    // Row 4: Buku Kuning (ICV) / Profilaksis
    _addDocumentRow(overlays, 3, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.icvStatus, hasStatusColumn: true);
    
    // Row 5: P3K Kapal (spans multiple sub-rows)
    _addDocumentRow(overlays, 4, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.p3kStatus, hasStatusColumn: true);
    if (data.p3kPlace != null) {
      overlays.add(_buildText(105, docTableY + docRowHeight * 4.3, data.p3kPlace!, fontSize: 6));
    }
    if (data.p3kDate != null) {
      overlays.add(_buildText(105, docTableY + docRowHeight * 4.6, dateFormat.format(data.p3kDate!), fontSize: 6));
    }
    if (data.p3kExpiry != null) {
      overlays.add(_buildText(105, docTableY + docRowHeight * 4.9, dateFormat.format(data.p3kExpiry!), fontSize: 6));
    }
    
    // Row 6: Buku Kesehatan Kapal
    _addDocumentRow(overlays, 5, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.healthBookStatus, hasStatusColumn: true);
    if (data.healthBookPlace != null) {
      overlays.add(_buildText(105, docTableY + docRowHeight * 5.3, data.healthBookPlace!, fontSize: 6));
    }
    if (data.healthBookDate != null) {
      overlays.add(_buildText(105, docTableY + docRowHeight * 5.6, dateFormat.format(data.healthBookDate!), fontSize: 6));
    }
    
    // Row 7: Voyage Memo / Last Port o Call
    _addDocumentRow(overlays, 6, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.voyageMemoStatus, hasStatusColumn: false);
    
    // Row 8: Ship Particular
    _addDocumentRow(overlays, 7, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.shipParticularStatus, hasStatusColumn: false);
    
    // Row 9: Manifest Cargo
    _addDocumentRow(overlays, 8, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.manifestCargoStatus, hasStatusColumn: false);

    // ============================================================
    // II.C. FAKTOR RISIKO PHEIC
    // ============================================================
    const double risikoY = 430; // +15
    const double risikoAdaX = 265; // +20
    const double risikoTidakAdaX = 530; // "Tidak ada" checkbox on right side (+20)
    
    // 1. Faktor Risiko Sanitasi Kapal
    if (data.sanitationRisk) {
      overlays.add(_buildCheckmark(risikoAdaX, risikoY));
    } else {
      overlays.add(_buildCheckmark(risikoTidakAdaX, risikoY));
    }
    
    // 2. Faktor Risiko Orang dan P3K
    if (data.healthRisk) {
      overlays.add(_buildCheckmark(risikoAdaX, risikoY + 11));
    } else {
      overlays.add(_buildCheckmark(risikoTidakAdaX, risikoY + 11));
    }

    // ============================================================
    // III. KESIMPULAN
    // ============================================================
    const double kesimpulanY = 455; // +15
    const double kesimpulanBebasX = 160;      // Kapal Bebas PHEIC (+20)
    const double kesimpulanTidakBebasX = 260; // Tidak Bebas PHEIC (+20)
    
    if (data.isPHEICFree) {
      overlays.add(_buildCheckmark(kesimpulanBebasX, kesimpulanY));
    } else {
      overlays.add(_buildCheckmark(kesimpulanTidakBebasX, kesimpulanY));
    }

    // ============================================================
    // IV. REKOMENDASI
    // ============================================================
    
    // A. Kapal dalam Karantina
    const double rekA_Y = 477; // +15
    const double rekA_X = 115; // Checkbox X position (+20)
    const double rekA_TanggalX = 415; // +20
    const double rekA_JamX = 475; // +20
    
    if (data.quarantineRecommendation != null) {
      if (data.quarantineRecommendation == 'Free Pratique') {
        overlays.add(_buildCheckmark(rekA_X, rekA_Y));
      } else if (data.quarantineRecommendation == 'Free Pratique dengan Syarat') {
        overlays.add(_buildCheckmark(rekA_X, rekA_Y + 10));
      } else if (data.quarantineRecommendation == 'No Free Pratique') {
        overlays.add(_buildCheckmark(rekA_X, rekA_Y + 20));
      }
      
      // Date and time
      if (data.quarantineRecommendationDate != null) {
        overlays.add(_buildText(rekA_TanggalX, rekA_Y, dateFormat.format(data.quarantineRecommendationDate!), fontSize: 8));
        overlays.add(_buildText(rekA_JamX, rekA_Y, timeFormat.format(data.quarantineRecommendationDate!), fontSize: 8));
      }
    }
    
    // B. Kapal dalam Negeri
    const double rekB_Y = 518; // +15
    const double rekB_X = 115; // +20
    const double rekB_NoX = 250; // +20
    const double rekB_TanggalX = 350; // +20
    const double rekB_JamX = 440; // +20
    
    if (data.sibGiven) {
      overlays.add(_buildCheckmark(rekB_X, rekB_Y));
      if (data.sibNumber != null) {
        overlays.add(_buildText(rekB_NoX, rekB_Y, data.sibNumber!, fontSize: 8));
      }
      if (data.sibDate != null) {
        overlays.add(_buildText(rekB_TanggalX, rekB_Y, dateFormat.format(data.sibDate!), fontSize: 8));
        overlays.add(_buildText(rekB_JamX, rekB_Y, timeFormat.format(data.sibDate!), fontSize: 8));
      }
    } else {
      overlays.add(_buildCheckmark(rekB_X, rekB_Y + 10));
    }
    
    // Location text "Balikpapan," (+20)
    overlays.add(_buildText(450, rekB_Y + 10, 'Balikpapan,', fontSize: 8));

    // ============================================================
    // TANDA TANGAN
    // ============================================================
    const double signatureY = 565; // +15
    const double signatureWidth = 80;
    const double signatureHeight = 35;
    const double nameY = signatureY + 40;
    
    // MASTER (left side)
    const double masterX = 320; // +20
    
    List<pw.Widget> signatures = [];
    
    if (data.captainSignature != null) {
      signatures.add(
        pw.Positioned(
          left: masterX,
          top: signatureY,
          child: pw.Container(
            width: signatureWidth,
            height: signatureHeight,
            alignment: pw.Alignment.center,
            child: pw.Image(
              pw.MemoryImage(data.captainSignature!),
              fit: pw.BoxFit.contain,
            ),
          ),
        ),
      );
    }
    
    // Master name (under signature line)
    if (data.captainName != null && data.captainName!.isNotEmpty) {
      signatures.add(
        pw.Positioned(
          left: masterX,
          top: nameY,
          child: pw.Container(
            width: signatureWidth,
            height: 12,
            alignment: pw.Alignment.center,
            child: pw.Text(
              data.captainName!,
              style: const pw.TextStyle(fontSize: 7),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Petugas 1 (right of Master)
    const double petugas1X = 420; // +20
    
    if (data.officerSignature != null) {
      signatures.add(
        pw.Positioned(
          left: petugas1X,
          top: signatureY,
          child: pw.Container(
            width: signatureWidth,
            height: signatureHeight,
            alignment: pw.Alignment.center,
            child: pw.Image(
              pw.MemoryImage(data.officerSignature!),
              fit: pw.BoxFit.contain,
            ),
          ),
        ),
      );
    }

    // Officer Name
    if (data.officerName != null && data.officerName!.isNotEmpty) {
      signatures.add(
        pw.Positioned(
          left: petugas1X,
          top: nameY,
          child: pw.Container(
            width: signatureWidth,
            height: 12,
            alignment: pw.Alignment.center,
            child: pw.Text(
              data.officerName!,
              style: const pw.TextStyle(fontSize: 7),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),
      );
    }

    // ============================================================
    // BUILD PDF PAGE
    // ============================================================
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

              // All overlays (text + checkmarks)
              ...overlays,

              // Signatures overlay
              ...signatures,
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Helper untuk menambahkan checkbox dokumen
  static void _addDocumentRow(
    List<pw.Widget> overlays,
    int rowIndex,
    double startY,
    double rowHeight,
    double colAda,
    double colSehat,
    double colTidakSehat,
    double colTidakAda,
    String? status, {
    bool hasStatusColumn = false,
  }) {
    final double rowY = startY + (rowIndex * rowHeight);
    
    if (status == null) return;
    
    if (status == 'Ada') {
      overlays.add(_buildCheckmark(colAda, rowY));
    } else if (status == 'Sehat' || status == 'Berlaku' || status == 'Sesuai') {
      overlays.add(_buildCheckmark(colAda, rowY));
      if (hasStatusColumn) {
        overlays.add(_buildCheckmark(colSehat, rowY));
      }
    } else if (status == 'Tidak Sehat' || status == 'Tidak Berlaku' || status == 'Tidak Sesuai') {
      overlays.add(_buildCheckmark(colAda, rowY));
      if (hasStatusColumn) {
        overlays.add(_buildCheckmark(colTidakSehat, rowY));
      }
    } else if (status == 'Tidak Ada') {
      overlays.add(_buildCheckmark(colTidakAda, rowY));
    }
  }

  /// Helper widget untuk membuat text overlay
  static pw.Widget _buildText(double x, double y, String text, {double fontSize = 8}) {
    return pw.Positioned(
      left: x,
      top: y,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: fontSize),
      ),
    );
  }

  /// Helper widget untuk membuat tanda centang (✓) yang digambar
  static pw.Widget _buildCheckmark(double x, double y) {
    const double size = 7;
    return pw.Positioned(
      left: x - size / 2,
      top: y,
      child: pw.CustomPaint(
        size: const PdfPoint(size, size),
        painter: (PdfGraphics canvas, PdfPoint size) {
          canvas
            ..setStrokeColor(PdfColors.black)
            ..setLineWidth(1.0)
            ..moveTo(0, size.y * 0.5)
            ..lineTo(size.x * 0.35, size.y * 0.15)
            ..lineTo(size.x, size.y * 0.85)
            ..strokePath();
        },
      ),
    );
  }

  /// Alternative method name for clarity
  static Future<Uint8List> generateForm1Pdf(InspectionModel data) async {
    return generatePdf(data);
  }
}
