import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import '../models/inspection_model.dart';
import 'generator_form_1.dart';
import 'generator_form_2.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'generator_form_3.dart';
import 'generator_form_4.dart';

/// Combined PDF Generator yang menggabungkan Form 1, 2, 3, dan 4 menjadi satu dokumen PDF.
class CombinedPdfGenerator {
  /// Generate PDF gabungan dengan Form 1, 2, 3, 4 secara berurutan
  static Future<Uint8List> generateCombinedPdf(InspectionModel data) async {
    // Load semua template images di Main Thread
    final Uint8List form1Bytes = (await rootBundle.load('lib/pdf/form_1.png')).buffer.asUint8List();
    final Uint8List form2Bytes = (await rootBundle.load('lib/pdf/form_2.png')).buffer.asUint8List();
    final Uint8List form3Bytes = (await rootBundle.load('lib/pdf/form_3.png')).buffer.asUint8List();
    final Uint8List form4Bytes = (await rootBundle.load('lib/pdf/form_4.png')).buffer.asUint8List();

    // Load font Calibri from Assets (Offline)
    final Uint8List fontBytes = (await rootBundle.load('lib/fonts/calibri.ttf')).buffer.asUint8List();

    // Generate PDF di background isolate
    return await compute(_generateCombinedPdfTask, {
      'data': data,
      'form1Bytes': form1Bytes,
      'form2Bytes': form2Bytes,
      'form3Bytes': form3Bytes,
      'form4Bytes': form4Bytes,
      'fontBytes': fontBytes,
    });
  }

  /// Task yang dijalankan di isolate
  static Future<Uint8List> _generateCombinedPdfTask(Map<String, dynamic> params) async {
    // Initialize locale data for this isolate
    await initializeDateFormatting('id_ID', null);

    final InspectionModel data = params['data'] as InspectionModel;
    final Uint8List form1Bytes = params['form1Bytes'] as Uint8List;
    final Uint8List form2Bytes = params['form2Bytes'] as Uint8List;
    final Uint8List form3Bytes = params['form3Bytes'] as Uint8List;
    final Uint8List form4Bytes = params['form4Bytes'] as Uint8List;
    final Uint8List fontBytes = params['fontBytes'] as Uint8List;

    final ttf = pw.Font.ttf(fontBytes.buffer.asByteData());
    final pdf = pw.Document();

    // Halaman 1: Form 1 - Data Kapal
    await PdfGeneratorForm1.addPageToDocument(pdf, data, form1Bytes, ttf);
    
    // Halaman 2: Form 2 - Sanitasi
    PdfGenerator.addPageToDocument(pdf, data, form2Bytes, ttf);

    // Halaman 3: Form 3 - Konfirmasi
    await PdfGeneratorForm3.addPageToDocument(pdf, data, form3Bytes, ttf);

    // Halaman 4: Form 4 - Kesehatan
    await PdfGeneratorForm4.addPageToDocument(pdf, data, form4Bytes, ttf);

    return pdf.save();
  }
}
