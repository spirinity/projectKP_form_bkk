import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../providers/inspection_provider.dart';
import 'step2_sanitation_form.dart';

class Step1BDataKhusus extends StatefulWidget {
  const Step1BDataKhusus({super.key});

  @override
  State<Step1BDataKhusus> createState() => _Step1BDataKhususState();
}

class _Step1BDataKhususState extends State<Step1BDataKhusus> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InspectionProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Data Khusus'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            Container(
              color: theme.primaryColor,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Row(
                children: [
                  _buildStepIndicator(1, 'Data Umum', true, true),
                  _buildStepLine(true),
                  _buildStepIndicator(2, 'Data Khusus', true, false),
                  _buildStepLine(false),
                  _buildStepIndicator(3, 'Sanitasi', false, false),
                  _buildStepLine(false),
                  _buildStepIndicator(4, 'TTD', false, false),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormCard(
                      title: 'A. Pelanggaran Karantina',
                      icon: Icons.warning_amber,
                      iconColor: Colors.orange,
                      children: [
                        _buildRadioGroup(
                          'quarantineSignal',
                          '1. Isyarat Karantina',
                          ['Pasang', 'Tidak Pasang'],
                          provider.data.quarantineSignal,
                        ),
                        const Gap(8),
                        _buildRadioGroup(
                          'shipActivity',
                          '2. Aktivitas di atas kapal',
                          [
                            'Ada bongkar muat sebelum Free Pratique',
                            'Naik/turun orang sebelum Free Pratique',
                            'Tidak ada aktivitas'
                          ],
                          provider.data.shipActivity,
                        ),
                      ],
                    ),
                    const Gap(16),
                    _buildFormCard(
                      title: 'B. Dokumen Kesehatan Kapal',
                      icon: Icons.description,
                      iconColor: Colors.blue,
                      children: [
                        _buildDocumentItem('MDH', 'mdhStatus', 'mdhNote', 
                          ['Sehat', 'Tidak Sehat', 'Tidak Ada'], provider.data.mdhStatus, provider.data.mdhNote),
                        const Divider(height: 24),
                        _buildDocumentItem('SSCEC / SSCC', 'sscecStatus', 'sscecNote', 
                          ['Berlaku', 'Tidak Berlaku', 'Tidak Ada'], provider.data.sscecStatus, provider.data.sscecNote),
                        const Divider(height: 24),
                        _buildDocumentItem('Crew List / Daftar ABK', 'crewListStatus', 'crewListNote', 
                          ['Ada', 'Tidak Ada'], provider.data.crewListStatus, provider.data.crewListNote),
                        const Divider(height: 24),
                        _buildDocumentItem('Buku Kuning (ICV)', 'icvStatus', 'icvNote', 
                          ['Sesuai', 'Tidak Sesuai', 'Tidak Ada'], provider.data.icvStatus, provider.data.icvNote),
                        const Divider(height: 24),
                        _buildDocumentItem('Voyage Memo', 'voyageMemoStatus', 'voyageMemoNote', 
                          ['Ada', 'Tidak Ada'], provider.data.voyageMemoStatus, provider.data.voyageMemoNote),
                        const Divider(height: 24),
                        _buildDocumentItem('Ship Particular', 'shipParticularStatus', 'shipParticularNote', 
                          ['Ada', 'Tidak Ada'], provider.data.shipParticularStatus, provider.data.shipParticularNote),
                        const Divider(height: 24),
                        _buildDocumentItem('Manifest Cargo', 'manifestCargoStatus', 'manifestCargoNote', 
                          ['Ada', 'Tidak Ada'], provider.data.manifestCargoStatus, provider.data.manifestCargoNote),
                      ],
                    ),
                    const Gap(16),
                    _buildFormCard(
                      title: 'C. Faktor Risiko PHEIC',
                      icon: Icons.health_and_safety,
                      iconColor: Colors.red,
                      children: [
                        _buildRiskItem('Faktor Risiko Sanitasi Kapal', 'sanitationRisk', 'sanitationRiskDetail',
                          provider.data.sanitationRisk, provider.data.sanitationRiskDetail),
                        const Gap(12),
                        _buildRiskItem('Faktor Risiko Orang dan P3K', 'healthRisk', 'healthRiskDetail',
                          provider.data.healthRisk, provider.data.healthRiskDetail),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        label: const Text('Lanjut ke Sanitasi'),
        icon: const Icon(Icons.arrow_forward),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final provider = Provider.of<InspectionProvider>(context, listen: false);

      provider.updateQuarantineViolations(
        signal: values['quarantineSignal'],
        activity: values['shipActivity'],
      );
      
      provider.updateDocumentMDH(status: values['mdhStatus'], note: values['mdhNote']);
      provider.updateDocumentSSCEC(status: values['sscecStatus'], note: values['sscecNote']);
      provider.updateDocumentCrewList(status: values['crewListStatus'], note: values['crewListNote']);
      provider.updateDocumentICV(status: values['icvStatus'], note: values['icvNote']);
      
      provider.updateOtherDocuments(
        voyageStatus: values['voyageMemoStatus'], voyageNote: values['voyageMemoNote'],
        shipPartStatus: values['shipParticularStatus'], shipPartNote: values['shipParticularNote'],
        manifestStatus: values['manifestCargoStatus'], manifestNote: values['manifestCargoNote'],
      );

      provider.updateRisks(
        sanitation: values['sanitationRisk'] ?? false, 
        sDetail: values['sanitationRiskDetail'],
        health: values['healthRisk'] ?? false, 
        hDetail: values['healthRiskDetail']
      );

      Navigator.push(context, MaterialPageRoute(builder: (_) => const Step2SanitationForm()));
    }
  }

  Widget _buildStepIndicator(int step, String label, bool isCompleted, bool isPast) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.white : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isPast 
                ? Icon(Icons.check, color: Theme.of(context).primaryColor, size: 16)
                : Text('$step', style: TextStyle(color: isCompleted ? Theme.of(context).primaryColor : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          const Gap(4),
          Text(label, style: TextStyle(color: isCompleted ? Colors.white : Colors.white.withOpacity(0.6), fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return Container(width: 20, height: 2, color: isCompleted ? Colors.white : Colors.white.withOpacity(0.3));
  }

  Widget _buildFormCard({required String title, required IconData icon, Color? iconColor, required List<Widget> children}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor, size: 20)),
          const Gap(12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
        ]),
        const Gap(16),
        ...children,
      ]),
    );
  }

  Widget _buildCustomChipField(String name, List<String> options, String? initialValue) {
    return FormBuilderField<String>(
      name: name,
      initialValue: initialValue,
      builder: (FormFieldState<String> field) {
        return InputDecorator(
          decoration: InputDecoration(border: InputBorder.none, errorText: field.errorText, contentPadding: EdgeInsets.zero),
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: options.map((option) {
              final selected = field.value == option;
              return ChoiceChip(
                label: Text(option, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 12)),
                selected: selected,
                onSelected: (val) { if (val) field.didChange(option); },
                selectedColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                showCheckmark: false,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildRadioGroup(String name, String label, List<String> options, String? initialValue) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      const Gap(8),
      _buildCustomChipField(name, options, initialValue),
    ]);
  }

  Widget _buildDocumentItem(String title, String statusName, String noteName, List<String> options, String? status, String? note) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const Gap(8),
      _buildCustomChipField(statusName, options, status),
      const Gap(8),
      FormBuilderTextField(
        name: noteName, initialValue: note,
        decoration: InputDecoration(hintText: 'Keterangan (bila diperlukan)', hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), isDense: true),
        style: const TextStyle(fontSize: 13),
      ),
    ]);
  }

  Widget _buildRiskItem(String title, String checkName, String detailName, bool? checked, String? detail) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FormBuilderCheckbox(name: checkName, initialValue: checked ?? false, title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)), decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero)),
        FormBuilderTextField(name: detailName, initialValue: detail, decoration: InputDecoration(hintText: 'Detail risiko (jika ada)', hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), isDense: true), style: const TextStyle(fontSize: 13)),
      ]),
    );
  }
}
