import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/inspection_model.dart'; // Pastikan import ini sesuai dengan project Anda

class PdfGenerator {
  static Future<Uint8List> generatePdf(InspectionModel data) async {
    final pdf = pw.Document();

    // 1. Load Assets
    final imageLogo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo_kemenkes.png')).buffer.asUint8List(),
    );

    // 2. Constants & Styles
    const double fontSizeHeader = 8.0; 
    const double fontSizeBody = 8.0;
    const double fontSizeSmall = 7.0;
    final PdfColor colorTeal = PdfColor.fromInt(0xFF009688);
    final PdfColor colorGrey = PdfColor.fromInt(0xFF424242);

    // --- HELPER: Header Cell ---
    // Fungsi ini membuat sel header dengan border dan alignment yang pas
    pw.Widget _headerCell(String text, {double? height, bool bottomBorder = false, bool rightBorder = false}) {
      return pw.Container(
        height: height,
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: bottomBorder ? const pw.BorderSide(width: 0.5) : pw.BorderSide.none,
            right: rightBorder ? const pw.BorderSide(width: 0.5) : pw.BorderSide.none,
          ),
        ),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: fontSizeHeader),
        ),
      );
    }

    // --- HELPER: Data Row ---
    pw.TableRow _buildTableRow(
      String no,
      String title,
      String subtitle,
      SanitationAreaData? areaData, {
      bool isParent = false,
      bool isChild = false,
    }) {
      final String q = (areaData?.qualify ?? false) ? 'V' : '';
      final String uq = (areaData?.unqualify ?? false) ? 'V' : '';
      final String vs = (areaData?.visibleSigns ?? false) ? 'V' : '';
      final String ns = (areaData?.noSigns ?? false) ? 'V' : '';

      pw.Widget locationWidget;
      if (isChild) {
        locationWidget = pw.Padding(
          padding: const pw.EdgeInsets.only(left: 14),
          child: pw.RichText(
            text: pw.TextSpan(style: const pw.TextStyle(fontSize: fontSizeBody), children: [
              const pw.TextSpan(text: '- '),
              pw.TextSpan(text: title),
              pw.TextSpan(text: ' $subtitle', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ]),
          ),
        );
      } else {
        locationWidget = pw.Padding(
          padding: const pw.EdgeInsets.only(left: 4),
          child: pw.RichText(
            text: pw.TextSpan(style: const pw.TextStyle(fontSize: fontSizeBody), children: [
              pw.TextSpan(text: title),
              pw.TextSpan(text: ' $subtitle', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ]),
          ),
        );
      }

      return pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text(no, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: fontSizeBody))),
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: locationWidget),
          pw.Container(alignment: pw.Alignment.center, padding: const pw.EdgeInsets.symmetric(vertical: 4), child: isParent ? null : pw.Text(q, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: fontSizeBody))),
          pw.Container(alignment: pw.Alignment.center, padding: const pw.EdgeInsets.symmetric(vertical: 4), child: isParent ? null : pw.Text(uq, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: fontSizeBody))),
          pw.Container(alignment: pw.Alignment.center, padding: const pw.EdgeInsets.symmetric(vertical: 4), child: isParent ? null : pw.Text(vs, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: fontSizeBody))),
          pw.Container(alignment: pw.Alignment.center, padding: const pw.EdgeInsets.symmetric(vertical: 4), child: isParent ? null : pw.Text(ns, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: fontSizeBody))),
        ],
      );
    }

    // --- MAIN PDF GENERATION ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. HEADER KOP SURAT
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(width: 85, height: 60, child: pw.Image(imageLogo, fit: pw.BoxFit.contain)),
                  pw.Spacer(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Kementerian Kesehatan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: colorTeal)),
                      pw.Text('Direktorat Jenderal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: colorGrey)),
                      pw.Text('Penanggulangan Penyakit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: colorGrey)),
                      pw.SizedBox(height: 4),
                      pw.Text('Balai Kekarantinaan Kesehatan Kelas I Balikpapan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: colorGrey)),
                      pw.Text('📍 Jalan Pelita RT 11, Sepinggang Raya', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('     Balikpapan 76115', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('☎ (0542) 7570108', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('🌐 https://www.bkkbalikpapan.id', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),

              // 2. JUDUL
              pw.Center(
                child: pw.Text(
                  'PEMERIKSAAN SANITASI KAPAL DALAM KARANTINA',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
              ),

              pw.SizedBox(height: 15),

              // 3. TABEL UTAMA
              pw.Table(
                border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
                // PENGATURAN LEBAR KOLOM (Sesuai Margin 4:3 Visual)
                columnWidths: {
                  0: const pw.FixedColumnWidth(20),  // No (Sangat Kecil)
                  1: const pw.FlexColumnWidth(4),    // Lokasi (Sangat Lebar - Dominan)
                  2: const pw.FlexColumnWidth(1.2),  // Qualify
                  3: const pw.FlexColumnWidth(1.2),  // Unqualify
                  4: const pw.FlexColumnWidth(1.2),  // Visible
                  5: const pw.FlexColumnWidth(1.4),  // No Sign (Agak lebar dikit karena teksnya panjang)
                },
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  // --- HEADER TABLE ---
                  pw.TableRow(
                    children: [
                      _headerCell('No', height: 45), // Height disesuaikan agar muat
                      _headerCell('Lokasi Yang Diperiksa\n(Inspected Areas)', height: 45),
                      
                      // Merged Header: Kondisi Sanitasi
                      pw.Column(
                        children: [
                          _headerCell('Kondisi Sanitasi', height: 22, bottomBorder: true),
                          pw.Row(
                            children: [
                              pw.Expanded(child: _headerCell('Memenuhi Syarat\n(Qualify)', rightBorder: true, height: 35)),
                              pw.Expanded(child: _headerCell('Tidak Memenuhi Syarat\n(Unqualify)', height: 35)),
                            ],
                          )
                        ],
                      ),
                      
                      // Merged Header: Vektor
                      pw.Column(
                        children: [
                          _headerCell('Vektor', height: 22, bottomBorder: true),
                          pw.Row(
                            children: [
                              pw.Expanded(child: _headerCell('Tampak Tanda-\ntanda (Visible Signs)', rightBorder: true, height: 35)),
                              // Perhatikan teks panjang di bawah ini sesuai gambar
                              pw.Expanded(child: _headerCell('Tidak Tampak\nTanda-tanda (No\nEvidence Of Any\nSign)', height: 35)),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),

                  // --- DATA ROWS ---
                  _buildTableRow('1', 'Dapur', '(Galley)', data.sanitationAreas[SanitationAreaKeys.galley]),
                  _buildTableRow('2', 'Ruang Rakit Makanan', '(Pantry)', data.sanitationAreas[SanitationAreaKeys.pantry]),
                  _buildTableRow('3', 'Gudang', '(Store)', data.sanitationAreas[SanitationAreaKeys.store]),
                  _buildTableRow('4', 'Palka', '(Cargo)', data.sanitationAreas[SanitationAreaKeys.cargo]),
                  
                  // GROUP 5: QUARTER
                  _buildTableRow('5', 'Ruang Tidur', '(Quarter)', null, isParent: true),
                  _buildTableRow('', 'ABK', '(Crew)', data.sanitationAreas[SanitationAreaKeys.quarterCrew], isChild: true),
                  _buildTableRow('', 'Perwira', '(Officer)', data.sanitationAreas[SanitationAreaKeys.quarterCrew], isChild: true),
                  _buildTableRow('', 'Penumpang', '(Passenger)', data.sanitationAreas[SanitationAreaKeys.quarterCrew], isChild: true),
                  _buildTableRow('', 'Geladak', '(Deck)', data.sanitationAreas[SanitationAreaKeys.quarterCrew], isChild: true),

                  _buildTableRow('6', 'Air Minum', '(Potable Water)', data.sanitationAreas[SanitationAreaKeys.potableWater]),
                  _buildTableRow('7', 'Limbah Cair', '(Sewage)', data.sanitationAreas[SanitationAreaKeys.sewage]),
                  _buildTableRow('8', 'Air Balast', '(Water Balast)', data.sanitationAreas[SanitationAreaKeys.waterBallast]),
                  _buildTableRow('9', 'Limbah Medis/ Padat', '(Medic/Solid Waste)', data.sanitationAreas[SanitationAreaKeys.medicalWaste]),
                  _buildTableRow('10', 'Air Tergenang/ Permukaan', '(Standing Water)', data.sanitationAreas[SanitationAreaKeys.standingWater]),
                  _buildTableRow('11', 'Ruang Mesin', '(Engine Room)', data.sanitationAreas[SanitationAreaKeys.engineRoom]),
                  _buildTableRow('12', 'Fasilitas Medik', '(Medical Facilities)', data.sanitationAreas[SanitationAreaKeys.medicalFacilities]),
                  _buildTableRow('13', 'Area Lainnya', '(Other Area Spesified)', data.sanitationAreas[SanitationAreaKeys.otherArea]),
                ],
              ),
              
              pw.SizedBox(height: 10),

              // 4. KETERANGAN / REMARKS
              pw.Text('Keterangan / Remark:', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: fontSizeSmall, fontWeight: pw.FontWeight.bold)),
              pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('*) ', style: const pw.TextStyle(fontSize: fontSizeSmall)),
                pw.Expanded(child: pw.Text('Beri tanda (V) pada kolom sesuai dengan kondisi\nGive a sign (V) in the columns in accordance with the condition above', style: const pw.TextStyle(fontSize: fontSizeSmall))),
              ]),

              pw.Spacer(),

              // 5. TANDA TANGAN (SIGNATURES)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Mengetahui (Knowledge by)', style: const pw.TextStyle(fontSize: fontSizeBody)),
                      pw.Text('Nahkoda/Perwira Jaga', style: const pw.TextStyle(fontSize: fontSizeBody)),
                      pw.Text('Master / Officer on charge', style: pw.TextStyle(fontSize: fontSizeBody, fontStyle: pw.FontStyle.italic)),
                      pw.SizedBox(height: 50),
                      // Garis Putus-putus menggunakan Divider standard
                      pw.SizedBox(width: 150, child: pw.Divider(borderStyle: pw.BorderStyle.dotted, color: PdfColors.black, thickness: 1)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Pemeriksa/Inspector', style: const pw.TextStyle(fontSize: fontSizeBody)),
                      pw.SizedBox(height: 74), // Spacer agar garis sejajar dengan kiri
                      pw.SizedBox(width: 150, child: pw.Divider(borderStyle: pw.BorderStyle.dotted, color: PdfColors.black, thickness: 1)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // 6. FOOTER DISCLAIMER
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5, color: PdfColors.black),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Kementerian Kesehatan tidak menerima suap dan/atau gratifikasi dalam bentuk apapun. Jika terdapat potensi suap atau gratifikasi',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                    pw.RichText(
                      textAlign: pw.TextAlign.center,
                      text: pw.TextSpan(
                        style: const pw.TextStyle(fontSize: 7),
                        children: [
                          const pw.TextSpan(text: 'silahkan laporkan melalui HALO KEMENKES 1500567 dan '),
                          pw.TextSpan(text: 'https://wbs.kemkes.go.id', style: const pw.TextStyle(color: PdfColors.blue)),
                          const pw.TextSpan(text: '. Untuk verifikasi keaslian tanda tangan'),
                        ],
                      ),
                    ),
                    pw.RichText(
                      textAlign: pw.TextAlign.center,
                      text: pw.TextSpan(
                        style: const pw.TextStyle(fontSize: 7),
                        children: [
                          const pw.TextSpan(text: 'elektronik, silahkan unggah dokumen pada laman '),
                          pw.TextSpan(text: 'https://tte.komdigi.go.id/verifyPDF', style: const pw.TextStyle(color: PdfColors.blue)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}