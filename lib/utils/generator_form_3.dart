import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/inspection_model.dart';

/// PDF Generator untuk Form 3
/// Hanya berisi Tanda Tangan dan Nama Nahkoda
class PdfGeneratorForm3 {
  static Future<Uint8List> generatePdf(InspectionModel data) async {
    // 1. Load template overlay image on Main Thread
    final Uint8List overlayBytes = (await rootBundle.load(
      'lib/pdf/form_3.png',
    )).buffer.asUint8List();

    // 2. Run PDF generation in a background isolate
    return await compute(_generatePdfTask, {
      'data': data,
      'overlayBytes': overlayBytes,
    });
  }

  /// Internal task to run in isolate
  static Future<Uint8List> _generatePdfTask(Map<String, dynamic> params) async {
    // Initialize locale data for this isolate
    await initializeDateFormatting('id_ID', null);

    final InspectionModel data = params['data'] as InspectionModel;
    final Uint8List overlayBytes = params['overlayBytes'] as Uint8List;

    final pdf = pw.Document();
    
    // We don't have the custom font here passed in params for standalone, 
    // but the combined generator will pass it. 
    // For standalone, we might use default font or load it if needed. 
    // keeping it simple for now using standard font in standalone if possible or just Times.
    // However, the `addPageToDocument` below expects ttf. 
    // For now, let's just make addPageToDocument optional ttf or use standard if null.
    // Actually, let's keep it simple: combined generator passes everything.
    
    // For standalone generic usage (if ever used), we'd need to load font.
    // But since we are moving to combined, let's focus on the methods structure.
    
    await addPageToDocument(pdf, data, overlayBytes, null);

    return pdf.save();
  }

  /// Menambahkan halaman Form 3 ke dokumen PDF yang sudah ada
  static Future<void> addPageToDocument(
    pw.Document pdf, 
    InspectionModel data, 
    Uint8List overlayBytes,
    pw.Font? ttf, // Optional, can use default if null
  ) async {
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

    // ============================================================
    // DATA FORM 3 (Hanya Nama & Tanda Tangan Nahkoda)
    // ============================================================

    // Koordinat Estimasi (Silakan disesuaikan dengan Coordinate Finder)
    const double signatureX = 380; // Posisi X Tanda Tangan
    const double signatureY = 650; // Posisi Y Tanda Tangan
    
    // 1. Tanda Tangan Nahkoda
    if (data.captainSignature != null) {
      overlays.add(pw.Positioned(
        left: signatureX,
        top: signatureY,
        child: pw.Container(
          width: 100,
          height: 50,
          alignment: pw.Alignment.center,
          child: pw.Image(pw.MemoryImage(data.captainSignature!)),
        ),
      ));
    }

    // 2. Nama Nahkoda
    if (data.captainName != null) {
      overlays.add(pw.Positioned(
        left: signatureX,
        top: signatureY + 50, // Di bawah tanda tangan
        child: pw.Container(
          width: 100,
          alignment: pw.Alignment.center,
          child: pw.Text(
            data.captainName!,
            style: pw.TextStyle(
              fontSize: 10.5,
              font: ttf ?? pw.Font.times(),
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
  }

  // --- HELPER WIDGETS ---
  
  static pw.Widget _buildText(double x, double y, String text, {double fontSize = 10.5}) {
    return pw.Positioned(
      left: x,
      top: y,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          font: pw.Font.times(),
        ),
      ),
    );
  }

  /// Helper untuk membuat Grid Garis Bantu (Merah)
  static List<pw.Widget> _buildGrid() {
    List<pw.Widget> grid = [];
    const double w = 595.0;
    const double h = 842.0;
    const double step = 50.0;

    for (double x = 0; x <= w; x += step) {
      grid.add(
        pw.Positioned(
          left: x,
          top: 0,
          bottom: 0,
          child: pw.Container(width: 0.5, color: PdfColors.red),
        ),
      );
      grid.add(
        pw.Positioned(
          left: x + 2,
          top: 5,
          child: pw.Text(x.toInt().toString(), style: const pw.TextStyle(fontSize: 6, color: PdfColors.red)),
        ),
      );
    }

    for (double y = 0; y <= h; y += step) {
      grid.add(
        pw.Positioned(
          left: 0,
          right: 0,
          top: y,
          child: pw.Container(height: 0.5, color: PdfColors.red),
        ),
      );
      grid.add(
        pw.Positioned(
          left: 5,
          top: y + 2,
          child: pw.Text(y.toInt().toString(), style: const pw.TextStyle(fontSize: 6, color: PdfColors.red)),
        ),
      );
    }
    return grid;
  }
}
