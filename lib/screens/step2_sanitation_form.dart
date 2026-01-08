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

    return Scaffold(
      appBar: AppBar(title: const Text('Langkah 2: Sanitasi Kapal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ceklist Kebersihan', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Gap(16),
              
              FormBuilderCheckbox(
                name: 'kitchenClean',
                initialValue: provider.data.kitchenClean,
                title: const Text('Dapur (Galley) Bersih?'),
                subtitle: const Text('Tidak ada sisa makanan busuk, peralatan bersih.'),
              ),
              FormBuilderCheckbox(
                name: 'pantryClean',
                initialValue: provider.data.pantryClean,
                title: const Text('Pantry / Penylimpanan Makanan Bersih?'),
              ),
              FormBuilderCheckbox(
                name: 'foodStorageClean',
                initialValue: provider.data.foodStorageClean,
                title: const Text('Gudang Makanan Kering & Basah Aman?'),
                subtitle: const Text('Suhu sesuai, tidak ada tanda hama.'),
              ),
              const Divider(),
              FormBuilderCheckbox(
                name: 'wasteManagementGood',
                initialValue: provider.data.wasteManagementGood,
                title: const Text('Pengelolaan Limbah Baik?'),
                subtitle: const Text('Sampah dipisah, tertutup rapat.'),
              ),
              FormBuilderCheckbox(
                name: 'vectorControlGood',
                initialValue: provider.data.vectorControlGood,
                title: const Text('Bebas Vektor (Tikus/Kecoa)?'),
                subtitle: const Text('Tidak ditemukan jejak atau keberadaan vektor.'),
              ),

              const Gap(20),
              FormBuilderTextField(
                name: 'sanitationNote',
                initialValue: provider.data.sanitationNote,
                decoration: const InputDecoration(
                  labelText: 'Catatan Tambahan',
                  hintText: 'Misal: Ditemukan kebocoran pipa di dapur...',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),

              const Gap(40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final values = _formKey.currentState!.value;
                      provider.updateSanitationData(
                        kitchenClean: values['kitchenClean'],
                        pantryClean: values['pantryClean'],
                        foodStorageClean: values['foodStorageClean'],
                        wasteManagementGood: values['wasteManagementGood'],
                        vectorControlGood: values['vectorControlGood'],
                        note: values['sanitationNote'],
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const Step3HealthForm()));
                    }
                  },
                  child: const Text('Lanjut ke Kesehatan'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
