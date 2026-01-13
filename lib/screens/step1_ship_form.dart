import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../providers/inspection_provider.dart';
import '../widgets/custom_progress_stepper.dart';
import 'step1b_data_khusus.dart';

class Step1ShipForm extends StatefulWidget {
  const Step1ShipForm({super.key});

  @override
  State<Step1ShipForm> createState() => _Step1ShipFormState();
}

class _Step1ShipFormState extends State<Step1ShipForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  static const Map<String, String> _countryFlags = {
    'Indonesia': '🇮🇩', 'Panama': '🇵🇦', 'Singapore': '🇸🇬', 'Malaysia': '🇲🇾',
    'Liberia': '🇱🇷', 'Marshall Islands': '🇲🇭', 'Vietnam': '🇻🇳', 'Thailand': '🇹🇭',
    'Philippines': '🇵🇭', 'China': '🇨🇳', 'Hong Kong': '🇭🇰', 'Japan': '🇯🇵'
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InspectionProvider>(context, listen: false);
    final theme = Theme.of(context);

    // Dummy data lists for dropdowns to match visual style if needed, 
    // or just use text fields if data model dictates strings.
    // The user requested UI changes but to keep existing data content.
    // We will assume existing fields are strings mostly.

    return Scaffold(
      backgroundColor: Colors.grey[100], // bg-background-light
      appBar: AppBar(
        title: const Text('Data Umum Kapal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            // Progress Indicator
            const CustomProgressStepper(
              currentStep: 1,
              totalSteps: 4,
              stepTitle: 'Data Khusus',
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- IDENTITAS KAPAL (DATA UMUM) ---
                    _buildFormCard(
                      title: 'Data Umum',
                      icon: Icons.directions_boat,
                      children: [
                         // Nama Kapal
                        _buildStyledTextField(
                          name: 'shipName',
                          label: 'Nama Kapal',
                          initialValue: provider.data.shipName,
                          hintText: 'Nama Kapal',
                          validator: FormBuilderValidators.required(),
                        ),
                        const Gap(16),
                        
                        // Flag & GT row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStyledDropdown(
                                name: 'flag',
                                label: 'Bendera',
                                initialValue: provider.data.flag,
                                hintText: 'Negara',
                                items: _countryFlags.keys
                                    .map((country) => DropdownMenuItem(
                                          value: country,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(_countryFlags[country]!, style: const TextStyle(fontSize: 20)),
                                              const Gap(8),
                                              Flexible(
                                                child: Text(
                                                  country,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: _buildStyledTextField(
                                name: 'grossTonnage',
                                label: 'Besar Kapal (GT)', // Closest to 'Tipe Kapal' structure-wise
                                initialValue: provider.data.grossTonnage,
                                hintText: 'Besar Kapal (GT)',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        
                        // IMO Number
                        _buildStyledTextField(
                          name: 'imoNumber',
                          label: 'Nomor IMO',
                          initialValue: provider.data.imoNumber,
                          hintText: 'Nomor IMO',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    const Gap(16),

                    // --- PERJALANAN ---
                    _buildFormCard(
                      title: 'Perjalanan',
                      icon: Icons.route,
                      children: [
                         // Last Port (Pelabuhan Asal)
                         _buildStyledTextField(
                          name: 'lastPort',
                          label: 'Pelabuhan Asal',
                          initialValue: provider.data.lastPort,
                          hintText: 'Pelabuhan Asal',
                          prefixIcon: Icons.anchor,
                         ),
                         const Gap(16),
                         
                         // Arrival Date
                         _buildStyledDateField(
                           name: 'arrivalDate',
                           label: 'Tanggal Kedatangan',
                           initialValue: provider.data.arrivalDate,
                         ),
                         const Gap(16),

                         // Next Port (Tujuan)
                         _buildStyledTextField(
                          name: 'nextPort',
                          label: 'Tujuan',
                          initialValue: provider.data.nextPort,
                          hintText: 'Tujuan',
                          prefixIcon: Icons.anchor,
                         ),
                         const Gap(16),
                         
                         // Departure Date
                         _buildStyledDateField(
                           name: 'departureDate',
                           label: 'Estimasi Keberangkatan',
                           initialValue: provider.data.departureDate,
                         ),
                         const Gap(16),

                         // Dock Location
                         _buildStyledTextField(
                           name: 'dockLocation',
                           label: 'Lokasi Sandar',
                           initialValue: provider.data.dockLocation,
                           hintText: 'Dermaga',
                           prefixIcon: Icons.location_on,
                         ),
                      ],
                    ),

                    const Gap(16),

                    // --- PERSONEL & KEAGENAN ---
                    _buildFormCard(
                      title: 'Personel & Keagenan',
                      icon: Icons.people,
                      children: [
                        _buildStyledTextField(
                          name: 'captainName',
                          label: 'Nama Nahkoda',
                          initialValue: provider.data.captainName,
                          hintText: 'Nama Kapten',
                          prefixIcon: Icons.person,
                        ),
                        const Gap(16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildStyledTextField(
                                name: 'crewCount',
                                label: 'Jumlah ABK',
                                initialValue: provider.data.crewCount?.toString(),
                                hintText: '0',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: _buildStyledTextField(
                                name: 'passengerCount',
                                label: 'Jumlah Penumpang',
                                initialValue: provider.data.passengerCount?.toString(),
                                hintText: '0',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        
                        _buildStyledTextField(
                          name: 'unregisteredPassengers',
                          label: 'Penumpang Tdk Terdaftar',
                          initialValue: provider.data.unregisteredPassengers?.toString(),
                          hintText: '0',
                          keyboardType: TextInputType.number,
                        ),
                        const Gap(16),

                        _buildStyledTextField(
                          name: 'agency',
                          label: 'Keagenan',
                          initialValue: provider.data.agency,
                          hintText: 'Nama Agen',
                          prefixIcon: Icons.business,
                        ),
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
          label: const Text(
            'Lanjut ke Data Khusus',
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

      int? parseInt(dynamic val) =>
          val is String ? int.tryParse(val) : (val is int ? val : null);

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Step1BDataKhusus()),
      );
    }
  }

  // --- UI COMPONENTS AS PER REFERENCE ---

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    // Matching the HTML: flex flex-col gap-4
    // Header with bottom border
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4, // Reduced from 10
            offset: const Offset(0, 2), // Reduced from 4
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!), // border-border-light
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 24),
                const Gap(8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18, // text-lg
                    fontWeight: FontWeight.bold, // font-bold
                    color: Colors.black87, // text-text-main-light
                  ),
                ),
              ],
            ),
          ),
          const Gap(16), // space-y-4
          ...children,
        ],
      ),
    );
  }

  // Matching HTML: label flex flex-col gap-1.5, input h-12 rounded-lg bg-background-light border...
  Widget _buildStyledTextField({
    required String name,
    required String label,
    String? initialValue,
    String? hintText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14, // text-sm
            fontWeight: FontWeight.w500, // font-medium
            color: Colors.black87, // text-text-main-light
          ),
        ),
        const Gap(6), // gap-1.5 -> approx 6px
        FormBuilderTextField(
          name: name,
          initialValue: initialValue,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
             isDense: true,
             hintText: hintText,
             hintStyle: TextStyle(
               color: Colors.grey[400], // placeholder:text-text-sub-light
               fontSize: 14,
             ),
             prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon, color: Colors.grey[400], size: 20) 
                : null,
             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // h-12 approx 48px -> 14 vert padding with 14 font + borders
             filled: true,
             fillColor: Colors.grey[50], // bg-background-light
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8), // rounded-lg
               borderSide: BorderSide(color: Colors.grey[300]!), // border-border-light
             ),
             enabledBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8),
               borderSide: BorderSide(color: Colors.grey[300]!),
             ),
             focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8),
               borderSide: BorderSide(color: Theme.of(context).primaryColor), // focus:border-primary
             ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledDateField({
    required String name,
    required String label,
    DateTime? initialValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const Gap(6),
        FormBuilderDateTimePicker(
          name: name,
          initialValue: initialValue,
          inputType: InputType.date,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
             isDense: true,
             hintText: 'Pilih Tanggal',
             hintStyle: TextStyle(
               color: Colors.grey[400],
               fontSize: 14,
             ),
             prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[400], size: 20),
             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
             filled: true,
             fillColor: Colors.grey[50],
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8),
               borderSide: BorderSide(color: Colors.grey[300]!),
             ),
             enabledBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8),
               borderSide: BorderSide(color: Colors.grey[300]!),
             ),
             focusedBorder: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8),
               borderSide: BorderSide(color: Theme.of(context).primaryColor),
             ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledDropdown({
    required String name,
    required String label,
    required List<DropdownMenuItem<String>> items,
    String? initialValue,
    String? hintText,
  }) {
    // Re-map items to ensure they are centered within the dropdown
    final centeredItems = items.map((item) {
      return DropdownMenuItem<String>(
        value: item.value,
        child: Center(child: item.child),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const Gap(6),
        FormBuilderDropdown<String>(
          name: name,
          initialValue: initialValue,
          items: centeredItems,
          isExpanded: true,
          alignment: AlignmentDirectional.center,
          // Use widget hint for centering
          hint: hintText != null 
              ? Center(child: Text(hintText, style: TextStyle(color: Colors.grey[400], fontSize: 14))) 
              : null,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            isDense: true,
            // Hint is handled by the widget property above
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }


}
