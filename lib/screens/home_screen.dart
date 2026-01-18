import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'step1_ship_form.dart';
import 'history_screen.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // COLORS - matching theme color from main.dart (0xFF005c4b)
  final Color primaryDeep = const Color(0xFF005c4b); // Medical Green (same as theme)
  final Color accentCyan = const Color(0xFF00BFA5);  // Matching accent green
  
  // STATUS KONEKSI
  bool _isOnline = false;
  Timer? _timer;            // Timer koneksi
  int _todayCount = 0;      // Jumlah laporan selesai hari ini

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _loadData(); // Load awal data
    
    // Cek koneksi & data berkala setiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkConnection();
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final count = await StorageService.getTodayCompletedCount();
    if (mounted) {
      setState(() {
        _todayCount = count;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
                                            // Jika di Web, kita asumsikan online dulu atau gunakan logika lain
                                            // karena dart:io InternetAddress tidak support Web.
    if (kIsWeb) {
      setState(() => _isOnline = true);
      return;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (mounted) setState(() => _isOnline = true);
      }
    } on SocketException catch (_) {
      if (mounted) setState(() => _isOnline = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Date & Time
    final String dateString = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(DateTime.now());
    
    // Get status bar height for proper padding
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Set status bar transparent to remove the black fade overlay
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // White icons
      statusBarBrightness: Brightness.dark, // For iOS
    ));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // SCROLLABLE CONTENT - Everything scrolls together
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header Section with Background
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryDeep,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryDeep.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      // Pastikan tidak negatif agar tidak crash (max(0, ...))
                      top: (statusBarHeight - 30) < 0 ? 0 : (statusBarHeight - 30),
                      left: 24,
                      right: 24,
                      bottom: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar (Logo & Profile)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo Kemenkes only (no background, no text)
                            Image.asset(
                              'assets/images/logo_kemenkes.png',
                              width: 168,
                              height: 168,
                              fit: BoxFit.contain,
                            ),
                            Container(
                              width: 45, height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white30, width: 2),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => _showComingSoon(context, "Pengaturan"),
                                  child: const Icon(Icons.settings_outlined, color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),

                        // Welcome Text & Date - moved closer to logo
                        Transform.translate(
                          offset: const Offset(0, -40), // Move up closer to logo
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateString,
                                style: GoogleFonts.poppins(
                                  color: Colors.teal.shade100,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              const Gap(4),
                              const DigitalClockWidget(), // Gunakan widget terpisah agar performa lancar
                            ],
                          ),
                        ),
                        const Gap(8), // Tambah jarak sedikit
                        Transform.translate(
                          offset: const Offset(0, -40), // Move up closer
                          child: Text(
                            "Selamat Bertugas,\nPetugas Karantina", 
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              height: 1.2,
                            ),
                          ),
                        ),

                        const Gap(10),

                        // HERO STATS CARD
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                _showComingSoon(context, "Detail Statistik");
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Inspeksi Hari Ini",
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _isOnline ? const Color(0xFFE0F7F4) : const Color(0xFFFFEBEE),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 8, height: 8,
                                                decoration: BoxDecoration(
                                                  color: _isOnline ? const Color(0xFF00CFA2) : const Color(0xFFD32F2F), 
                                                  shape: BoxShape.circle
                                                ),
                                              ),
                                              const Gap(6),
                                              Text(
                                                _isOnline ? "ONLINE" : "OFFLINE",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: _isOnline ? const Color(0xFF00796B) : const Color(0xFFC62828),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(15),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "$_todayCount", // Real Data
                                          style: GoogleFonts.poppins(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2D3142),
                                          ),
                                        ),
                                        const Gap(12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Kapal Selesai",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[800],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                "Belum ada data",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 42, height: 42,
                                          decoration: BoxDecoration(
                                            color: primaryDeep,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.arrow_forward, color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content Section (below the curved header)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(25),

                      // Grid Menu Title
                      Text(
                        "Layanan Formulir",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3142),
                        ),
                      ),
                      const Gap(16),
                      
                      // Menu Row 1
                      Row(
                        children: [
                          Expanded(
                            child: _buildMenuCard(
                              icon: Icons.anchor,
                              color: const Color(0xFFE0F7FA), // Cyan lighten
                              iconColor: const Color(0xFF0097A7), // Cyan darken
                              title: "Sanitasi Kapal",
                              subtitle: "Formulir PHQC",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const Step1ShipForm(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      // Slide dari KIRI (-1.0) ke kanan saat masuk
                                      // Slide ke KIRI (-1.0) saat keluar
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
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: _buildMenuCard(
                              icon: Icons.inventory_2_outlined,
                              color: const Color(0xFFFFF3E0), // Orange lighten
                              iconColor: const Color(0xFFFF9800), // Orange
                              title: "Fomite / Barang",
                              subtitle: "Cek Kargo",
                              onTap: () => _showComingSoon(context, "Inspeksi Fomite"),
                            ),
                          ),
                        ],
                      ),
                      
                      const Gap(16),
                      
                      // Menu Row 2
                      Row(
                        children: [
                          Expanded(
                            child: _buildMenuCard(
                              icon: Icons.restaurant,
                              color: const Color(0xFFF3E5F5), // Purple lighten
                              iconColor: const Color(0xFF9C27B0), // Purple
                              title: "Food Safety",
                              subtitle: "Hygiene Makanan",
                              onTap: () => _showComingSoon(context, "Food Safety"),
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: _buildMenuCard(
                              icon: Icons.description_outlined,
                              color: const Color(0xFFE8EAF6), // Indigo lighten
                              iconColor: const Color(0xFF3F51B5), // Indigo
                              title: "Barang Medis",
                              subtitle: "Kesehatan",
                              onTap: () => _showComingSoon(context, "Barang Medis"),
                            ),
                          ),
                        ],
                      ),

                      const Gap(120), // Extra space for Floating Bottom Nav
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // BOTTOM NAVIGATION (Floating) - Stays fixed
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

  Widget _buildMenuCard({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          splashColor: color.withOpacity(0.5),
          highlightColor: color.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const Spacer(),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3142),
                    height: 1.2,
                  ),
                ),
                const Gap(4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          _buildNavItem(Icons.home_filled, "Beranda", true, () {}),
          
          // FAB Center (Actual Clickable)
          Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                // Shortcut to main feature
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
                    transitionDuration: const Duration(milliseconds: 300),
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

          _buildNavItem(Icons.history, "Histori", false, () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const HistoryScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }),
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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Fitur '$feature' akan segera hadir!"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.grey[800],
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// Optimized Digital Clock Widget to prevent full screen rebuilds
class DigitalClockWidget extends StatefulWidget {
  const DigitalClockWidget({super.key});

  @override
  State<DigitalClockWidget> createState() => _DigitalClockWidgetState();
}

class _DigitalClockWidgetState extends State<DigitalClockWidget> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format: HH:mm:ss WITA
    final timeString = DateFormat('HH:mm:ss', 'id_ID').format(_now) + " WITA";
    
    return Text(
      timeString,
      style: GoogleFonts.poppins(
        color: Colors.teal.shade100,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    );
  }
}
