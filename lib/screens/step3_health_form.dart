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
                    // Data Counts
                    _buildFormCard(
                      title: 'Jumlah Personel',
                      icon: Icons.group,
                      iconColor: Colors.blue,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildCountField(
                                'crewCount',
                                'ABK',
                                Icons.person,
                                provider.data.crewCount,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: _buildCountField(
                                'passengerCount',
                                'Penumpang',
                                Icons.people,
                                provider.data.passengerCount,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Gap(16),

                    // Health Status
                    _buildFormCard(
                      title: 'Status Kesehatan',
                      icon: Icons.medical_information,
                      iconColor: Colors.red,
                      children: [
                        _buildCountField(
                          'sickCount',
                          'Jumlah Orang Sakit',
                          Icons.sick,
                          provider.data.sickCount,
                        ),
                        const Gap(16),
                        const Text(
                          'Gejala yang Ditemukan:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(8),
                        FormBuilderCheckboxGroup<String>(
                          name: 'symptoms',
                          initialValue: provider.data.symptoms,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          options: [
                            _buildSymptomOption(
                              'Demam',
                              Icons.thermostat,
                              '>38°C',
                            ),
                            _buildSymptomOption('Batuk', Icons.air, null),
                            _buildSymptomOption('Sesak Napas', Icons.air, null),
                            _buildSymptomOption(
                              'Diare',
                              Icons.water_drop,
                              null,
                            ),
                            _buildSymptomOption(
                              'Ruam Kulit',
                              Icons.healing,
                              null,
                            ),
                            _buildSymptomOption('Muntah', Icons.sick, null),
                          ],
                          wrapSpacing: 8,
                          wrapRunSpacing: 8,
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

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final provider = Provider.of<InspectionProvider>(context, listen: false);

      provider.updateHealthData(
        crewCount: int.tryParse(values['crewCount'] ?? ''),
        passengerCount: int.tryParse(values['passengerCount'] ?? ''),
        sickCount: int.tryParse(values['sickCount'] ?? ''),
        symptoms: List<String>.from(values['symptoms'] ?? []),
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

  Widget _buildCountField(
    String name,
    String label,
    IconData icon,
    int? initialValue,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.grey[600]),
          const Gap(8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const Gap(8),
          FormBuilderTextField(
            name: name,
            initialValue: initialValue?.toString() ?? '0',
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.integer(),
            ]),
          ),
        ],
      ),
    );
  }

  FormBuilderFieldOption<String> _buildSymptomOption(
    String value,
    IconData icon,
    String? subtitle,
  ) {
    return FormBuilderFieldOption(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const Gap(6),
            Text(
              subtitle != null ? '$value ($subtitle)' : value,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
