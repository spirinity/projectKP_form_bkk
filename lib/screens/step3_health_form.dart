import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../providers/inspection_provider.dart';
import 'step4_signature_screen.dart';

class Step3HealthForm extends StatefulWidget {
  const Step3HealthForm({super.key});

  @override
  State<Step3HealthForm> createState() => _Step3HealthFormState();
}

class _Step3HealthFormState extends State<Step3HealthForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InspectionProvider>(context, listen: false);
    final theme = Theme.of(context);

    // Get total counts from previous step
    final crewTotal = provider.data.crewCount ?? 0;
    final passengerTotal = provider.data.passengerCount ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Kesehatan ABK & Penumpang'),
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
                  _buildStepIndicator(1, 'Data Umum', true, false),
                  _buildStepLine(true),
                  _buildStepIndicator(2, 'Data Khusus', true, false),
                  _buildStepLine(true),
                  _buildStepIndicator(3, 'Sanitasi', true, false),
                  _buildStepLine(true),
                  _buildStepIndicator(4, 'Kesehatan', false, true),
                  _buildStepLine(false),
                  _buildStepIndicator(5, 'TTD', false, false),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- CARD 1: JUMLAH PERSONEL (READ ONLY) ---
                    Container(
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
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.groups,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const Gap(12),
                              const Text(
                                'Jumlah Personel',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDisplayItem(
                                  label: 'ABK',
                                  value: crewTotal.toString(),
                                  icon: Icons.person,
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: _buildDisplayItem(
                                  label: 'Penumpang',
                                  value: passengerTotal.toString(),
                                  icon: Icons.groups,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Gap(16),

                    // --- CARD 2: STATUS KESEHATAN (INPUTS) ---
                    Container(
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
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.medical_information,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              const Gap(12),
                              const Text(
                                'Status Kesehatan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Gap(24),

                          // ABK INPUTS
                          const Text(
                            'Kesehatan ABK',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Gap(12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStickerCounter(
                                  name: 'crewHealthyCount',
                                  label: 'Sehat',
                                  icon: Icons.sentiment_satisfied_alt,
                                  max: crewTotal,
                                  initialValue:
                                      provider.data.crewHealthyCount ??
                                      crewTotal,
                                  onChanged: (val) {
                                    _updateOppositeCount(
                                      newValue: val,
                                      oppositeField: 'crewSickCount',
                                      total: crewTotal,
                                    );
                                  },
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: _buildStickerCounter(
                                  name: 'crewSickCount',
                                  label: 'Sakit',
                                  icon: Icons.sick,
                                  max: crewTotal,
                                  initialValue:
                                      provider.data.crewSickCount ?? 0,
                                  onChanged: (val) {
                                    _updateOppositeCount(
                                      newValue: val,
                                      oppositeField: 'crewHealthyCount',
                                      total: crewTotal,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const Gap(24),

                          // PASSENGER INPUTS
                          const Text(
                            'Kesehatan Penumpang',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Gap(12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStickerCounter(
                                  name: 'passengerHealthyCount',
                                  label: 'Sehat',
                                  icon: Icons.sentiment_satisfied_alt,
                                  max: passengerTotal,
                                  initialValue:
                                      provider.data.passengerHealthyCount ??
                                      passengerTotal,
                                  onChanged: (val) {
                                    _updateOppositeCount(
                                      newValue: val,
                                      oppositeField: 'passengerSickCount',
                                      total: passengerTotal,
                                    );
                                  },
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: _buildStickerCounter(
                                  name: 'passengerSickCount',
                                  label: 'Sakit',
                                  icon: Icons.sick,
                                  max: passengerTotal,
                                  initialValue:
                                      provider.data.passengerSickCount ?? 0,
                                  onChanged: (val) {
                                    _updateOppositeCount(
                                      newValue: val,
                                      oppositeField: 'passengerHealthyCount',
                                      total: passengerTotal,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const Gap(24),
                          const Divider(),
                          const Gap(16),

                          // DOCUMENTS INPUTS
                          const Text(
                            'Dokumen Kesehatan / Health Document',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Gap(12),
                          // ICV / Vaccination
                          _buildDocumentRadio(
                            title: 'ICV / Vaccination',
                            name: 'icvStatus',
                            initialValue: provider.data.icvStatus ?? 'Lengkap',
                            options: ['Lengkap', 'Tidak Lengkap'],
                          ),
                          const Gap(8),
                          // ICV Text Input (Validation: Alphanumeric, Max 13)
                          FormBuilderTextField(
                            name: 'icvCertificateCount',
                            initialValue: provider.data.icvCertificateCount,
                            decoration: InputDecoration(
                              labelText: 'Nomor/Jumlah Sertifikat',
                              hintText: 'Max 13 karakter (Huruf/Angka)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              counterText:
                                  '', // Hide default character counter if preferred, or show it. Using maxLength usually shows it.
                            ),
                            maxLength: 13,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.maxLength(13),
                              // Custom validator for alphanumeric if strictly required, but usually alphanumeric includes symbols per user request "bisa huruf angka dan simbol" which is basically 'text'
                              // So just Max Length 13 is the main constraint.
                            ]),
                          ),
                          const Gap(12),
                          // Sertifikat PPPK
                          _buildDocumentRadio(
                            title: 'Sertifikat PPPK',
                            subtitle: 'First Aid Equipment Certificate',
                            name: 'p3kStatus',
                            initialValue: provider.data.p3kStatus ?? 'Tersedia',
                            options: ['Tersedia', 'Tidak Tersedia'],
                          ),
                        ],
                      ),
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
          label: const Text(
            'Lanjut ke Tanda Tangan',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  bool _isUpdating = false;

  void _updateOppositeCount({
    required int newValue,
    required String oppositeField,
    required int total,
  }) {
    if (_isUpdating) return;

    int oppositeValue = total - newValue;
    if (oppositeValue < 0) oppositeValue = 0;

    _isUpdating = true;
    try {
      _formKey.currentState?.fields[oppositeField]?.didChange(
        oppositeValue.toString(),
      );
    } finally {
      _isUpdating = false;
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final provider = Provider.of<InspectionProvider>(context, listen: false);

      provider.updateHealthDataPdf(
        crewHealthyCount: int.tryParse(values['crewHealthyCount'] ?? ''),
        crewSickCount: int.tryParse(values['crewSickCount'] ?? ''),
        passengerHealthyCount: int.tryParse(
          values['passengerHealthyCount'] ?? '',
        ),
        passengerSickCount: int.tryParse(values['passengerSickCount'] ?? ''),
        icvCertificateCount: values['icvCertificateCount'], // Now String
        icvStatus: values['icvStatus'],
        p3kStatus: values['p3kStatus'],
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Step4SignatureScreen()),
      );
    }
  }

  Widget _buildStepIndicator(
    int step,
    String label,
    bool isCompleted,
    bool isCurrent,
  ) {
    Color bgColor = (isCompleted || isCurrent)
        ? Colors.white
        : Colors.white.withOpacity(0.3);
    Color contentColor = Theme.of(context).primaryColor;
    Color labelColor = (isCompleted || isCurrent)
        ? Colors.white
        : Colors.white.withOpacity(0.6);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: contentColor, size: 16)
                  : Text(
                      '$step',
                      style: TextStyle(
                        color: contentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const Gap(4),
          SizedBox(
            height: 24,
            child: Text(
              label,
              style: TextStyle(color: labelColor, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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

  Widget _buildDisplayItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Neutral
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.grey[600]),
          const Gap(8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const Gap(8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Vertical layout matching user screenshot + Small buttons
  Widget _buildStickerCounter({
    required String name,
    required String label,
    required IconData icon,
    required int max,
    required int initialValue,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.grey[600]),
          const Gap(8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const Gap(12),
          // Counter Box
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100], // Darker grey for input box
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Subtract Button (Hidden/Ghost or small)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final formState = _formKey.currentState;
                      final field = formState?.fields[name];
                      if (field != null) {
                        final curr = int.tryParse(field.value ?? '0') ?? 0;
                        if (curr > 0) {
                          final newVal = curr - 1;
                          field.didChange(newVal.toString());
                          onChanged(newVal);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 30,
                      height: double.infinity,
                      child: Icon(
                        Icons.remove,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ),

                // Number Display
                Expanded(
                  child: FormBuilderTextField(
                    name: name,
                    initialValue: initialValue.toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.integer(),
                      FormBuilderValidators.max(max),
                      FormBuilderValidators.min(0),
                    ]),
                    onChanged: (val) {
                      if (!_isUpdating && val != null) {
                        final v = int.tryParse(val) ?? 0;
                        if (v >= 0 && v <= max) {
                          onChanged(v);
                        }
                      }
                    },
                  ),
                ),

                // Add Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final formState = _formKey.currentState;
                      final field = formState?.fields[name];
                      if (field != null) {
                        final curr = int.tryParse(field.value ?? '0') ?? 0;
                        if (curr < max) {
                          final newVal = curr + 1;
                          field.didChange(newVal.toString());
                          onChanged(newVal);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 30,
                      height: double.infinity,
                      child: Icon(Icons.add, size: 16, color: Colors.grey[500]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRadio({
    required String title,
    String? subtitle,
    required String name,
    required String initialValue,
    required List<String> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        FormBuilderRadioGroup<String>(
          name: name,
          initialValue: initialValue,
          options: options
              .map((opt) => FormBuilderFieldOption(value: opt))
              .toList(),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
