import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inspection_provider.dart';
import '../widgets/custom_progress_stepper.dart';
import 'step2_sanitation_form.dart';

class Step1cConclusion extends StatefulWidget {
  const Step1cConclusion({super.key});

  @override
  State<Step1cConclusion> createState() => _Step1cConclusionState();
}

class _Step1cConclusionState extends State<Step1cConclusion> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InspectionProvider>(context, listen: false);
    final theme = Theme.of(context);

    // Common text styles
    final sectionTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Kesimpulan & Rekomendasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
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
             // Progress Indicator (Step 1: Data Kapal is active)
             // Progress Indicator (Step 3: Kesehatan is active)
            const CustomProgressStepper(
              currentStep: 1,
              totalSteps: 4,
              stepTitle: 'Sanitasi Kapal',
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // III. KESIMPULAN
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('III. Kesimpulan', style: sectionTitleStyle),
                    ),
                    _buildSectionContainer(
                      children: [
                        FormBuilderField<bool>(
                          name: 'isPHEICFree',
                          initialValue: provider.data.isPHEICFree ?? true,
                          builder: (field) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildSelectionCard(
                                    label: 'Kapal Bebas PHEIC',
                                    icon: Icons.check_circle_outline,
                                    iconColor: Colors.green,
                                    isSelected: field.value == true,
                                    onTap: () {
                                      field.didChange(true);
                                    },
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: _buildSelectionCard(
                                    label: 'Tidak Bebas PHEIC',
                                    icon: Icons.warning_amber_rounded,
                                    iconColor: Colors.red,
                                    isSelected: field.value == false,
                                    onTap: () {
                                      field.didChange(false);
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),

                    const Gap(32),

                    // IV. REKOMENDASI
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('IV. Rekomendasi', style: sectionTitleStyle),
                    ),
                    
                    // A. Kapal dalam Karantina
                    _buildSectionContainer(
                      children: [
                        StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNumberedHeader('A', 'Kapal dalam Karantina'),
                                const Gap(16),
                                FormBuilderField<String>(
                                  name: 'quarantineRecommendation',
                                  initialValue: provider.data.quarantineRecommendation,
                                  builder: (FormFieldState<String?> field) {
                                    final options = [
                                      'Free Pratique',
                                      'Free Pratique dengan Syarat',
                                      'No Free Pratique',
                                    ];
                                    final labels = {
                                      'Free Pratique': 'Kapal diberikan Free Pratique',
                                      'Free Pratique dengan Syarat': 'Kapal diberikan Free Pratique dengan syarat',
                                      'No Free Pratique': 'Kapal tidak diberikan Free Pratique',
                                    };
                                    return Column(
                                      children: options.map((option) {
                                        final isSelected = field.value == option;
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: InkWell(
                                            onTap: () {
                                              field.didChange(option);
                                              setStateSection(() {}); 
                                            },
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              decoration: BoxDecoration(
                                                color: isSelected ? theme.primaryColor.withOpacity(0.05) : Colors.white,
                                                border: Border.all(
                                                  color: isSelected ? theme.primaryColor : Colors.grey[200]!,
                                                  width: isSelected ? 1.5 : 1,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                                    color: isSelected ? theme.primaryColor : Colors.grey[400],
                                                    size: 20,
                                                  ),
                                                  const Gap(12),
                                                  Expanded(
                                                    child: Text(
                                                      labels[option]!,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                        color: isSelected ? theme.primaryColor : Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                                // Detail Inputs for Free Pratique
                                if (_formKey.currentState?.fields['quarantineRecommendation']?.value == 'Free Pratique') ...[
                                    const Gap(12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!)
                                      ),
                                      child: Column(
                                        children: [
                                            _buildStyledTextField('freePratiqueNo', 'NO', null, 'Nomor Free Pratique'),
                                            const Gap(8),
                                            Row(
                                              children: [
                                                Expanded(child: _buildStyledDateField('freePratiqueDate', 'Tanggal', DateTime.now())),
                                                const Gap(8),
                                                Expanded(child: _buildStyledTimeField('freePratiqueTime', 'Jam', DateTime.now())),
                                              ],
                                            )
                                        ],
                                      ),
                                    )
                                ],
                              ],
                            );
                          }
                        ),
                      ]
                    ),
                    
                    const Gap(16),

                    // B. Kapal dalam Negeri
                    _buildSectionContainer(
                      children: [
                        StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNumberedHeader('B', 'Kapal dalam Negeri'),
                                const Gap(16),
                                FormBuilderField<bool>(
                                  name: 'sibGiven',
                                  initialValue: provider.data.sibGiven,
                                  builder: (field) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: _buildSelectionCard(
                                            label: 'Kapal diberikan S I B',
                                            icon: Icons.check_circle_outline,
                                            iconColor: Colors.blue,
                                            isSelected: field.value == true,
                                            onTap: () {
                                              field.didChange(true);
                                              setStateSection(() {});
                                            },
                                          ),
                                        ),
                                        const Gap(12),
                                        Expanded(
                                          child: _buildSelectionCard(
                                            label: 'Tidak Diberikan',
                                            icon: Icons.cancel_outlined,
                                            iconColor: Colors.red,
                                            isSelected: field.value == false,
                                            onTap: () {
                                              field.didChange(false);
                                              setStateSection(() {});
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                // Detail Inputs for SIB
                                if (_formKey.currentState?.fields['sibGiven']?.value == true) ...[
                                    const Gap(12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!)
                                      ),
                                      child: Column(
                                        children: [
                                            _buildStyledTextField('sibNumber', 'NO', provider.data.sibNumber, 'Nomor SIB'),
                                            const Gap(8),
                                            Row(
                                              children: [
                                                Expanded(child: _buildStyledDateField('sibDate', 'Tanggal', provider.data.sibDate ?? DateTime.now())),
                                                const Gap(8),
                                                Expanded(child: _buildStyledTimeField('sibTime', 'Jam', provider.data.sibDate ?? DateTime.now())),
                                              ],
                                            )
                                        ],
                                      ),
                                    )
                                ],
                              ],
                            );
                          }
                        ),
                      ]
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
          label: const Text('Lanjut ke Sanitasi', style: TextStyle(fontWeight: FontWeight.w600)),
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
      
      // Combine Date and Time for SIB and Free Pratique
      // Note: Model might need updates if we strictly want separate Time fields, but for now we can merge into DateTime or just use text for Number.
      
      // Update data
      provider.updateConclusion(isPHEICFree: values['isPHEICFree']);
      
      // For Recommendation
      provider.updateRecommendation(
        qRec: values['quarantineRecommendation'],
        qDate: values['freePratiqueDate'], // Simplified for now
        sibNum: values['sibNumber'],
        sibGiven: values['sibGiven'],
        sibDate: values['sibDate'], // Simplified
      );

      Navigator.push(context, MaterialPageRoute(builder: (_) => const Step2SanitationForm()));
    }
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildNumberedHeader(String number, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
          child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const Gap(10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
  
   Widget _buildStyledTextField(String name, String label, String? initialValue, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const Gap(6),
        FormBuilderTextField(
          name: name,
          initialValue: initialValue,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        )
      ],
    );
  }
  
  Widget _buildStyledDateField(String name, String label, DateTime? initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const Gap(6),
        FormBuilderDateTimePicker(
          name: name,
          initialValue: initialValue,
          inputType: InputType.date,
          style: const TextStyle(fontSize: 14),
          fieldHintText: 'mm/dd/yyyy',
          decoration: InputDecoration(
             prefixIcon: const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
             isDense: true,
             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStyledTimeField(String name, String label, DateTime? initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const Gap(6),
         FormBuilderDateTimePicker(
          name: name,
          initialValue: initialValue,
          inputType: InputType.time,
          style: const TextStyle(fontSize: 14),
          fieldHintText: 'HH:mm',
          decoration: InputDecoration(
             prefixIcon: const Icon(Icons.access_time, size: 16, color: Colors.grey),
             isDense: true,
             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isCompleted, bool isCurrent) {
    Color bgColor = (isCompleted || isCurrent) ? Colors.white : Colors.white.withOpacity(0.3);
    Color contentColor = Theme.of(context).primaryColor;
    Color labelColor = (isCompleted || isCurrent) ? Colors.white : Colors.white.withOpacity(0.6);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: contentColor, size: 16)
                  : Text('$step', style: TextStyle(color: contentColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          const Gap(4),
          SizedBox(
            height: 24,
            child: Text(label, style: TextStyle(color: labelColor, fontSize: 10), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return Container(
      width: 20, height: 2,
      color: isCompleted ? Colors.white : Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildSelectionCard({
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100, // Slightly taller for potential 2 lines text
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? iconColor : Colors.grey[200]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(icon, color: isSelected ? iconColor : Colors.grey[400], size: 28),
             const Gap(8),
             Text(
               label, 
               textAlign: TextAlign.center,
               style: TextStyle(
                 fontSize: 13, 
                 fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                 color: isSelected ? iconColor : Colors.black87
               )
             ),
          ],
        ),
      ),
    );
  }
}
