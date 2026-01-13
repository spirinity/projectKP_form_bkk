import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inspection_model.dart';

class SheetService {
  // Ganti URL ini dengan URL Web App Anda setelah deploy
  static const String _webAppUrl = '';

  static Future<bool> submitInspection(InspectionModel data) async {
    try {
      final Map<String, dynamic> jsonPayload = {
        // Data Umum
        'shipName': data.shipName ?? '',
        'flag': data.flag ?? '',
        'grossTonnage': data.grossTonnage ?? '',
        'imoNumber': data.imoNumber ?? '',
        'captainName': data.captainName ?? '',
        'agency': data.agency ?? '',
        
        // Perjalanan
        'lastPort': data.lastPort ?? '',
        'nextPort': data.nextPort ?? '',
        'arrivalDate': data.arrivalDate?.toIso8601String() ?? '',
        
        // Data Khusus (Checklists)
        'mdhStatus': data.mdhStatus ?? '',
        'sscecStatus': data.sscecStatus ?? '',
        'crewListStatus': data.crewListStatus ?? '',
        
        // Kesimpulan
        'isPHEICFree': data.isPHEICFree.toString(),
        'quarantineRecommendation': data.quarantineRecommendation ?? '',
      };

      final response = await http.post(
        Uri.parse(_webAppUrl),
        body: jsonEncode(jsonPayload),
      );

      if (response.statusCode == 302 || response.statusCode == 200) {
        // 302 sering terjadi pada redirect Google Scripts, biasanya sukses
        return true;
      } else {
        print('Sheet Service Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Sheet Service Exception: $e');
      return false;
    }
  }
}
