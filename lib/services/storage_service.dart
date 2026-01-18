import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyReports = 'reports_data';

  // Simpan Laporan Baru (Data Lengkap)
  static Future<void> saveReport(Map<String, dynamic> reportData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil data lama
    final List<String> savedReports = prefs.getStringList(_keyReports) ?? [];

    // Tambahkan ID dan Timestamp jika belum ada
    if (!reportData.containsKey('id')) {
      reportData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    // Pastikan tanggal ada
    if (!reportData.containsKey('date')) {
      reportData['date'] = DateTime.now().toIso8601String();
    }

    // Tambahkan ke list (paling atas)
    savedReports.insert(0, jsonEncode(reportData));

    // Simpan kembali
    await prefs.setStringList(_keyReports, savedReports);
  }

  // Ambil Semua Laporan
  static Future<List<Map<String, dynamic>>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedReports = prefs.getStringList(_keyReports) ?? [];

    return savedReports.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  // Hitung Laporan Selesai Hari Ini
  static Future<int> getTodayCompletedCount() async {
    final reports = await getReports();
    final now = DateTime.now();
    
    int count = 0;
    for (var report in reports) {
      String? dateStr = report['date'];
      if (dateStr == null) continue; // Skip corrupted data
      
      final reportDate = DateTime.tryParse(dateStr);
      if (reportDate == null) continue;

      final bool isToday = reportDate.year == now.year && 
                           reportDate.month == now.month && 
                           reportDate.day == now.day;
      
      if (isToday && report['status'] == 'SELESAI') {
        count++;
      }
    }
    return count;
  }
}
