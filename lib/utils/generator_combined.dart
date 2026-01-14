import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/inspection_model.dart';

/// Combined PDF Generator yang menggabungkan Form 1 dan Form 2 menjadi satu dokumen PDF.
/// Form 1 (Data Kapal) akan menjadi halaman pertama, Form 2 (Sanitasi) halaman kedua.
class CombinedPdfGenerator {
  // A4 dimensions at 72 DPI
  static const double pageWidth = 595.0;
  static const double pageHeight = 842.0;

  /// Generate PDF gabungan dengan Form 1 di halaman 1 dan Form 2 di halaman 2
  static Future<Uint8List> generateCombinedPdf(InspectionModel data) async {
    // Load both template images on Main Thread (AssetBundle is not available in Isolate)
    final Uint8List form1Bytes = (await rootBundle.load(
      'lib/pdf/form_1.png',
    )).buffer.asUint8List();
    
    final Uint8List form2Bytes = (await rootBundle.load(
      'lib/pdf/form_2.png',
    )).buffer.asUint8List();

    // Run PDF generation in a background isolate to avoid blocking the UI
    return await compute(_generateCombinedPdfTask, {
      'data': data,
      'form1Bytes': form1Bytes,
      'form2Bytes': form2Bytes,
    });
  }

  /// Internal task to run in isolate
  static Future<Uint8List> _generateCombinedPdfTask(Map<String, dynamic> params) async {
    final InspectionModel data = params['data'] as InspectionModel;
    final Uint8List form1Bytes = params['form1Bytes'] as Uint8List;
    final Uint8List form2Bytes = params['form2Bytes'] as Uint8List;

    final pdf = pw.Document();
    final form1Image = pw.MemoryImage(form1Bytes);
    final form2Image = pw.MemoryImage(form2Bytes);

    // Date formatter
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    // ============================================================
    // PAGE 1: FORM 1 - DATA KAPAL
    // ============================================================
    List<pw.Widget> form1Overlays = [];
    
    // I. DATA UMUM - Y positions
    const double dataUmumY1 = 116;
    const double dataUmumY2 = 127;
    const double dataUmumY3 = 138;
    const double dataUmumY4 = 149;
    const double dataUmumY5 = 160;
    const double dataUmumY6 = 171;
    const double dataUmumY7 = 182;
    
    const double leftValueX = 160;
    const double rightValueX = 425;
    const double rightValueX2 = 560;

    // Row 1: Nama Kapal | Nama Nahkoda
    if (data.shipName != null) {
      form1Overlays.add(_buildText(leftValueX, dataUmumY1, data.shipName!));
    }
    if (data.captainName != null) {
      form1Overlays.add(_buildText(rightValueX, dataUmumY1, data.captainName!));
    }

    // Row 2: Bendera | No. IMO
    if (data.flag != null) {
      form1Overlays.add(_buildText(leftValueX, dataUmumY2, data.flag!));
    }
    if (data.imoNumber != null) {
      form1Overlays.add(_buildText(rightValueX, dataUmumY2, data.imoNumber!));
    }

    // Row 3: Besar Kapal (GT) | Lokasi Sandar
    if (data.grossTonnage != null) {
      form1Overlays.add(_buildText(leftValueX, dataUmumY3, data.grossTonnage!));
    }
    if (data.dockLocation != null) {
      form1Overlays.add(_buildText(rightValueX, dataUmumY3, data.dockLocation!));
    }

    // Row 4: Datang Dari | Jumlah ABK + "Orang"
    if (data.lastPort != null) {
      form1Overlays.add(_buildText(leftValueX, dataUmumY4, data.lastPort!));
    }
    if (data.crewCount != null) {
      form1Overlays.add(_buildText(rightValueX, dataUmumY4, data.crewCount.toString()));
      form1Overlays.add(_buildText(rightValueX2, dataUmumY4, 'Orang', fontSize: 7));
    }

    // Row 5: Tanggal (Kedatangan) | Jumlah Penumpang + "Orang"
    if (data.arrivalDate != null) {
      form1Overlays.add(_buildText(leftValueX, dataUmumY5, dateFormat.format(data.arrivalDate!)));
    }
    if (data.passengerCount != null) {
      form1Overlays.add(_buildText(rightValueX, dataUmumY5, data.passengerCount.toString()));
      form1Overlays.add(_buildText(rightValueX2, dataUmumY5, 'Orang', fontSize: 7));
    }

    // Row 6: Tujuan | Penumpang Tdk Terdaftar + "Orang"
    if (data.nextPort != null) {
      form1Overlays.add(_buildText(leftValueX, dataUmumY6, data.nextPort!));
    }
    if (data.unregisteredPassengers != null) {
      form1Overlays.add(_buildText(rightValueX, dataUmumY6, data.unregisteredPassengers.toString()));
      form1Overlays.add(_buildText(rightValueX2, dataUmumY6, 'Orang', fontSize: 7));
    }

    // Row 7: Tanggal (Keberangkatan) | Keagenan
    if (data.departureDate != null) {
      form1Overlays.add(_buildText(leftValueX, dataUmumY7, dateFormat.format(data.departureDate!)));
    }
    if (data.agency != null) {
      form1Overlays.add(_buildText(rightValueX, dataUmumY7, data.agency!));
    }

    // II.A. PELANGGARAN KARANTINA
    const double quarantineY = 181;
    const double isyaratPasangX = 115;
    const double isyaratTidakPasangX = 115;
    const double isyaratPasangY = quarantineY;
    const double isyaratTidakPasangY = quarantineY + 9;
    
    if (data.quarantineSignal == 'Pasang') {
      form1Overlays.add(_buildCheckmark(isyaratPasangX, isyaratPasangY));
    } else if (data.quarantineSignal == 'Tidak Pasang') {
      form1Overlays.add(_buildCheckmark(isyaratTidakPasangX, isyaratTidakPasangY));
    }

    // 2. Aktivitas di atas Kapal
    const double aktivitasX = 320;
    const double aktivitasY1 = quarantineY;
    const double aktivitasY2 = quarantineY + 9;
    const double aktivitasY3 = quarantineY + 18;
    
    if (data.shipActivity != null) {
      if (data.shipActivity!.contains('bongkar muat')) {
        form1Overlays.add(_buildCheckmark(aktivitasX, aktivitasY1));
      } else if (data.shipActivity!.contains('Naik/turun') || data.shipActivity!.contains('naik turun')) {
        form1Overlays.add(_buildCheckmark(aktivitasX, aktivitasY2));
      } else if (data.shipActivity!.contains('Tidak ada')) {
        form1Overlays.add(_buildCheckmark(aktivitasX, aktivitasY3));
      }
    }

    // II.B. DOKUMEN KESEHATAN KAPAL
    const double docTableY = 233;
    const double docRowHeight = 19.0;
    const double colAda = 268;
    const double colSehat = 300;
    const double colTidakSehat = 332;
    const double colTidakAda = 375;
    
    // Row 1: MDH
    _addDocumentRow(form1Overlays, 0, docTableY, docRowHeight, 
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.mdhStatus, hasStatusColumn: true);
    
    // Row 2: SSCEC / SSCC
    _addDocumentRow(form1Overlays, 1, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.sscecStatus, hasStatusColumn: true);
    if (data.sscecPlace != null) {
      form1Overlays.add(_buildText(105, docTableY + docRowHeight * 1.3, data.sscecPlace!, fontSize: 6));
    }
    if (data.sscecDate != null) {
      form1Overlays.add(_buildText(105, docTableY + docRowHeight * 1.6, dateFormat.format(data.sscecDate!), fontSize: 6));
    }
    if (data.sscecExpiry != null) {
      form1Overlays.add(_buildText(105, docTableY + docRowHeight * 1.9, dateFormat.format(data.sscecExpiry!), fontSize: 6));
    }
    
    // Row 3: Crew List
    _addDocumentRow(form1Overlays, 2, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.crewListStatus, hasStatusColumn: false);
    
    // Row 4: Buku Kuning (ICV)
    _addDocumentRow(form1Overlays, 3, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.icvStatus, hasStatusColumn: true);
    
    // Row 5: P3K Kapal
    _addDocumentRow(form1Overlays, 4, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.p3kStatus, hasStatusColumn: true);
    if (data.p3kPlace != null) {
      form1Overlays.add(_buildText(105, docTableY + docRowHeight * 4.3, data.p3kPlace!, fontSize: 6));
    }
    if (data.p3kDate != null) {
      form1Overlays.add(_buildText(105, docTableY + docRowHeight * 4.6, dateFormat.format(data.p3kDate!), fontSize: 6));
    }
    if (data.p3kExpiry != null) {
      form1Overlays.add(_buildText(105, docTableY + docRowHeight * 4.9, dateFormat.format(data.p3kExpiry!), fontSize: 6));
    }
    
    // Row 6: Buku Kesehatan Kapal
    _addDocumentRow(form1Overlays, 5, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.healthBookStatus, hasStatusColumn: true);
    if (data.healthBookPlace != null) {
      form1Overlays.add(_buildText(105, docTableY + docRowHeight * 5.3, data.healthBookPlace!, fontSize: 6));
    }
    if (data.healthBookDate != null) {
      form1Overlays.add(_buildText(105, docTableY + docRowHeight * 5.6, dateFormat.format(data.healthBookDate!), fontSize: 6));
    }
    
    // Row 7: Voyage Memo
    _addDocumentRow(form1Overlays, 6, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.voyageMemoStatus, hasStatusColumn: false);
    
    // Row 8: Ship Particular
    _addDocumentRow(form1Overlays, 7, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.shipParticularStatus, hasStatusColumn: false);
    
    // Row 9: Manifest Cargo
    _addDocumentRow(form1Overlays, 8, docTableY, docRowHeight,
      colAda, colSehat, colTidakSehat, colTidakAda,
      data.manifestCargoStatus, hasStatusColumn: false);

    // II.C. FAKTOR RISIKO PHEIC
    const double risikoY = 430;
    const double risikoAdaX = 265;
    const double risikoTidakAdaX = 530;
    
    if (data.sanitationRisk == true) {
      form1Overlays.add(_buildCheckmark(risikoAdaX, risikoY));
    } else {
      form1Overlays.add(_buildCheckmark(risikoTidakAdaX, risikoY));
    }
    
    if (data.healthRisk == true) {
      form1Overlays.add(_buildCheckmark(risikoAdaX, risikoY + 11));
    } else {
      form1Overlays.add(_buildCheckmark(risikoTidakAdaX, risikoY + 11));
    }

    // III. KESIMPULAN
    const double kesimpulanY = 455;
    const double kesimpulanBebasX = 160;
    const double kesimpulanTidakBebasX = 260;
    
    if (data.isPHEICFree == true) {
      form1Overlays.add(_buildCheckmark(kesimpulanBebasX, kesimpulanY));
    } else {
      form1Overlays.add(_buildCheckmark(kesimpulanTidakBebasX, kesimpulanY));
    }

    // IV. REKOMENDASI
    const double rekA_Y = 477;
    const double rekA_X = 115;
    const double rekA_TanggalX = 415;
    const double rekA_JamX = 475;
    
    if (data.quarantineRecommendation != null) {
      if (data.quarantineRecommendation == 'Free Pratique') {
        form1Overlays.add(_buildCheckmark(rekA_X, rekA_Y));
      } else if (data.quarantineRecommendation == 'Free Pratique dengan Syarat') {
        form1Overlays.add(_buildCheckmark(rekA_X, rekA_Y + 10));
      } else if (data.quarantineRecommendation == 'No Free Pratique') {
        form1Overlays.add(_buildCheckmark(rekA_X, rekA_Y + 20));
      }
      
      if (data.quarantineRecommendationDate != null) {
        form1Overlays.add(_buildText(rekA_TanggalX, rekA_Y, dateFormat.format(data.quarantineRecommendationDate!), fontSize: 8));
        form1Overlays.add(_buildText(rekA_JamX, rekA_Y, timeFormat.format(data.quarantineRecommendationDate!), fontSize: 8));
      }
    }
    
    // B. Kapal dalam Negeri
    const double rekB_Y = 518;
    const double rekB_X = 115;
    const double rekB_NoX = 250;
    const double rekB_TanggalX = 350;
    const double rekB_JamX = 440;
    
    if (data.sibGiven == true) {
      form1Overlays.add(_buildCheckmark(rekB_X, rekB_Y));
      if (data.sibNumber != null) {
        form1Overlays.add(_buildText(rekB_NoX, rekB_Y, data.sibNumber!, fontSize: 8));
      }
      if (data.sibDate != null) {
        form1Overlays.add(_buildText(rekB_TanggalX, rekB_Y, dateFormat.format(data.sibDate!), fontSize: 8));
        form1Overlays.add(_buildText(rekB_JamX, rekB_Y, timeFormat.format(data.sibDate!), fontSize: 8));
      }
    } else {
      form1Overlays.add(_buildCheckmark(rekB_X, rekB_Y + 10));
    }
    
    form1Overlays.add(_buildText(450, rekB_Y + 10, 'Balikpapan,', fontSize: 8));

    // TANDA TANGAN - Form 1
    const double signatureY = 565;
    const double signatureWidth = 80;
    const double signatureHeight = 35;
    const double nameY = signatureY + 40;
    const double masterX = 320;
    const double petugas1X = 420;
    
    List<pw.Widget> form1Signatures = [];
    
    if (data.captainSignature != null) {
      form1Signatures.add(
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
    
    if (data.captainName != null && data.captainName!.isNotEmpty) {
      form1Signatures.add(
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

    if (data.officerSignature != null) {
      form1Signatures.add(
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

    if (data.officerName != null && data.officerName!.isNotEmpty) {
      form1Signatures.add(
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

    // Add Page 1 - Form 1
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(form1Image, fit: pw.BoxFit.fill),
              ),
              ...form1Overlays,
              ...form1Signatures,
            ],
          );
        },
      ),
    );

    // ============================================================
    // PAGE 2: FORM 2 - SANITASI
    // ============================================================
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
      null, // Quarter header
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

    List<pw.Widget> form2Checkmarks = [];

    for (int i = 0; i < rowKeys.length; i++) {
      final key = rowKeys[i];
      if (key == null) continue;

      final areaData = data.sanitationAreas[key];
      if (areaData == null) continue;

      final double rowY = rowStartY + (i * rowHeight);

      if (areaData.qualify) {
        form2Checkmarks.add(_buildCheckmark(col1X, rowY));
      }
      if (areaData.unqualify) {
        form2Checkmarks.add(_buildCheckmark(col2X, rowY));
      }
      if (areaData.visibleSigns) {
        form2Checkmarks.add(_buildCheckmark(col3X, rowY));
      }
      if (areaData.noSigns) {
        form2Checkmarks.add(_buildCheckmark(col4X, rowY));
      }
    }

    // Signatures for Form 2
    const double captainBoxX = 76;
    const double captainBoxY = 604;
    const double captainBoxWidth = 150;
    const double captainBoxHeight = 30;
    const double officerBoxX = 397;
    const double officerBoxY = 604;
    const double officerBoxWidth = 150;
    const double officerBoxHeight = 30;
    const double form2NameY = 640;
    const double form2NameHeight = 15;

    List<pw.Widget> form2Signatures = [];

    if (data.captainSignature != null) {
      form2Signatures.add(
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

    if (data.captainName != null && data.captainName!.isNotEmpty) {
      form2Signatures.add(
        pw.Positioned(
          left: captainBoxX,
          top: form2NameY,
          child: pw.Container(
            width: captainBoxWidth,
            height: form2NameHeight,
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

    if (data.officerSignature != null) {
      form2Signatures.add(
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

    if (data.officerName != null && data.officerName!.isNotEmpty) {
      form2Signatures.add(
        pw.Positioned(
          left: officerBoxX,
          top: form2NameY,
          child: pw.Container(
            width: officerBoxWidth,
            height: form2NameHeight,
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

    // Add Page 2 - Form 2
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.Image(form2Image, fit: pw.BoxFit.fill),
              ),
              ...form2Checkmarks,
              ...form2Signatures,
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
}
