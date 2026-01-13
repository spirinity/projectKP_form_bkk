import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../providers/inspection_provider.dart';
import 'preview_screen.dart';
import '../services/sheet_service.dart';
import '../widgets/custom_progress_stepper.dart';

class Step4SignatureScreen extends StatefulWidget {
  const Step4SignatureScreen({super.key});

  @override
  State<Step4SignatureScreen> createState() => _Step4SignatureScreenState();
}

class _Step4SignatureScreenState extends State<Step4SignatureScreen> {
  final SignatureController _captainController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final SignatureController _officerController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final TextEditingController _officerNameController = TextEditingController();

  @override
  void dispose() {
    _captainController.dispose();
    _officerController.dispose();
    _officerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tanda Tangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Progress Indicator
          // Progress Indicator
          const CustomProgressStepper(
            currentStep: 4,
            totalSteps: 4,
            stepTitle: 'Selesai & Preview PDF',
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Captain Signature
                  _buildSignatureCard(
                    title: 'Tanda Tangan Nahkoda',
                    icon: Icons.person,
                    iconColor: Colors.blue,
                    controller: _captainController,
                  ),

                  const Gap(16),

                  // Officer Signature
                  _buildFormCard(
                    title: 'Petugas Pemeriksa',
                    icon: Icons.badge,
                    iconColor: Colors.teal,
                    children: [
                      TextField(
                        controller: _officerNameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Petugas',
                          prefixIcon: const Icon(Icons.person_pin, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const Gap(16),
                      const Text(
                        'Tanda Tangan Petugas',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const Gap(8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Signature(
                            controller: _officerController,
                            height: 150,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const Gap(8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _officerController.clear(),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text(
                            'Hapus',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingActionButton.extended(
          onPressed: _submitForm,
          icon: const Icon(Icons.check_circle),
          label: const Text(
            'Selesai & Preview PDF',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _submitForm() async {
    if (_captainController.isEmpty ||
        _officerController.isEmpty ||
        _officerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Harap lengkapi Nama Petugas dan kedua Tanda Tangan.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = Provider.of<InspectionProvider>(context, listen: false);

    // Export signatures to bytes
    final captainBytes = await _captainController.toPngBytes();
    final officerBytes = await _officerController.toPngBytes();

    if (captainBytes != null && officerBytes != null) {
      provider.setCaptainSignature(captainBytes);
      provider.setOfficerSignature(officerBytes);
      provider.setOfficerName(_officerNameController.text);

      if (context.mounted) {
        // 1. Show Loading Dialog
        showDialog(
          context: context, 
          barrierDismissible: false,
          builder: (ctx) => const Center(child: CircularProgressIndicator())
        );

        // 2. Submit to Google Sheets
        bool isSuccess = await SheetService.submitInspection(provider.data);
        
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          
          if (isSuccess) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data berhasil disimpan ke Google Sheets!'), backgroundColor: Colors.green),
            );
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal menyimpan ke Google Sheets (Cek Koneksi/URL)'), backgroundColor: Colors.orange),
            );
          }

          // 3. Navigate to Preview
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PreviewScreen()),
          );
        }
      }
    }
  }



  Widget _buildSignatureCard({
    required String title,
    required IconData icon,
    Color? iconColor,
    required SignatureController controller,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).primaryColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const Gap(12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Signature(
                controller: controller,
                height: 150,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const Gap(8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => controller.clear(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Hapus', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    Color? iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).primaryColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const Gap(12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Gap(16),
          ...children,
        ],
      ),
    );
  }
}
