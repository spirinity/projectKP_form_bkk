import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../models/inspection_model.dart';
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildStepIndicator(1, 'Data Umum', true, false),
                  _buildStepLine(true),
                  _buildStepIndicator(2, 'Data Khusus', true, false),
                  _buildStepLine(true),
                  _buildStepIndicator(3, 'Sanitasi', false, true),
                  _buildStepLine(false),
                  _buildStepIndicator(4, 'Kesehatan', false, false),
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
                    // Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              'Beri tanda (✓) pada kolom sesuai dengan kondisi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(16),

                    // Sanitation Table Card
                    _buildSanitationTableCard(),

                    const Gap(16),

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
            'Lanjut ke Kesehatan',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSanitationTableCard() {
    return Container(
      width: double.infinity,
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.checklist,
                    color: Colors.teal,
                    size: 20,
                  ),
                ),
                const Gap(12),
                const Expanded(
                  child: Text(
                    'Pemeriksaan Sanitasi Kapal',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Legend - Above Table
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keterangan:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.grey[700],
                  ),
                ),
                const Gap(4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '• MS = Memenuhi Syarat (Qualify)',
                        style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '• TT = Tampak Tanda (Visible Signs)',
                        style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '• TMS = Tidak Memenuhi Syarat (Unqualify)',
                        style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '• TTT = Tidak Tampak Tanda (No Evidence)',
                        style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Table Header with merged cells using Stack for true vertical centering
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // No column - true merged cell using Stack
                  SizedBox(
                    width: 35,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border(
                          right: BorderSide(color: Colors.grey[400]!),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'No',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Lokasi column - true merged cell
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border(
                          right: BorderSide(color: Colors.grey[400]!),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Lokasi Yang Diperiksa\n(Inspected Areas)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  // Kondisi Sanitasi + Vektor columns with sub-headers
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        // Parent headers row
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    border: Border(
                                      right: BorderSide(
                                        color: Colors.grey[400]!,
                                      ),
                                      bottom: BorderSide(
                                        color: Colors.grey[400]!,
                                      ),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Kondisi Sanitasi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[400]!,
                                      ),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Vektor',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Sub-headers row (MS, TMS, TT, TTT)
                        SizedBox(
                          height: 28,
                          child: Row(
                            children: [
                              _buildSubHeader('MS'),
                              _buildSubHeader('TMS'),
                              _buildSubHeader('TT'),
                              _buildSubHeader('TTT', isLast: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Table Rows
          Consumer<InspectionProvider>(
            builder: (context, provider, _) {
              return Column(
                children: SanitationAreaKeys.allKeys.asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key;
                  final areaKey = entry.value;
                  final areaData = provider.data.sanitationAreas[areaKey]!;
                  final isEven = index % 2 == 0;

                  return _buildTableRow(
                    index: index + 1,
                    areaKey: areaKey,
                    label: SanitationAreaKeys.getLabel(areaKey),
                    areaData: areaData,
                    isEven: isEven,
                    provider: provider,
                  );
                }).toList(),
              );
            },
          ),

          const Gap(8),
        ],
      ),
    );
  }

  Widget _buildSubHeader(String text, {bool isLast = false}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(right: BorderSide(color: Colors.grey[400]!)),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow({
    required int index,
    required String areaKey,
    required String label,
    required SanitationAreaData areaData,
    required bool isEven,
    required InspectionProvider provider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isEven ? Colors.grey[50] : Colors.white),
      child: Row(
        children: [
          SizedBox(
            width: 35,
            child: Text(
              '$index',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                label,
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          _buildCheckboxCell(
            value: areaData.qualify,
            onChanged: (val) {
              provider.updateSanitationArea(
                areaKey,
                qualify: val,
                unqualify: val == true ? false : null,
              );
            },
          ),
          _buildCheckboxCell(
            value: areaData.unqualify,
            onChanged: (val) {
              provider.updateSanitationArea(
                areaKey,
                unqualify: val,
                qualify: val == true ? false : null,
              );
            },
          ),
          _buildCheckboxCell(
            value: areaData.visibleSigns,
            onChanged: (val) {
              provider.updateSanitationArea(
                areaKey,
                visibleSigns: val,
                noSigns: val == true ? false : null,
              );
            },
          ),
          _buildCheckboxCell(
            value: areaData.noSigns,
            onChanged: (val) {
              provider.updateSanitationArea(
                areaKey,
                noSigns: val,
                visibleSigns: val == true ? false : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxCell({
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Expanded(
      flex: 1,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            activeColor: Colors.teal,
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    // Save notes - removed per request

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Step3HealthForm()),
    );
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
}
