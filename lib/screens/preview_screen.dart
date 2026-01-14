import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../providers/inspection_provider.dart';
import '../utils/generator_combined.dart';
import 'home_screen.dart';

/// Preview Screen dengan caching untuk meringankan beban memory di HP low-end.
/// PDF gabungan (Form 1 + Form 2) di-generate sekali dan di-cache.
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  // Cache untuk PDF bytes - hanya generate sekali
  Uint8List? _cachedPdfBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    try {
      final provider = Provider.of<InspectionProvider>(context, listen: false);
      final pdfBytes = await CombinedPdfGenerator.generateCombinedPdf(provider.data);
      
      if (mounted) {
        setState(() {
          _cachedPdfBytes = pdfBytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal membuat PDF: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Dokumen'),
        actions: [
          // Tombol refresh untuk regenerate PDF
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh PDF',
            onPressed: () {
              setState(() {
                _isLoading = true;
                _cachedPdfBytes = null;
                _errorMessage = null;
              });
              _generatePdf();
            },
          ),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Membuat PDF...'),
            SizedBox(height: 8),
            Text(
              'Form 1 + Form 2',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _generatePdf();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Gunakan cached PDF bytes - tidak generate ulang
    return PdfPreview(
      build: (format) async => _cachedPdfBytes!,
      pageFormats: const {'A4': PdfPageFormat.a4},
      canDebug: false,
      canChangeOrientation: false,
      canChangePageFormat: false,
      pdfFileName: 'inspeksi_kapal.pdf',
    );
  }
}
