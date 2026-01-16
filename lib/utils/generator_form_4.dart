import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/inspection_model.dart';

/// PDF Generator untuk Form 4 (Health / Kesehatan)
/// Menggunakan pendekatan overlay pada gambar `form_4.png`.
class PdfGeneratorForm4 {
  static Future<Uint8List> generatePdf(InspectionModel data) async {
    // 1. Load template overlay image on Main Thread
    final Uint8List overlayBytes = (await rootBundle.load(
      'lib/pdf/form_4.png',
    )).buffer.asUint8List();
    
    // 2. Load font Calibri upon generation
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

  /// Internal task to run in isolate
  static Future<Uint8List> _generatePdfTask(Map<String, dynamic> params) async {
    // Initialize locale data for this isolate
    await initializeDateFormatting('id_ID', null);

    final InspectionModel data = params['data'] as InspectionModel;
    final Uint8List overlayBytes = params['overlayBytes'] as Uint8List;
    final Uint8List fontBytes = params['fontBytes'] as Uint8List; // Get font bytes
    
    final ttf = pw.Font.ttf(fontBytes.buffer.asByteData()); // Load font
    final pdf = pw.Document();
    final overlayImage = pw.MemoryImage(overlayBytes);
    
    // Format tanggal Indonesia: 14 Mei 2025
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

    // DEBUG GRID: Set to true to see coordinate lines
    const bool showLayoutGrid = false; 

    List<pw.Widget> overlays = [];
    
    // Grid Helper
    if (showLayoutGrid) {
      overlays.addAll(_buildGrid());
    }
    
    // Helper local to use ttf
    pw.Widget _buildText(double x, double y, String text, {double fontSize = 9}) {
      return pw.Positioned(
        left: x,
        top: y,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: fontSize,
            font: ttf, // Use Calibri
          ),
        ),
      );
    }

    // ============================================================
    // KOORDINAT BERDASARKAN GAMBAR CONTOH (Estimasi Grid)
    // ============================================================
    
    // --- 1. PETUGAS (HEADER) ---
    // Nama Petugas
    const double petugasX = 210;
    if (data.officerName != null) {
      overlays.add(_buildText(petugasX, 184, data.officerName!)); 
    }
    // NIP Petugas (Placeholder / Hardcoded for now as it's not in model)
    overlays.add(_buildText(petugasX, 209, "198XXXXX...")); 

    // --- 2. DATA KAPAL (MENYATAKAN BAHWA) ---
    const double shipDataX = 210;
    // Nama Kapal (Y ~ 205)
    if (data.shipName != null) {
      overlays.add(_buildText(shipDataX, 273, data.shipName!)); 
    }
    // Bendera (Y ~ 218)
    if (data.flag != null) {
      overlays.add(_buildText(shipDataX, 298, data.flag!));
    }
    // Pelabuhan Asal (Y ~ 231)
    if (data.lastPort != null) {
      overlays.add(_buildText(shipDataX, 323, data.lastPort!));
    }
    // Pelabuhan Tujuan (Y ~ 244)
    if (data.nextPort != null) {
      overlays.add(_buildText(shipDataX, 348, data.nextPort!));
    }

    // --- 3. JUMLAH ABK (Crew) ---
    const double crewDataX = 280;
    const double crewY = 386;
    
    // Total ABK
    if (data.crewCount != null) {
      overlays.add(_buildText(crewDataX, crewY, data.crewCount.toString()));
    }
    // Sehat
    if (data.crewHealthyCount != null) {
      overlays.add(_buildText(crewDataX, crewY + 26, data.crewHealthyCount.toString()));
    }
    // Sakit
    if (data.crewSickCount != null) {
      overlays.add(_buildText(crewDataX, crewY + 39, data.crewSickCount.toString()));
    }

    // --- 4. DOKUMEN KESEHATAN (IcV & P3K) ---

    // ICV / Vaccination
    // Style: Strikethrough (Coret) yang TIDAK dipilih
    if (data.icvStatus == 'Lengkap') {
      // Coret "Tidak Lengkap" (Right side)
      overlays.add(_buildStrikethrough(278, 466, 39)); 
    } else if (data.icvStatus == 'Tidak Lengkap') {
      // Coret "Lengkap" (Left side)
      overlays.add(_buildStrikethrough(345, 466, 71));
    }
    // Sertifikat Count
    if (data.icvCertificateCount != null) {
      overlays.add(_buildText(420, 464, data.icvCertificateCount!));
    }

    // Sertifikat P3K
    // Style: Strikethrough yang TIDAK dipilih
    if (data.p3kStatus == 'Tersedia') {
      // Coret "Tidak Tersedia" (Right side)
      overlays.add(_buildStrikethrough(277.5, 503, 40)); // Y=503
    } else if (data.p3kStatus == 'Tidak Tersedia') {
      // Coret "Tersedia" (Left side)
      overlays.add(_buildStrikethrough(395, 503, 70)); // Y=503
    }

    // --- 5. JUMLAH PENUMPANG (Passenger) ---
    const double passY = 540;
    const double passDataX = 280; // Aligned with Crew X

    // Total Passenger
    if (data.passengerCount != null) {
      overlays.add(_buildText(passDataX, passY, data.passengerCount.toString()));
    }
    // Sehat
    if (data.passengerHealthyCount != null) {
      overlays.add(_buildText(passDataX, passY + 26, data.passengerHealthyCount.toString()));
    }
    // Sakit
    if (data.passengerSickCount != null) {
      overlays.add(_buildText(passDataX, passY + 40, data.passengerSickCount.toString()));
    }

    // --- 6. TANDA TANGAN ---
    const double signatureY = 725; // Adjusted based on bottom area
    const double dateY = 693;
    
    // City & Date
    if (data.arrivalDate != null) {
      overlays.add(_buildText(87, dateY, "Balikpapan, ${dateFormat.format(data.arrivalDate!)}"));
    }

    const double masterX = 100;
    const double officerX = 410;

    // Master / Captain
    if (data.captainSignature != null) {
      overlays.add(pw.Positioned(
        left: masterX,
        top: signatureY,
        child: pw.Container(
          width: 100,
          height: 50,
          alignment: pw.Alignment.centerLeft,
          child: pw.Image(pw.MemoryImage(data.captainSignature!)),
        ),
      ));
    }
    if (data.captainName != null) {
      overlays.add(_buildText(masterX, signatureY + 50, data.captainName!));
    }

    // Officer
    if (data.officerSignature != null) {
      overlays.add(pw.Positioned(
        left: officerX,
        top: signatureY,
        child: pw.Container(
          width: 100,
          height: 50,
          alignment: pw.Alignment.center,
          child: pw.Image(pw.MemoryImage(data.officerSignature!)),
        ),
      ));
    }
    if (data.officerName != null) {
      overlays.add(pw.Positioned(
        left: officerX,
        top: signatureY + 49,
        child: pw.Container(
          width: 100,
          alignment: pw.Alignment.center,
          child: pw.Text(
            data.officerName!,
            style: pw.TextStyle(
              fontSize: 9,
              font: ttf,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ));
    }

    // --- BUILD PAGE ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(overlayImage, fit: pw.BoxFit.fill),
              ),
              ...overlays,
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- HELPER WIDGETS ---
  
  // NOTE: _buildText moved inside _generatePdfTask to capture ttf closure, or we can update signature.
  // To keep it clean, I moved it inside.
  // The static helper below is deprecated or remove it.
  
  static pw.Widget _buildStrikethrough(double x, double y, double width) {
    return pw.Positioned(
      left: x,
      top: y + 4, // Center vertically on text (assuming font size ~10)
      child: pw.Container(
        width: width,
        height: 1, // Thickness
        color: PdfColors.black,
      ),
    );
  }

  /// Helper untuk membuat Grid Garis Bantu (Merah)
  static List<pw.Widget> _buildGrid() {
    List<pw.Widget> grid = [];
    // Page dimensions (A4)
    const double w = 595.0;
    const double h = 842.0;
    const double step = 50.0;

    // Vertical lines (X)
    for (double x = 0; x <= w; x += step) {
      grid.add(
        pw.Positioned(
          left: x,
          top: 0,
          bottom: 0,
          child: pw.Container(
            width: 0.5,
            color: PdfColors.red,
          ),
        ),
      );
      grid.add(
        pw.Positioned(
          left: x + 2,
          top: 5,
          child: pw.Text(
            x.toInt().toString(),
            style: const pw.TextStyle(fontSize: 6, color: PdfColors.red),
          ),
        ),
      );
    }

    // Horizontal lines (Y)
    for (double y = 0; y <= h; y += step) {
      grid.add(
        pw.Positioned(
          left: 0,
          right: 0,
          top: y,
          child: pw.Container(
            height: 0.5,
            color: PdfColors.red,
          ),
        ),
      );
      grid.add(
        pw.Positioned(
          left: 5,
          top: y + 2,
          child: pw.Text(
            y.toInt().toString(),
            style: const pw.TextStyle(fontSize: 6, color: PdfColors.red),
          ),
        ),
      );
    }
    return grid;
  }

}