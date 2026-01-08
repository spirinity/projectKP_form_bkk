import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../providers/inspection_provider.dart';
import 'step2_sanitation_form.dart';

class Step1ShipForm extends StatefulWidget {
  const Step1ShipForm({super.key});

  @override
  State<Step1ShipForm> createState() => _Step1ShipFormState();
}

class _Step1ShipFormState extends State<Step1ShipForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InspectionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Langkah 1: Data Kapal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Informasi Dasar Kapal', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Gap(16),
              FormBuilderTextField(
                name: 'shipName',
                initialValue: provider.data.shipName,
                decoration: const InputDecoration(labelText: 'Nama Kapal', prefixIcon: Icon(Icons.directions_boat)),
                validator: FormBuilderValidators.required(),
              ),
              const Gap(12),
              FormBuilderTextField(
                name: 'flag',
                initialValue: provider.data.flag,
                decoration: const InputDecoration(labelText: 'Bendera Kebangsaan', prefixIcon: Icon(Icons.flag)),
                validator: FormBuilderValidators.required(),
              ),
              const Gap(12),
              FormBuilderTextField(
                name: 'grossTonnage',
                initialValue: provider.data.grossTonnage,
                decoration: const InputDecoration(labelText: 'Bobot (Gross Tonnage)', prefixIcon: Icon(Icons.line_weight)),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.required(),
              ),
              const Gap(12),
              FormBuilderDateTimePicker(
                name: 'arrivalDate',
                initialValue: provider.data.arrivalDate,
                inputType: InputType.date,
                decoration: const InputDecoration(labelText: 'Tanggal Kedatangan', prefixIcon: Icon(Icons.calendar_today)),
                validator: FormBuilderValidators.required(),
              ),
              const Gap(20),
              
              const Text('Detail Perjalanan', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Gap(16),
              FormBuilderTextField(
                name: 'captainName',
                initialValue: provider.data.captainName,
                decoration: const InputDecoration(labelText: 'Nama Nahkoda', prefixIcon: Icon(Icons.person)),
                validator: FormBuilderValidators.required(),
              ),
               const Gap(12),
              FormBuilderTextField(
                name: 'lastPort',
                initialValue: provider.data.lastPort,
                decoration: const InputDecoration(labelText: 'Pelabuhan Asal', prefixIcon: Icon(Icons.arrow_back)),
                validator: FormBuilderValidators.required(),
              ),
               const Gap(12),
              FormBuilderTextField(
                name: 'nextPort',
                initialValue: provider.data.nextPort,
                decoration: const InputDecoration(labelText: 'Pelabuhan Tujuan', prefixIcon: Icon(Icons.arrow_forward)),
                validator: FormBuilderValidators.required(),
              ),

              const Gap(40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final values = _formKey.currentState!.value;
                      provider.updateShipData(
                        shipName: values['shipName'],
                        flag: values['flag'],
                        grossTonnage: values['grossTonnage'],
                        arrivalDate: values['arrivalDate'],
                        captainName: values['captainName'],
                        lastPort: values['lastPort'],
                        nextPort: values['nextPort'],
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const Step2SanitationForm()));
                    }
                  },
                  child: const Text('Lanjut ke Sanitasi'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
