import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../providers/inspection_provider.dart';
import '../utils/generator_form_1.dart';
import '../utils/generator_form_2.dart';
import 'home_screen.dart'; // To go back home

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Form 1 - Data Kapal'),
            Tab(text: 'Form 2 - Sanitasi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Form 1 Preview
          PdfPreview(
            build: (format) async {
              return await PdfGeneratorForm1.generatePdf(provider.data);
            },
            pageFormats: const {'A4': PdfPageFormat.a4},
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
          ),
          // Form 2 Preview
          PdfPreview(
            build: (format) async {
              return await PdfGenerator.generatePdf(provider.data);
            },
            pageFormats: const {'A4': PdfPageFormat.a4},
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
          ),
        ],
      ),
    );
  }
}
