import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/inspection_model.dart';

/// PDF Generator menggunakan pendekatan overlay.
/// Gambar template `sanitasi.png` digunakan sebagai background,
/// lalu data (tanda centang ✓) diposisikan secara absolut di atasnya.
class PdfGenerator {
  static Future<Uint8List> generatePdf(InspectionModel data) async {
    // 1. Load template overlay image on Main Thread
    final Uint8List overlayBytes = (await rootBundle.load(
      'lib/pdf/form_2.png',
    )).buffer.asUint8List();
    
    // 2. Load font Calibri (Offline)
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

  static Future<Uint8List> _generatePdfTask(Map<String, dynamic> params) async {
    final InspectionModel data = params['data'] as InspectionModel;
    final Uint8List overlayBytes = params['overlayBytes'] as Uint8List;
    final Uint8List fontBytes = params['fontBytes'] as Uint8List;
    
    final ttf = pw.Font.ttf(fontBytes.buffer.asByteData());
    final pdf = pw.Document();
    final overlayImage = pw.MemoryImage(overlayBytes);

    // --- KOORDINAT CHECKBOX ---
    // ... (rest of coordinate definitions unchanged)
    // ...
    const double col1X = 285;
    const double col2X = 368;
    const double col3X = 454;
    const double col4X = 527;
    const double rowStartY = 274;
    const double rowHeight = 14.9;

    final List<String?> rowKeys = [
      SanitationAreaKeys.galley,
      SanitationAreaKeys.pantry,
      SanitationAreaKeys.store,
      SanitationAreaKeys.cargo,
      null,
      SanitationAreaKeys.quarterCrew,
      SanitationAreaKeys.quarterOfficer,
      SanitationAreaKeys.quarterPassenger,
      SanitationAreaKeys.deck,
      SanitationAreaKeys.potableWater,
      SanitationAreaKeys.sewage,
      SanitationAreaKeys.waterBallast,
      SanitationAreaKeys.medicalWaste,
      SanitationAreaKeys.standingWater,
      SanitationAreaKeys.engineRoom,
      SanitationAreaKeys.medicalFacilities,
      SanitationAreaKeys.otherArea,
    ];

    List<pw.Widget> checkmarks = [];

    for (int i = 0; i < rowKeys.length; i++) {
      final key = rowKeys[i];
      if (key == null) continue;

      final areaData = data.sanitationAreas[key];
      if (areaData == null) continue;

      final double rowY = rowStartY + (i * rowHeight);

      if (areaData.qualify) checkmarks.add(_buildCheckmark(col1X, rowY));
      if (areaData.unqualify) checkmarks.add(_buildCheckmark(col2X, rowY));
      if (areaData.visibleSigns) checkmarks.add(_buildCheckmark(col3X, rowY));
      if (areaData.noSigns) checkmarks.add(_buildCheckmark(col4X, rowY));
    }

    // --- SIGNATURE AREA ---
    const double captainBoxX = 76;
    const double captainBoxY = 604;
    const double captainBoxWidth = 150;
    const double captainBoxHeight = 30;
    
    const double officerBoxX = 397;
    const double officerBoxY = 604;
    const double officerBoxWidth = 150;
    const double officerBoxHeight = 30;
    
    const double nameY = 640;
    const double nameHeight = 15;

    List<pw.Widget> signatures = [];

    // === NAHKODA ===
    if (data.captainSignature != null) {
      signatures.add(
        pw.Positioned(
          left: captainBoxX, top: captainBoxY,
          child: pw.Container(
            width: captainBoxWidth, height: captainBoxHeight, alignment: pw.Alignment.center,
            child: pw.Image(pw.MemoryImage(data.captainSignature!), fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

    if (data.captainName != null && data.captainName!.isNotEmpty) {
      signatures.add(
        pw.Positioned(
          left: captainBoxX, top: nameY,
          child: pw.Container(
            width: captainBoxWidth, height: nameHeight, alignment: pw.Alignment.center,
            child: pw.Text(data.captainName!, style: pw.TextStyle(fontSize: 9, font: ttf), textAlign: pw.TextAlign.center),
          ),
        ),
      );
    }

    // === PEMERIKSA ===
    if (data.officerSignature != null) {
      signatures.add(
        pw.Positioned(
          left: officerBoxX, top: officerBoxY,
          child: pw.Container(
            width: officerBoxWidth, height: officerBoxHeight, alignment: pw.Alignment.center,
            child: pw.Image(pw.MemoryImage(data.officerSignature!), fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

    if (data.officerName != null && data.officerName!.isNotEmpty) {
      signatures.add(
        pw.Positioned(
          left: officerBoxX, top: nameY,
          child: pw.Container(
            width: officerBoxWidth, height: nameHeight, alignment: pw.Alignment.center,
            child: pw.Text(data.officerName!, style: pw.TextStyle(fontSize: 9, font: ttf), textAlign: pw.TextAlign.center),
          ),
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(child: pw.Image(overlayImage, fit: pw.BoxFit.fill)),
              ...checkmarks,
              ...signatures,
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ... _buildCheckmark and generateSanitationPdf ...

  /// Helper widget untuk membuat tanda centang (✓) yang digambar
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

  static Future<Uint8List> generateSanitationPdf(InspectionModel data) async {
    return generatePdf(data);
  }

  /// Tambahkan halaman Form 2 ke dokumen PDF yang sudah ada
  static void addPageToDocument(
    pw.Document pdf,
    InspectionModel data,
    Uint8List overlayBytes,
    pw.Font font, // Added font parameter
  ) {
    final ttf = font;
    final overlayImage = pw.MemoryImage(overlayBytes);

    // Koordinat checkbox
    const double col1X = 285;
    const double col2X = 368;
    const double col3X = 454;
    const double col4X = 527;
    const double rowStartY = 274;
    final double rowHeight = 14.9;

    final List<String?> rowKeys = [
      SanitationAreaKeys.galley,
      SanitationAreaKeys.pantry,
      SanitationAreaKeys.store,
      SanitationAreaKeys.cargo,
      null,
      SanitationAreaKeys.quarterCrew,
      SanitationAreaKeys.quarterOfficer,
      SanitationAreaKeys.quarterPassenger,
      SanitationAreaKeys.deck,
      SanitationAreaKeys.potableWater,
      SanitationAreaKeys.sewage,
      SanitationAreaKeys.waterBallast,
      SanitationAreaKeys.medicalWaste,
      SanitationAreaKeys.standingWater,
      SanitationAreaKeys.engineRoom,
      SanitationAreaKeys.medicalFacilities,
      SanitationAreaKeys.otherArea,
    ];

    List<pw.Widget> checkmarks = [];

    for (int i = 0; i < rowKeys.length; i++) {
      final key = rowKeys[i];
      if (key == null) continue;

      final areaData = data.sanitationAreas[key];
      if (areaData == null) continue;

      final double rowY = rowStartY + (i * rowHeight);

      if (areaData.qualify) checkmarks.add(_buildCheckmark(col1X, rowY));
      if (areaData.unqualify) checkmarks.add(_buildCheckmark(col2X, rowY));
      if (areaData.visibleSigns) checkmarks.add(_buildCheckmark(col3X, rowY));
      if (areaData.noSigns) checkmarks.add(_buildCheckmark(col4X, rowY));
    }

    // Signatures
    const double captainBoxX = 76;
    const double captainBoxY = 604;
    const double captainBoxWidth = 150;
    const double captainBoxHeight = 30;
    const double officerBoxX = 397;
    const double officerBoxY = 604;
    const double officerBoxWidth = 150;
    const double officerBoxHeight = 30;
    const double nameY = 640;
    const double nameHeight = 15;

    List<pw.Widget> signatures = [];

    if (data.captainSignature != null) {
      signatures.add(pw.Positioned(left: captainBoxX, top: captainBoxY, child: pw.Container(
        width: captainBoxWidth, height: captainBoxHeight, alignment: pw.Alignment.center,
        child: pw.Image(pw.MemoryImage(data.captainSignature!), fit: pw.BoxFit.contain),
      )));
    }
    if (data.captainName != null && data.captainName!.isNotEmpty) {
      signatures.add(pw.Positioned(left: captainBoxX, top: nameY, child: pw.Container(
        width: captainBoxWidth, height: nameHeight, alignment: pw.Alignment.center,
        child: pw.Text(data.captainName!, style: pw.TextStyle(fontSize: 9, font: ttf), textAlign: pw.TextAlign.center),
      )));
    }
    if (data.officerSignature != null) {
      signatures.add(pw.Positioned(left: officerBoxX, top: officerBoxY, child: pw.Container(
        width: officerBoxWidth, height: officerBoxHeight, alignment: pw.Alignment.center,
        child: pw.Image(pw.MemoryImage(data.officerSignature!), fit: pw.BoxFit.contain),
      )));
    }
    if (data.officerName != null && data.officerName!.isNotEmpty) {
      signatures.add(pw.Positioned(left: officerBoxX, top: nameY, child: pw.Container(
        width: officerBoxWidth, height: nameHeight, alignment: pw.Alignment.center,
        child: pw.Text(data.officerName!, style: pw.TextStyle(fontSize: 9, font: ttf), textAlign: pw.TextAlign.center),
      )));
    }

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (pw.Context context) {
        return pw.Stack(children: [
          pw.Positioned.fill(child: pw.Image(overlayImage, fit: pw.BoxFit.fill)),
          ...checkmarks,
          ...signatures,
        ]);
      },
    ));
  }
}
