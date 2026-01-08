import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../providers/inspection_provider.dart';
import '../utils/pdf_generator.dart';
import 'home_screen.dart'; // To go back home

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InspectionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Dokumen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: PdfPreview(
        build: (format) async {
          return await PdfGenerator.generatePdf(provider.data);
        },
        // We can disable dynamic layout to force A4
        pageFormats: const {'A4': PdfPageFormat.a4},
        canDebug: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }
}
