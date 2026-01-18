import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/inspection_model.dart';
import '../providers/inspection_provider.dart';
import 'preview_screen.dart';
import 'step1_ship_form.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color primaryDeep = const Color(0xFF005c4b);
  final TextEditingController _searchController = TextEditingController();
  
  // Data Laporan
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _filteredReports = []; // Added for search/filter

  // Filter State
  String _selectedFilterMode = 'Semua';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadReports();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _loadReports() async {
    final data = await StorageService.getReports();
    if (mounted) {
      setState(() {
        _reports = data;
        _applyFilters(); // Apply filter initially
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredReports = _reports.where((report) {
        // 1. Search Query
        final shipName = (report['shipName'] ?? '').toLowerCase();
        final matchesQuery = shipName.contains(query);

        // 2. Status Mode
        bool matchesMode = true;
        if (_selectedFilterMode == 'Selesai') {
          matchesMode = report['status'] == 'SELESAI';
        } else if (_selectedFilterMode == 'Draf') {
          matchesMode = report['status'] != 'SELESAI';
        }

        // 3. Date Filter
        bool matchesDate = true;
        if (_selectedDate != null) {
          try {
            final reportDate = DateTime.parse(report['date']);
            matchesDate = reportDate.year == _selectedDate!.year &&
                          reportDate.month == _selectedDate!.month &&
                          reportDate.day == _selectedDate!.day;
          } catch (_) {
            matchesDate = false;
          }
        }

        return matchesQuery && matchesMode && matchesDate;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryDeep,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: statusBarHeight + 20,
                    left: 24,
                    right: 24,
                    bottom: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "Riwayat Inspeksi",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(20),

                      // Search Bar
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              clipBehavior: Clip.antiAlias, // FORCE CLIP
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50), // Fully Rounded Capsule
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Cari nama kapal...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey[400],
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, // Agak menjorok ke dalam
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Gap(12),
                          // Filter Button
                          Container(
                            width: 48,
                            height: 48,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(50), // Fully Rounded Circle
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.tune,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _showFilterBottomSheet(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // LIST REPORTS
              Expanded(
                child: _filteredReports.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16, 
                          right: 16, 
                          top: 16, 
                          bottom: 120, // Space for bottom nav
                        ),
                        // Balik urutan agar yang baru di atas? 
                        // StorageService.saveReport insert di index 0, jadi _reports[0] sudah yang terbaru. Aman.
                        itemCount: _filteredReports.length,
                        itemBuilder: (context, index) {
                          final report = _filteredReports[index];
                          return _buildReportCard(report);
                        },
                      ),
              ),
            ],
          ),
          
          // BOTTOM NAVIGATION BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final bool isSelesai = report['status'] == 'SELESAI';
    
    // Parsing Tanggal & Waktu
    DateTime dateObj;
    try {
      dateObj = DateTime.parse(report['date']);
    } catch (e) {
      dateObj = DateTime.now();
    }
    
    final String dateStr = DateFormat('d MMM yyyy', 'id_ID').format(dateObj);
    final String timeStr = DateFormat('HH:mm', 'id_ID').format(dateObj) + " WITA";

    // Warna Icon berdasarkan tipe
    Color iconColor;
    switch (report['type']) {
      case 'Sanitasi Kapal': iconColor = const Color(0xFF00BFA5); break;
      case 'Pemeriksaan Kargo': iconColor = const Color(0xFF78909C); break;
      case 'Kontrol Vektor': iconColor = const Color(0xFFFF9800); break;
      case 'Dokumen Kesehatan': iconColor = const Color(0xFF2196F3); break;
      default: iconColor = primaryDeep;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Restore Data & Preview
            final model = InspectionModel.fromMap(report);
            Provider.of<InspectionProvider>(context, listen: false).setInspectionData(model);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PreviewScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Row 1: Icon, Name, Status
                Row(
                  children: [
                    // Icon Container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_boat_filled,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    // Name & Type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report['shipName'] ?? 'Tanpa Nama',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            report['type'] ?? '-',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelesai
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        report['status'] ?? 'UNKNOWN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelesai
                              ? const Color(0xFF388E3C)
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                // Row 2: Date & Time
                Row(
                  children: [
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const Gap(6),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    // Time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const Gap(6),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const Gap(16),
          Text(
            "Belum ada riwayat inspeksi",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(8),
          Text(
            "Riwayat akan muncul setelah Anda\nmenyelesaikan inspeksi",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }



  // ... [Inside build method, replace _reports.length with _filteredReports.length] ...
  // Wait, I need to replace the whole build or at least the relevant parts.
  // The 'Instruction' asks to replace specific methods. Filters logic is usually outside build.
  
  // Let's redefine _showFilterBottomSheet and _buildFilterOption to handle date.

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return SingleChildScrollView( // Added scroll view to prevent overflow
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     // Handle Bar
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const Gap(20), // ... rest of the code is effectively same, just wrapped
                    Text("Filter Riwayat", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Gap(20),

                    // DATE FILTER
                    const Text("Tanggal", style: TextStyle(fontWeight: FontWeight.w600)),
                    const Gap(8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setStateModal(() {
                            _selectedDate = picked;
                          });
                          // Apply immediately in main state
                          setState(() { _selectedDate = picked; });
                          _applyFilters();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                            const Gap(10),
                            Text(
                              _selectedDate != null 
                                ? DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate!) 
                                : "Pilih Tanggal...",
                              style: TextStyle(color: _selectedDate != null ? Colors.black87 : Colors.grey[500]),
                            ),
                            const Spacer(),
                            if (_selectedDate != null)
                              InkWell(
                                onTap: () {
                                  setStateModal(() { _selectedDate = null; });
                                  setState(() { _selectedDate = null; });
                                  _applyFilters();
                                },
                                child: const Icon(Icons.close, size: 18, color: Colors.grey),
                              )
                          ],
                        ),
                      ),
                    ),

                    const Gap(20),

                    // STATUS FILTER
                    const Text("Status", style: TextStyle(fontWeight: FontWeight.w600)),
                    _buildFilterOption("Semua", _selectedFilterMode == 'Semua', (val) {
                      setStateModal(() => _selectedFilterMode = 'Semua');
                      setState(() { _selectedFilterMode = 'Semua'; });
                      _applyFilters();
                    }),
                    _buildFilterOption("Selesai", _selectedFilterMode == 'Selesai', (val) {
                      setStateModal(() => _selectedFilterMode = 'Selesai');
                      setState(() { _selectedFilterMode = 'Selesai'; });
                      _applyFilters();
                    }),
                    _buildFilterOption("Draf", _selectedFilterMode == 'Draf', (val) {
                      setStateModal(() => _selectedFilterMode = 'Draf');
                      setState(() { _selectedFilterMode = 'Draf'; });
                      _applyFilters();
                    }),
                    const Gap(20),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildFilterOption(String label, bool isSelected, Function(bool) onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? primaryDeep : Colors.grey[400],
      ),
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      onTap: () => onTap(!isSelected),
    );
  }

  // BOTTOM NAVIGATION BAR
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, "Beranda", false, () {
            Navigator.pop(context); // Go back to home
          }),
          
          // FAB Center
          Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const Step1ShipForm(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      var tween = Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.linear));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 150),
                  ),
                );
              },
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: primaryDeep,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: primaryDeep.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))
                  ]
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),

          _buildNavItem(Icons.history, "Histori", true, () {}), // Active!
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF00BFA5) : Colors.grey[400],
              size: 28,
            ),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF00BFA5) : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
