import 'dart:typed_data';

class InspectionModel {
  // --- I. DATA UMUM ---
  String? shipName;
  String? flag;
  String? grossTonnage; // Besar Kapal
  String? lastPort; // Datang Dari
  DateTime? arrivalDate; // Tanggal Kedatangan
  String? nextPort; // Tujuan
  DateTime? departureDate; // Tanggal Tujuan (Estimasi)
  String? captainName;
  String? imoNumber;
  String? dockLocation; // Lokasi Sandar
  int? crewCount;
  int? passengerCount;
  int? unregisteredPassengers;
  String? agency; // Keagenan

  // --- II. DATA KHUSUS ---
  // A. Pelanggaran Karantina
  String? quarantineSignal; // Pasang / Tidak Pasang
  String? shipActivity; // Bongkar Muat / Naik Turun / Tidak Ada

  // B. Dokumen Kesehatan Kapal (Simple structure for now)
  // MDH
  String? mdhStatus; // Sehat / Tidak Sehat / Tidak Ada
  String? mdhNote;

  // SSCEC / SSCC
  String? sscecPlace;
  DateTime? sscecDate;
  DateTime? sscecExpiry;
  String? sscecStatus; // Berlaku / Tidak Berlaku / Tidak Ada
  String? sscecNote;

  // Crew List
  String? crewListStatus; // Ada / Tidak Ada
  String? crewListNote;

  // Buku Kuning (ICV)
  String? icvStatus; // Sesuai / Tidak Sesuai / Tidak Ada
  String? icvNote;

  // P3K Kapal
  String? p3kPlace;
  DateTime? p3kDate;
  DateTime? p3kExpiry;
  String? p3kStatus; // Berlaku / Tidak Berlaku / Tidak Ada
  String? p3kNote;

  // Buku Kesehatan Kapal
  String? healthBookPlace;
  DateTime? healthBookDate;
  String? healthBookStatus; // Sesuai / Tidak Sesuai / Tidak Ada
  String? healthBookNote;

  // Voyage Memo
  String? voyageMemoStatus; // Ada / Tidak Ada
  String? voyageMemoNote;

  // Ship Particular
  String? shipParticularStatus; // Ada / Tidak Ada
  String? shipParticularNote;

  // Manifest Cargo
  String? manifestCargoStatus; // Ada / Tidak Ada
  String? manifestCargoNote;

  // C. Faktor Risiko PHEIC
  bool sanitationRisk;
  String? sanitationRiskDetail;
  bool healthRisk;
  String? healthRiskDetail;

  // --- III. KESIMPULAN ---
  bool isPHEICFree; // Kapal Bebas PHEIC vs Tidak Bebas

  // --- IV. REKOMENDASI ---
  // A. Kapal dalam Karantina
  String? quarantineRecommendation; // Free Pratique / Syarat / Tidak
  DateTime? quarantineRecommendationDate; // Gabungan Tanggal & Jam

  // B. Kapal dalam Negeri
  String? sibNumber; // Jika ada
  bool sibGiven; // Diberikan / Tidak
  DateTime? sibDate; 

  // --- OLDER FIELDS (FORM 2 & 4 - KEEPING FOR NOW) ---
  bool kitchenClean;
  bool pantryClean;
  bool foodStorageClean;
  bool wasteManagementGood;
  bool vectorControlGood; 
  String? sanitationNote;
  
  // Health
  int sickCount;
  List<String> symptoms;
  
  // Signatures
  Uint8List? captainSignature;
  Uint8List? officerSignature;
  String? officerName;

  InspectionModel({
    this.shipName,
    this.flag,
    this.grossTonnage,
    this.lastPort,
    this.arrivalDate,
    this.nextPort,
    this.departureDate,
    this.captainName,
    this.imoNumber,
    this.dockLocation,
    this.crewCount,
    this.passengerCount,
    this.unregisteredPassengers,
    this.agency,
    this.quarantineSignal,
    this.shipActivity,
    this.mdhStatus,
    this.mdhNote,
    this.sscecPlace,
    this.sscecDate,
    this.sscecExpiry,
    this.sscecStatus,
    this.sscecNote,
    this.crewListStatus,
    this.crewListNote,
    this.icvStatus,
    this.icvNote,
    this.p3kPlace,
    this.p3kDate,
    this.p3kExpiry,
    this.p3kStatus,
    this.p3kNote,
    this.healthBookPlace,
    this.healthBookDate,
    this.healthBookStatus,
    this.healthBookNote,
    this.voyageMemoStatus,
    this.voyageMemoNote,
    this.shipParticularStatus,
    this.shipParticularNote,
    this.manifestCargoStatus,
    this.manifestCargoNote,
    this.sanitationRisk = false,
    this.sanitationRiskDetail,
    this.healthRisk = false,
    this.healthRiskDetail,
    this.isPHEICFree = true,
    this.quarantineRecommendation,
    this.quarantineRecommendationDate,
    this.sibNumber,
    this.sibGiven = false,
    this.sibDate,
    this.kitchenClean = false,
    this.pantryClean = false,
    this.foodStorageClean = false,
    this.wasteManagementGood = false,
    this.vectorControlGood = false,
    this.sanitationNote,
    this.sickCount = 0,
    this.symptoms = const [],
    this.captainSignature,
    this.officerSignature,
    this.officerName,
  });
}
