import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../providers/inspection_provider.dart';
import 'step3_health_form.dart';

class Step2SanitationForm extends StatefulWidget {
  const Step2SanitationForm({super.key});

  @override
  State<Step2SanitationForm> createState() => _Step2SanitationFormState();
}

class _Step2SanitationFormState extends State<Step2SanitationForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InspectionProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Pemeriksaan Sanitasi'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            // Progress Indicator
            Container(
              color: theme.primaryColor,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Row(
                children: [
                  _buildStepIndicator(1, 'Data Umum', true),
                  _buildStepLine(true),
                  _buildStepIndicator(2, 'Data Khusus', true),
                  _buildStepLine(true),
                  _buildStepIndicator(3, 'Sanitasi', false),
                  _buildStepLine(false),
                  _buildStepIndicator(4, 'TTD', false),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checklist Card
                    _buildFormCard(
                      title: 'Checklist Kebersihan',
                      icon: Icons.checklist,
                      iconColor: Colors.teal,
                      children: [
                        _buildSanitationItem(
                          'kitchenClean',
                          'Dapur (Galley)',
                          'Tidak ada sisa makanan busuk, peralatan bersih',
                          Icons.kitchen,
                          provider.data.kitchenClean,
                        ),
                        _buildSanitationItem(
                          'pantryClean',
                          'Pantry / Penyimpanan Makanan',
                          'Area penyimpanan tertata dan bersih',
                          Icons.inventory_2,
                          provider.data.pantryClean,
                        ),
                        _buildSanitationItem(
                          'foodStorageClean',
                          'Gudang Makanan',
                          'Suhu sesuai, tidak ada tanda hama',
                          Icons.warehouse,
                          provider.data.foodStorageClean,
                        ),
                      ],
                    ),
                    
                    const Gap(16),
                    
                    _buildFormCard(
                      title: 'Pengelolaan & Vektor',
                      icon: Icons.pest_control,
                      iconColor: Colors.brown,
                      children: [
                        _buildSanitationItem(
                          'wasteManagementGood',
                          'Pengelolaan Limbah',
                          'Sampah dipisah dan tertutup rapat',
                          Icons.delete,
                          provider.data.wasteManagementGood,
                        ),
                        _buildSanitationItem(
                          'vectorControlGood',
                          'Bebas Vektor (Tikus/Kecoa)',
                          'Tidak ditemukan jejak atau keberadaan vektor',
                          Icons.bug_report,
                          provider.data.vectorControlGood,
                        ),
                      ],
                    ),
                    
                    const Gap(16),
                    
                    _buildFormCard(
                      title: 'Catatan Tambahan',
                      icon: Icons.note_add,
                      iconColor: Colors.indigo,
                      children: [
                        FormBuilderTextField(
                          name: 'sanitationNote',
                          initialValue: provider.data.sanitationNote,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Misal: Ditemukan kebocoran pipa di dapur, perlu perbaikan...',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
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
      ),
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingActionButton.extended(
          onPressed: _submitForm,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Lanjut ke Kesehatan', style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final provider = Provider.of<InspectionProvider>(context, listen: false);
      
      provider.updateSanitationData(
        kitchenClean: values['kitchenClean'] ?? false,
        pantryClean: values['pantryClean'] ?? false,
        foodStorageClean: values['foodStorageClean'] ?? false,
        wasteManagementGood: values['wasteManagementGood'] ?? false,
        vectorControlGood: values['vectorControlGood'] ?? false,
        note: values['sanitationNote'],
      );
      
      Navigator.push(context, MaterialPageRoute(builder: (_) => const Step3HealthForm()));
    }
  }

  Widget _buildStepIndicator(int step, String label, bool isPast) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isPast ? Colors.white : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isPast 
                ? Icon(Icons.check, color: Theme.of(context).primaryColor, size: 16)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
            ),
          ),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(isPast ? 1 : 0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return Container(
      width: 20,
      height: 2,
      color: isCompleted ? Colors.white : Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildFormCard({required String title, required IconData icon, Color? iconColor, required List<Widget> children}) {
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
                  color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor, size: 20),
              ),
              const Gap(12),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const Gap(16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSanitationItem(String name, String title, String subtitle, IconData icon, bool initialValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          FormBuilderSwitch(
            name: name,
            initialValue: initialValue,
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
            title: const SizedBox.shrink(),
            activeColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
