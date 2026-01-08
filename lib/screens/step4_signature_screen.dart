import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import '../providers/inspection_provider.dart';
import 'preview_screen.dart';

class Step4SignatureScreen extends StatefulWidget {
  const Step4SignatureScreen({super.key});

  @override
  State<Step4SignatureScreen> createState() => _Step4SignatureScreenState();
}

class _Step4SignatureScreenState extends State<Step4SignatureScreen> {
  final SignatureController _captainController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  final SignatureController _officerController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
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
    final provider = Provider.of<InspectionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Langkah 4: Tanda Tangan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text(
              'Tanda Tangan Nahkoda',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Signature(
                controller: _captainController,
                height: 200,
                backgroundColor: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _captainController.clear(),
                  child: const Text('Hapus / Ulangi'),
                ),
              ],
            ),
            
            const Gap(24),
            
            const Text(
              'Petugas Pemeriksa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Gap(8),
            TextField(
              controller: _officerNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Petugas',
                prefixIcon: Icon(Icons.person_pin),
              ),
            ),
            const Gap(12),
            const Text(
              'Tanda Tangan Petugas',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const Gap(8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Signature(
                controller: _officerController,
                height: 200,
                backgroundColor: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _officerController.clear(),
                  child: const Text('Hapus / Ulangi'),
                ),
              ],
            ),

            const Gap(40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () async {
                  if (_captainController.isEmpty || _officerController.isEmpty || _officerNameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Harap lengkapi Nama Petugas dan kedua Tanda Tangan.')),
                    );
                    return;
                  }

                  // Export signatures to bytes
                  final captainBytes = await _captainController.toPngBytes();
                  final officerBytes = await _officerController.toPngBytes();

                  if (captainBytes != null && officerBytes != null) {
                    provider.setCaptainSignature(captainBytes);
                    provider.setOfficerSignature(officerBytes);
                    provider.setOfficerName(_officerNameController.text);
                    
                    if (context.mounted) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PreviewScreen()));
                    }
                  }
                },
                child: const Text('Selesai & Preview PDF'),
              ),
            ),
            const Gap(30),
          ],
        ),
      ),
    );
  }
}
