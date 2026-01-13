import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../providers/inspection_provider.dart';
import '../widgets/custom_progress_stepper.dart';
import 'step1c_conclusion.dart';

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

    // Common text styles
    final sectionTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Data Khusus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
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
            // --- PROGRESS INDICATOR ---
            // --- PROGRESS INDICATOR ---
            const CustomProgressStepper(
              currentStep: 1, // Still step 1 formally
              totalSteps: 4,
              stepTitle: 'Kesimpulan & Rekomendasi',
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === A. PELANGGARAN KARANTINA ===
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('A. Pelanggaran Karantina', style: sectionTitleStyle),
                    ),

                    // 1. Isyarat Karantina
                    _buildSectionContainer(
                      children: [
                        _buildNumberedHeader('1', 'Isyarat Karantina'),
                        const Gap(16),
                        FormBuilderField<String>(
                          name: 'quarantineSignal',
                          initialValue: provider.data.quarantineSignal,
                          builder: (field) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildSelectionCard(
                                    label: 'Pasang',
                                    icon: Icons.flag,
                                    iconColor: Colors.blue,
                                    isSelected: field.value == 'Pasang',
                                    onTap: () {
                                      field.didChange('Pasang');
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: _buildSelectionCard(
                                    label: 'Tidak Pasang',
                                    icon: Icons.outlined_flag,
                                    iconColor: Colors.red,
                                    isSelected: field.value == 'Tidak Pasang',
                                    onTap: () {
                                      field.didChange('Tidak Pasang');
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const Gap(16),

                    // 2. Aktivitas di atas Kapal - FIXED: Using FormBuilderField instead of FormBuilderRadioGroup
                    _buildSectionContainer(
                      children: [
                        _buildNumberedHeader('2', 'Aktivitas di atas Kapal'),
                        const Gap(16),
                        FormBuilderField<String>(
                          name: 'shipActivity',
                          initialValue: provider.data.shipActivity,
                          builder: (FormFieldState<String?> field) {
                            final options = [
                              'Ada bongkar muat sebelum penerbitan Free Pratique',
                              'Naik/turun orang sebelum penerbitan Free Pratique',
                              'Tidak ada aktivitas di atas kapal',
                            ];
                            return Column(
                              children: options.map((option) {
                                final isSelected = field.value == option;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: InkWell(
                                    onTap: () {
                                      field.didChange(option);
                                      setState(() {});
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.green.withOpacity(0.05) : Colors.white,
                                        border: Border.all(
                                          color: isSelected ? Colors.green : Colors.grey[200]!,
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                            color: isSelected ? Colors.green : Colors.grey[400],
                                          ),
                                          const Gap(12),
                                          Expanded(
                                            child: Text(
                                              option,
                                              style: TextStyle(
                                                color: isSelected ? Colors.green[900] : Colors.black87,
                                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
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
                      ],
                    ),
                    const Gap(24),

                    // === B. DOKUMEN KESEHATAN KAPAL ===
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('B. Dokumen Kesehatan Kapal', style: sectionTitleStyle),
                    ),

                    // 1. MDH
                    _buildDocumentCardRefined(
                      index: '1',
                      title: 'MDH',
                      subtitle: 'Maritime Declaration of Health',
                      children: [
                        StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMainToggle(
                                  name: 'mdh_exists',
                                  value: provider.data.mdhStatus == null ? null : provider.data.mdhStatus != 'Tidak Ada',
                                  onChanged: (val) {
                                    String? newStatus;
                                    if (val == false) {
                                      newStatus = 'Tidak Ada';
                                    } else if (val == true) {
                                      newStatus = null; // Clear status if "Ada" is selected, user needs to pick "Sehat" or "Tidak Sehat"
                                    }
                                    _formKey.currentState?.fields['mdhStatus']?.didChange(newStatus);
                                    setStateSection(() {}); // Local rebuild only
                                  },
                                ),
                                const Gap(16),
                                const Gap(16),
                                const Text('STATUS KESEHATAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const Gap(8),
                                FormBuilderField<String>(
                                  name: 'mdhStatus',
                                  initialValue: provider.data.mdhStatus,
                                  builder: (field) {
                                    final isEnabled = _formKey.currentState?.fields['mdh_exists']?.value ?? (provider.data.mdhStatus != 'Tidak Ada');
                                    return Row(
                                      children: [
                                        Expanded(child: _buildStatusButton('Sehat', field, enabled: isEnabled)),
                                        const Gap(12),
                                        Expanded(child: _buildStatusButton('Tidak Sehat', field, enabled: isEnabled)),
                                      ],
                                    );
                                  },
                                ),
                                const Gap(16),
                                Builder(
                                  builder: (context) {
                                    final exists = _formKey.currentState?.fields['mdh_exists']?.value ?? (provider.data.mdhStatus != 'Tidak Ada');
                                    return _buildNoteField('mdhNote', provider.data.mdhNote, enabled: !exists);
                                  }
                                ),
                              ],
                            );
                          }
                        ),
                      ],
                    ),
                    const Gap(16),

                    // 2. SSCEC / SSCC
                    _buildDocumentCardRefined(
                      index: '2',
                      title: 'SSCEC / SSCC',
                      subtitle: 'Sanitation Cert.',
                      children: [
                        StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMainToggle(
                                  name: 'sscec_exists', 
                                   value: provider.data.sscecStatus == null ? null : provider.data.sscecStatus != 'Tidak Ada',
                                  onChanged: (val) {
                                     final newStatus = val ? null : 'Tidak Ada';
                                    _formKey.currentState?.fields['sscecStatus']?.didChange(newStatus);
                                    setStateSection(() {});
                                  },
                                ),
                                const Gap(16),
                                const Gap(16),
                                // Status Buttons
                                 FormBuilderField<String>(
                                    name: 'sscecStatus',
                                    initialValue: provider.data.sscecStatus,
                                    builder: (field) {
                                      final isEnabled = _formKey.currentState?.fields['sscec_exists']?.value ?? true;
                                      return Row(
                                        children: [
                                          Expanded(child: _buildStatusButton('Berlaku', field, enabled: isEnabled)),
                                          const Gap(12),
                                          Expanded(child: _buildStatusButton('Tidak Berlaku', field, enabled: isEnabled)),
                                        ],
                                      );
                                    },
                                  ),
                                  const Gap(16),
                                  Builder(builder: (context) {
                                     final isEnabled = _formKey.currentState?.fields['sscec_exists']?.value ?? true;
                                     return Column(children: [
                                        _buildStyledTextField('sscecPlace', 'Tempat Terbit', provider.data.sscecPlace, 'Masukkan Pelabuhan', enabled: isEnabled),
                                        const Gap(12),
                                        Row(
                                          children: [
                                            Expanded(child: _buildStyledDateField('sscecDate', 'Tanggal Terbit', provider.data.sscecDate, enabled: isEnabled)),
                                            const Gap(12),
                                            Expanded(child: _buildStyledDateField('sscecExpiry', 'Berlaku Sampai', provider.data.sscecExpiry, enabled: isEnabled)),
                                          ],
                                        ),
                                     ]);
                                  }),
                                   const Gap(16),
                                  Builder(
                                    builder: (context) {
                                      final exists = _formKey.currentState?.fields['sscec_exists']?.value ?? (provider.data.sscecStatus != 'Tidak Ada');
                                      return _buildNoteField('sscecNote', provider.data.sscecNote, enabled: !exists);
                                    }
                                  ),
                              ]
                            );
                          }
                        ),
                      ],
                    ),
                    const Gap(16),

                    // 3. Crew List
                     _buildDocumentCardRefined(
                      index: '3',
                      title: 'Crew List / Daftar ABK',
                      children: [
                        StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMainToggle(
                                  name: 'crewListStatus',
                                  value: provider.data.crewListStatus == null ? null : provider.data.crewListStatus == 'Ada',
                                  onChanged: (val) {
                                     _formKey.currentState?.fields['crewListStatus_real']?.didChange(val ? 'Ada' : 'Tidak Ada');
                                     setStateSection((){});
                                  },
                                ),
                                Visibility(
                                  visible: false,
                                  child: FormBuilderTextField(name: 'crewListStatus_real', initialValue: provider.data.crewListStatus ?? 'Ada'),
                                ),

                                const Gap(16),
                                Builder(
                                  builder: (context) {
                                    final exists = _formKey.currentState?.fields['crewListStatus']?.value ?? (provider.data.crewListStatus == 'Ada');
                                    return _buildNoteField('crewListNote', provider.data.crewListNote, enabled: !exists);
                                  }
                                ),
                              ]
                            );
                          }
                        ),
                      ],
                    ),
                    const Gap(16),

                    // 4. Buku Kuning (ICV)
                    _buildDocumentCardRefined(
                      index: '4',
                      title: 'Buku Kuning (ICV)',
                      children: [
                        StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 _buildMainToggle(
                                  name: 'icv_exists',
                                  value: provider.data.icvStatus == null ? null : provider.data.icvStatus != 'Tidak Ada',
                                  onChanged: (val) {
                                    final newStatus = val ? null : 'Tidak Ada';
                                    _formKey.currentState?.fields['icvStatus']?.didChange(newStatus);
                                    setStateSection((){});
                                  },
                                ),
                                const Gap(16),
                                const Gap(16),
                                // Status Buttons
                                   FormBuilderField<String>(
                                    name: 'icvStatus',
                                    initialValue: provider.data.icvStatus,
                                    builder: (field) {
                                      final isEnabled = _formKey.currentState?.fields['icv_exists']?.value ?? true;
                                      return Row(
                                        children: [
                                          Expanded(child: _buildStatusButton('Sesuai', field, enabled: isEnabled)),
                                          const Gap(12),
                                          Expanded(child: _buildStatusButton('Tidak Sesuai', field, enabled: isEnabled)),
                                        ],
                                      );
                                    },
                                  ),
                                  const Gap(16),
                                   Builder(
                                    builder: (context) {
                                      final exists = _formKey.currentState?.fields['icv_exists']?.value ?? (provider.data.icvStatus != 'Tidak Ada');
                                      return _buildNoteField('icvNote', provider.data.icvNote, enabled: !exists);
                                    }
                                  ),
                              ]
                            );
                          }
                        ),
                      ],
                    ),
                    const Gap(16),

                    // 5. P3K Kapal
                    _buildDocumentCardRefined(
                      index: '5',
                      title: 'P3K Kapal',
                      children: [
                        StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMainToggle(
                                  name: 'p3k_exists', 
                                  value: provider.data.p3kStatus == null ? null : provider.data.p3kStatus != 'Tidak Ada',
                                  onChanged: (val) {
                                     final newStatus = val ? null : 'Tidak Ada';
                                    _formKey.currentState?.fields['p3kStatus']?.didChange(newStatus);
                                    setStateSection(() {});
                                  },
                                ),
                                const Gap(16),
                                const Gap(16),
                                // Status Buttons
                                   FormBuilderField<String>(
                                    name: 'p3kStatus',
                                    initialValue: provider.data.p3kStatus,
                                    builder: (field) {
                                      final isEnabled = _formKey.currentState?.fields['p3k_exists']?.value ?? true;
                                      return Row(
                                        children: [
                                          Expanded(child: _buildStatusButton('Berlaku', field, enabled: isEnabled)),
                                          const Gap(12),
                                          Expanded(child: _buildStatusButton('Tidak Berlaku', field, enabled: isEnabled)),
                                        ],
                                      );
                                    },
                                  ),
                                  const Gap(16),
                                  Builder(builder: (context) {
                                     final isEnabled = _formKey.currentState?.fields['p3k_exists']?.value ?? true;
                                     return Column(children: [
                                        _buildStyledTextField('p3kPlace', 'Tempat Terbit', provider.data.p3kPlace, 'Masukkan Pelabuhan', enabled: isEnabled),
                                        const Gap(12),
                                        Row(
                                          children: [
                                            Expanded(child: _buildStyledDateField('p3kDate', 'Tanggal Terbit', provider.data.p3kDate, enabled: isEnabled)),
                                            const Gap(12),
                                            Expanded(child: _buildStyledDateField('p3kExpiry', 'Berlaku Sampai', provider.data.p3kExpiry, enabled: isEnabled)),
                                          ],
                                        ),
                                     ]);
                                  }),
                                   const Gap(16),
                                  Builder(
                                    builder: (context) {
                                      final exists = _formKey.currentState?.fields['p3k_exists']?.value ?? (provider.data.p3kStatus != 'Tidak Ada');
                                      return _buildNoteField('p3kNote', provider.data.p3kNote, enabled: !exists);
                                    }
                                  ),
                              ]
                            );
                          }
                        ),
                      ],
                    ),
                    const Gap(16),

                    // 6. Buku Kesehatan Kapal
                    _buildDocumentCardRefined(
                      index: '6',
                      title: 'Buku Kesehatan Kapal',
                      children: [
                        StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 _buildMainToggle(
                                  name: 'healthBook_exists',
                                  value: provider.data.healthBookStatus == null ? null : provider.data.healthBookStatus != 'Tidak Ada',
                                  onChanged: (val) {
                                    final newStatus = val ? null : 'Tidak Ada';
                                    _formKey.currentState?.fields['healthBookStatus']?.didChange(newStatus);
                                    setStateSection((){});
                                  },
                                ),
                                const Gap(16),
                                const Gap(16),
                                // Status Buttons
                                   FormBuilderField<String>(
                                    name: 'healthBookStatus',
                                    initialValue: provider.data.healthBookStatus,
                                    builder: (field) {
                                      final isEnabled = _formKey.currentState?.fields['healthBook_exists']?.value ?? true;
                                      return Row(
                                        children: [
                                          Expanded(child: _buildStatusButton('Sesuai', field, enabled: isEnabled)),
                                          const Gap(12),
                                          Expanded(child: _buildStatusButton('Tidak Sesuai', field, enabled: isEnabled)),
                                        ],
                                      );
                                    },
                                  ),
                                  const Gap(16),
                                  Builder(builder: (context) {
                                     final isEnabled = _formKey.currentState?.fields['healthBook_exists']?.value ?? true;
                                     return Column(children: [
                                        _buildStyledTextField('healthBookPlace', 'Tempat Terbit', provider.data.healthBookPlace, 'Masukkan Tempat', enabled: isEnabled),
                                        const Gap(12),
                                        _buildStyledDateField('healthBookDate', 'Tanggal Terbit', provider.data.healthBookDate, enabled: isEnabled),
                                     ]);
                                  }),
                                   const Gap(16),
                                  Builder(
                                    builder: (context) {
                                      final exists = _formKey.currentState?.fields['healthBook_exists']?.value ?? (provider.data.healthBookStatus != 'Tidak Ada');
                                      return _buildNoteField('healthBookNote', provider.data.healthBookNote, enabled: !exists);
                                    }
                                  ),
                              ]
                            );
                          }
                        ),
                      ],
                    ),
                    const Gap(16),

                    // 7. Voyage Memo
                     _buildDocumentCardRefined(
                      index: '7',
                      title: 'Voyage Memo',
                      children: [
                         StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMainToggle(
                                  name: 'voyageMemoStatus_toggle',
                                  value: provider.data.voyageMemoStatus == null ? null : provider.data.voyageMemoStatus == 'Ada',
                                  onChanged: (val) {
                                     _formKey.currentState?.fields['voyageMemoStatus']?.didChange(val ? 'Ada' : 'Tidak Ada');
                                     setStateSection((){});
                                  },
                                ),
                                Visibility(visible: false, child: FormBuilderTextField(name: 'voyageMemoStatus', initialValue: provider.data.voyageMemoStatus)),
                                const Gap(16),
                                Builder(
                                  builder: (context) {
                                    final exists = _formKey.currentState?.fields['voyageMemoStatus_toggle']?.value ?? (provider.data.voyageMemoStatus == 'Ada');
                                    return _buildNoteField('voyageMemoNote', provider.data.voyageMemoNote, enabled: !exists);
                                  }
                                ),
                              ]
                            );
                          }
                        ),
                      ],
                    ),
                     const Gap(16),
                     
                     // 8. Ship Particular
                     _buildDocumentCardRefined(
                      index: '8',
                      title: 'Ship Particular',
                      children: [
                        StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMainToggle(
                                  name: 'shipParticularStatus_toggle',
                                  value: provider.data.shipParticularStatus == null ? null : provider.data.shipParticularStatus == 'Ada',
                                  onChanged: (val) {
                                     _formKey.currentState?.fields['shipParticularStatus']?.didChange(val ? 'Ada' : 'Tidak Ada');
                                     setStateSection((){});
                                  },
                                ),
                                Visibility(visible: false, child: FormBuilderTextField(name: 'shipParticularStatus', initialValue: provider.data.shipParticularStatus)),
                                const Gap(16),
                                Builder(
                                  builder: (context) {
                                    final exists = _formKey.currentState?.fields['shipParticularStatus_toggle']?.value ?? (provider.data.shipParticularStatus == 'Ada');
                                    return _buildNoteField('shipParticularNote', provider.data.shipParticularNote, enabled: !exists);
                                  }
                                ),
                              ]
                            );
                          }
                        ),
                      ],
                    ),
                    const Gap(16),

                    // 9. Manifest Cargo
                     _buildDocumentCardRefined(
                      index: '9',
                      title: 'Manifest Cargo',
                      children: [
                        StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMainToggle(
                                  name: 'manifestCargoStatus_toggle',
                                  value: provider.data.manifestCargoStatus == null ? null : provider.data.manifestCargoStatus == 'Ada',
                                  onChanged: (val) {
                                     _formKey.currentState?.fields['manifestCargoStatus']?.didChange(val ? 'Ada' : 'Tidak Ada');
                                     setStateSection((){});
                                  },
                                ),
                                 Visibility(visible: false, child: FormBuilderTextField(name: 'manifestCargoStatus', initialValue: provider.data.manifestCargoStatus)),
                                const Gap(16),
                                Builder(
                                  builder: (context) {
                                    final exists = _formKey.currentState?.fields['manifestCargoStatus_toggle']?.value ?? (provider.data.manifestCargoStatus == 'Ada');
                                    return _buildNoteField('manifestCargoNote', provider.data.manifestCargoNote, enabled: !exists);
                                  }
                                ),
                              ]
                            );
                          }
                        ),
                      ],
                    ),
                    const Gap(32),
                    
                    // C. Faktor Risiko PHEIC
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('C. Faktor Risiko PHEIC', style: sectionTitleStyle),
                    ),
                    _buildSectionContainer(
                      children: [
                        StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 _buildNumberedHeader('1', 'Sanitasi Kapal'),
                                 const Gap(16),
                                 FormBuilderField<bool>(
                                  name: 'sanitationRisk',
                                  initialValue: provider.data.sanitationRisk,
                                  builder: (field) {
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildSelectionCard(
                                                label: 'Ada',
                                                icon: Icons.warning_amber_rounded,
                                                iconColor: Colors.orange,
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
                                                label: 'Tidak ada',
                                                icon: Icons.check_circle_outline,
                                                iconColor: Colors.green,
                                                isSelected: field.value == false,
                                                onTap: () {
                                                  field.didChange(false);
                                                  setStateSection(() {});
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Gap(16),
                                        // Detail Text Field
                                        _buildStyledTextField(
                                          'sanitationRiskDetail', 
                                          'Detail Temuan Sanitasi', 
                                          provider.data.sanitationRiskDetail, 
                                          'Jelaskan temuan risiko...',
                                          enabled: field.value == true,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ]
                            );
                          }
                        ),
                      ]
                    ),
                    const Gap(16),
                    _buildSectionContainer(
                      children: [
                        StatefulBuilder(
                          builder: (context, setStateSection) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 _buildNumberedHeader('2', 'Risiko Orang & P3K'),
                                 const Gap(16),
                                FormBuilderField<bool>(
                                  name: 'healthRisk',
                                  initialValue: provider.data.healthRisk,
                                  builder: (field) {
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildSelectionCard(
                                                label: 'Ada',
                                                icon: Icons.medical_services_outlined,
                                                iconColor: Colors.red,
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
                                                label: 'Tidak ada',
                                                icon: Icons.check_circle_outline,
                                                iconColor: Colors.green,
                                                isSelected: field.value == false,
                                                onTap: () {
                                                  field.didChange(false);
                                                  setStateSection(() {});
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Gap(16),
                                        // Detail Text Field
                                        _buildStyledTextField(
                                          'healthRiskDetail', 
                                          'Detail Temuan Kesehatan', 
                                          provider.data.healthRiskDetail, 
                                          'Jelaskan temuan risiko...',
                                          enabled: field.value == true,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ]
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
          label: const Text(
            'Lanjut ke Kesimpulan dan Rekomendasi',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ==================== WIDGETS ====================

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildNumberedHeader(String number, String title) {
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const Gap(10),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
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
        height: 80,
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
             Icon(icon, color: isSelected ? iconColor : Colors.grey[400]),
             const Gap(8),
             Text(
               label, 
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

  Widget _buildDocumentCardRefined({
    required String index,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFE0F7FA),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$index. $title', style: TextStyle(color: const Color(0xFF006064), fontWeight: FontWeight.bold, fontSize: 15)),
                if (subtitle != null)
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'monospace')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainToggle({
    required String name,
    bool? value, // acting as initialValue
    required ValueChanged<bool> onChanged,
  }) {
    return FormBuilderField<bool>(
      name: name,
      initialValue: value,
      builder: (FormFieldState<bool> field) {
        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            return Row(
              children: [
                _buildTogglePart('Ada', true, field.value, (val) {
                  field.didChange(val);
                  onChanged(val);
                }),
                _buildTogglePart('Tidak Ada', false, field.value, (val) {
                  field.didChange(val);
                  onChanged(val);
                }),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildTogglePart(String label, bool isLeft, bool? currentValue, ValueChanged<bool> onChanged) {
    final bool isActive = currentValue == null ? false : (isLeft ? currentValue == true : currentValue == false);
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(isLeft),
        child: Container(
          margin: const EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isActive ? [ BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2) ] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Theme.of(context).primaryColor : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, FormFieldState<String> field,
      {bool enabled = true}) {
    final isSelected = field.value == label;
    final primaryColor = Theme.of(context).primaryColor;
    
    // Visual style for disabled state
    final Color bgColor = enabled 
        ? (isSelected ? primaryColor.withOpacity(0.08) : Colors.white)
        : Colors.grey[200]!;
    final Color borderColor = enabled
        ? (isSelected ? primaryColor : Colors.grey[200]!)
        : Colors.transparent;
    final Color textColor = enabled
        ? (isSelected ? primaryColor : Colors.grey[600]!)
        : Colors.grey[400]!;

    return GestureDetector(
      onTap: enabled
          ? () {
              field.didChange(label);
              setState(() {});
            }
          : null,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
  
  Widget _buildStyledTextField(String name, String label, String? initialValue, String hint, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: enabled ? Colors.grey : Colors.grey[300], fontWeight: FontWeight.bold)),
        const Gap(6),
        FormBuilderTextField(
          name: name,
          initialValue: initialValue,
          enabled: enabled,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: !enabled,
            fillColor: !enabled ? Colors.grey[100] : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
        )
      ],
    );
  }
  
  Widget _buildStyledDateField(String name, String label, DateTime? initialValue, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: enabled ? Colors.grey : Colors.grey[300], fontWeight: FontWeight.bold)),
        const Gap(6),
        FormBuilderDateTimePicker(
          name: name,
          initialValue: initialValue,
          inputType: InputType.date,
          enabled: enabled,
          style: const TextStyle(fontSize: 14),
          fieldHintText: 'mm/dd/yyyy',
          decoration: InputDecoration(
             prefixIcon: Icon(Icons.calendar_today, size: 16, color: enabled ? Colors.grey : Colors.grey[300]),
             isDense: true,
             filled: !enabled,
             fillColor: !enabled ? Colors.grey[100] : null,
             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
             disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField(String name, String? initialValue, {bool enabled = true}) {
      return FormBuilderTextField(
          name: name,
          initialValue: initialValue,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: 'Bila tidak ada, alasannya...',
            isDense: true,
            filled: !enabled,
            fillColor: !enabled ? Colors.grey[100] : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)), 
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)), 
          ),
          style: const TextStyle(fontSize: 13),
      );
  }

  Widget _buildSegmentedButtonBool(
      String name, Map<String, bool> options, bool? initialValue) {
    return FormBuilderField<bool>(
      name: name,
      initialValue: initialValue,
      builder: (FormFieldState<bool> field) {
        return SegmentedButton<bool>(
          segments: options.entries
              .map((e) => ButtonSegment<bool>(
                    value: e.value,
                    label: Text(e.key, style: const TextStyle(fontSize: 12)),
                  ))
              .toList(),
          selected: field.value != null ? {field.value!} : {},
          emptySelectionAllowed: true,
          onSelectionChanged: (Set<bool> newSelection) {
            if(newSelection.isNotEmpty) {
                 field.didChange(newSelection.first);
                 setState((){});
            }
          },
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      },
    );
  }
  


  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
       final values = _formKey.currentState!.value;
       final provider = Provider.of<InspectionProvider>(context, listen: false);

       provider.updateQuarantineViolations(signal: values['quarantineSignal'], activity: values['shipActivity']);
       provider.updateDocumentMDH(status: values['mdhStatus'], note: values['mdhNote']);
       provider.updateDocumentSSCEC(
          status: values['sscecStatus'], note: values['sscecNote'], 
          place: values['sscecPlace'], date: values['sscecDate'], expiry: values['sscecExpiry']
       );
       provider.updateDocumentCrewList(status: values['crewListStatus_real'], note: values['crewListNote']);
       provider.updateDocumentICV(status: values['icvStatus'], note: values['icvNote']);
       provider.updateDocumentP3K(
          status: values['p3kStatus'], note: values['p3kNote'],
          place: values['p3kPlace'], date: values['p3kDate'], expiry: values['p3kExpiry']
       ); 
       provider.updateDocumentHealthBook(
          status: values['healthBookStatus'], note: values['healthBookNote'],
          place: values['healthBookPlace'], date: values['healthBookDate'],
       );
       provider.updateOtherDocuments(
        voyageStatus: values['voyageMemoStatus_toggle'] == true ? 'Ada' : 'Tidak Ada',
        voyageNote: values['voyageMemoNote'],
        shipPartStatus: values['shipParticularStatus_toggle'] == true ? 'Ada' : 'Tidak Ada',
        shipPartNote: values['shipParticularNote'],
        manifestStatus: values['manifestCargoStatus_toggle'] == true ? 'Ada' : 'Tidak Ada',
        manifestNote: values['manifestCargoNote'],
      );

      provider.updateRisks(
        sanitation: values['sanitationRisk'],
        sDetail: values['sanitationRiskDetail'],
        health: values['healthRisk'],
        hDetail: values['healthRiskDetail'],
      );

       Navigator.push(context, MaterialPageRoute(builder: (_) => const Step1cConclusion()));
    }
  }
}
