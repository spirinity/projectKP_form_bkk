import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../providers/inspection_provider.dart';
import 'step1b_data_khusus.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Data Umum Kapal'),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStepIndicator(1, 'Data Umum', true),
                      _buildStepLine(false),
                      _buildStepIndicator(2, 'Data Khusus', false),
                      _buildStepLine(false),
                      _buildStepIndicator(3, 'Sanitasi', false),
                      _buildStepLine(false),
                      _buildStepIndicator(4, 'TTD', false),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Card
                    _buildFormCard(
                      title: 'Identitas Kapal',
                      icon: Icons.directions_boat,
                      children: [
                        _buildTextField('shipName', 'Nama Kapal', provider.data.shipName, required: true, icon: Icons.badge),
                        _buildTextField('flag', 'Bendera Kebangsaan', provider.data.flag, icon: Icons.flag),
                        _buildTextField('grossTonnage', 'Besar Kapal (GT)', provider.data.grossTonnage, icon: Icons.scale, keyboardType: TextInputType.number),
                        _buildTextField('imoNumber', 'No. IMO', provider.data.imoNumber, icon: Icons.numbers),
                      ],
                    ),
                    
                    const Gap(16),
                    
                    _buildFormCard(
                      title: 'Perjalanan',
                      icon: Icons.route,
                      children: [
                        _buildTextField('lastPort', 'Datang Dari', provider.data.lastPort, icon: Icons.flight_land),
                        _buildDateField('arrivalDate', 'Tanggal Kedatangan', provider.data.arrivalDate),
                        _buildTextField('nextPort', 'Tujuan', provider.data.nextPort, icon: Icons.flight_takeoff),
                        _buildDateField('departureDate', 'Tanggal Tujuan (Estimasi)', provider.data.departureDate),
                        _buildTextField('dockLocation', 'Lokasi Sandar', provider.data.dockLocation, icon: Icons.location_on),
                      ],
                    ),
                    
                    const Gap(16),
                    
                    _buildFormCard(
                      title: 'Personel & Keagenan',
                      icon: Icons.people,
                      children: [
                        _buildTextField('captainName', 'Nama Nahkoda', provider.data.captainName, icon: Icons.person),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('crewCount', 'Jml ABK', provider.data.crewCount?.toString(), keyboardType: TextInputType.number)),
                            const Gap(12),
                            Expanded(child: _buildTextField('passengerCount', 'Jml Penumpang', provider.data.passengerCount?.toString(), keyboardType: TextInputType.number)),
                          ],
                        ),
                        _buildTextField('unregisteredPassengers', 'Penumpang Tidak Terdaftar', provider.data.unregisteredPassengers?.toString(), keyboardType: TextInputType.number),
                        _buildTextField('agency', 'Keagenan', provider.data.agency, icon: Icons.business),
                      ],
                    ),
                    
                    const Gap(100), // Space for FAB
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
          label: const Text('Lanjut ke Data Khusus', style: TextStyle(fontWeight: FontWeight.w600)),
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
      
      int? parseInt(dynamic val) => val is String ? int.tryParse(val) : (val is int ? val : null);

      provider.updateGeneralData(
        shipName: values['shipName'],
        flag: values['flag'],
        grossTonnage: values['grossTonnage'],
        lastPort: values['lastPort'],
        arrivalDate: values['arrivalDate'],
        nextPort: values['nextPort'],
        departureDate: values['departureDate'],
        captainName: values['captainName'],
        imoNumber: values['imoNumber'],
        dockLocation: values['dockLocation'],
        crewCount: parseInt(values['crewCount']),
        passengerCount: parseInt(values['passengerCount']),
        unregisteredPassengers: parseInt(values['unregisteredPassengers']),
        agency: values['agency'],
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const Step1BDataKhusus()));
    }
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  color: isActive ? Theme.of(context).primaryColor : Colors.white,
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
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
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

  Widget _buildFormCard({required String title, required IconData icon, required List<Widget> children}) {
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
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              ),
              const Gap(12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Gap(16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String name, String label, String? initialValue, {IconData? icon, bool required = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FormBuilderTextField(
        name: name,
        initialValue: initialValue,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: required ? FormBuilderValidators.required() : null,
      ),
    );
  }

  Widget _buildDateField(String name, String label, DateTime? initialValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FormBuilderDateTimePicker(
        name: name,
        initialValue: initialValue,
        inputType: InputType.date,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
