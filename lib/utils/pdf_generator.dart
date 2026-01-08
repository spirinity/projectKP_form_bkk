import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/inspection_model.dart';
// import 'package:flutter/services.dart' show rootBundle;

class PdfGenerator {
  static Future<Uint8List> generatePdf(InspectionModel data) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd MMM yyyy');

    // Load fonts if necessary (using standard helvetica for now)
    
    // --- FORM 1: SHIP DATA ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // TODO: UNCOMMENT THIS BLOCK TO USE YOUR OVERLAY IMAGE
              // pw.Positioned.fill(
              //   child: pw.Image(pw.MemoryImage(form1ImageBytes), fit: pw.BoxFit.fill),
              // ),
              
              // Placeholder for the "Overlay" visual if image is missing
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 2),
                ),
                child: pw.Center(child: pw.Text("FORM 1: PEMERIKSAAN KAPAL (Template Overlay)", style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 24))),
              ),

              // DATA OVERLAY (Adjust top/left coordinates to match your PDF form)
              pw.Positioned(
                top: 100,
                left: 150,
                child: pw.Text(data.shipName ?? "-", style: const pw.TextStyle(fontSize: 12)),
              ),
              pw.Positioned(
                top: 120,
                left: 150,
                child: pw.Text(data.flag ?? "-", style: const pw.TextStyle(fontSize: 12)),
              ),
               pw.Positioned(
                top: 140,
                left: 150,
                child: pw.Text("${data.grossTonnage ?? "-"} GT", style: const pw.TextStyle(fontSize: 12)),
              ),
               pw.Positioned(
                top: 160,
                left: 150,
                child: pw.Text(data.arrivalDate != null ? dateFormat.format(data.arrivalDate!) : "-", style: const pw.TextStyle(fontSize: 12)),
              ),

              // Captain Signature Area
              if (data.captainSignature != null)
                pw.Positioned(
                  bottom: 100,
                  left: 50,
                  child: pw.Image(pw.MemoryImage(data.captainSignature!), width: 100, height: 50),
                ),
            ],
          );
        },
      ),
    );

    // --- FORM 2 & 4: SANITATION & HEALTH ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
               pw.Header(level: 0, child: pw.Text("FORM 2 & 4: SANITASI & KESEHATAN")),
               pw.SizedBox(height: 20),
               
               pw.TableHelper.fromTextArray(
                 context: context,
                 data: <List<String>>[
                   ['Item', 'Status'],
                   ['Dapur', data.kitchenClean ? 'Bersih' : 'Kotor'],
                   ['Pantry', data.pantryClean ? 'Bersih' : 'Kotor'],
                   ['Gudang', data.foodStorageClean ? 'Aman' : 'Rawan'],
                   ['Vektor', data.vectorControlGood ? 'Bebas' : 'Ditemukan'],
                 ],
               ),
               
               pw.SizedBox(height: 20),
               pw.Text("Catatan: ${data.sanitationNote ?? '-'}"),
               
               pw.Divider(),
               
               pw.Text("Data Kesehatan:"),
               pw.Bullet(text: "Jumlah Kru: ${data.crewCount}"),
               pw.Bullet(text: "Jumlah Penumpang: ${data.passengerCount}"),
               pw.Bullet(text: "Sakit: ${data.sickCount}"),
               pw.Bullet(text: "Gejala: ${data.symptoms.join(', ')}"),

               pw.Spacer(),

               pw.Row(
                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                 children: [
                   pw.Column(
                     children: [
                       pw.Text("Nahkoda"),
                       pw.SizedBox(height: 50), // Space for signature if not using overlay
                        if (data.captainSignature != null)
                          pw.Image(pw.MemoryImage(data.captainSignature!), width: 100, height: 50),
                       pw.Text(data.captainName ?? "Nama Kapten"),
                     ]
                   ),
                   pw.Column(
                     children: [
                       pw.Text("Petugas Pemeriksa"),
                       pw.SizedBox(height: 50),
                        if (data.officerSignature != null)
                          pw.Image(pw.MemoryImage(data.officerSignature!), width: 100, height: 50),
                       pw.Text(data.officerName ?? "Nama Petugas"),
                     ]
                   ),
                 ]
               )
            ]
          );
        }
      )
    );

    return pdf.save();
  }
}
