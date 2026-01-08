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

    return Scaffold(
      appBar: AppBar(title: const Text('Langkah 3: Kesehatan ABK/Penumpang')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Data Penumpang & Kru', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Gap(16),
              
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'crewCount',
                      initialValue: provider.data.crewCount.toString(),
                      decoration: const InputDecoration(labelText: 'Jumlah ABK'),
                      keyboardType: TextInputType.number,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.integer(),
                      ]),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'passengerCount',
                      initialValue: provider.data.passengerCount.toString(),
                      decoration: const InputDecoration(labelText: 'Jumlah Penumpang'),
                      keyboardType: TextInputType.number,
                       validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.integer(),
                      ]),
                    ),
                  ),
                ],
              ),
              const Gap(24),
              const Text('Status Kesehatan', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Gap(12),
              FormBuilderTextField(
                name: 'sickCount',
                initialValue: provider.data.sickCount.toString(),
                decoration: const InputDecoration(labelText: 'Jumlah Orang Sakit', prefixIcon: Icon(Icons.sick)),
                keyboardType: TextInputType.number,
                 validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.integer(),
                      ]),
              ),
              const Gap(12),
              FormBuilderCheckboxGroup<String>(
                name: 'symptoms',
                initialValue: provider.data.symptoms,
                decoration: const InputDecoration(labelText: 'Gejala yang Ditemukan'),
                options: const [
                  FormBuilderFieldOption(value: 'Demam', child: Text('Demam (>38°C)')),
                  FormBuilderFieldOption(value: 'Batuk', child: Text('Batuk')),
                  FormBuilderFieldOption(value: 'Sesak Napas', child: Text('Sesak Napas')),
                  FormBuilderFieldOption(value: 'Diare', child: Text('Diare')),
                  FormBuilderFieldOption(value: 'Ruam Kulit', child: Text('Ruam Kulit')),
                  FormBuilderFieldOption(value: 'Muntah', child: Text('Muntah')),
                ],
              ),

              const Gap(40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final values = _formKey.currentState!.value;
                      provider.updateHealthData(
                        crewCount: int.tryParse(values['crewCount']),
                        passengerCount: int.tryParse(values['passengerCount']),
                        sickCount: int.tryParse(values['sickCount']),
                        symptoms: List<String>.from(values['symptoms'] ?? []),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const Step4SignatureScreen()));
                    }
                  },
                  child: const Text('Lanjut ke Tanda Tangan'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
