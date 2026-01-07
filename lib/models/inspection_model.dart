import 'dart:typed_data';

/// Data untuk setiap area pemeriksaan sanitasi
class SanitationAreaData {
  bool qualify; // Memenuhi Syarat
  bool unqualify; // Tidak Memenuhi Syarat
  bool visibleSigns; // Tampak Tanda-tanda (Vektor)
  bool noSigns; // Tidak Tampak Tanda-tanda (Vektor)

  SanitationAreaData({
    this.qualify = false,
    this.unqualify = false,
    this.visibleSigns = false,
    this.noSigns = false,
  });

  SanitationAreaData copyWith({
    bool? qualify,
    bool? unqualify,
    bool? visibleSigns,
    bool? noSigns,
  }) {
    return SanitationAreaData(
      qualify: qualify ?? this.qualify,
      unqualify: unqualify ?? this.unqualify,
      visibleSigns: visibleSigns ?? this.visibleSigns,
      noSigns: noSigns ?? this.noSigns,
    );
  }
}

/// Daftar ID lokasi pemeriksaan sanitasi
class SanitationAreaKeys {
  static const String galley = 'galley'; // Dapur
  static const String pantry = 'pantry'; // Ruang Rakit Makanan
  static const String store = 'store'; // Gudang
  static const String cargo = 'cargo'; // Palka
  static const String quarterCrew = 'quarter_crew'; // Ruang Tidur ABK
  static const String quarterOfficer = 'quarter_officer'; // Ruang Tidur Perwira
  static const String quarterPassenger =
      'quarter_passenger'; // Ruang Tidur Penumpang
  static const String deck = 'deck'; // Geladak
  static const String potableWater = 'potable_water'; // Air Minum
  static const String sewage = 'sewage'; // Limbah Cair
  static const String waterBallast = 'water_ballast'; // Air Balast
  static const String medicalWaste = 'medical_waste'; // Limbah Medis/Padat
  static const String standingWater = 'standing_water'; // Air Tergenang
  static const String engineRoom = 'engine_room'; // Ruang Mesin
  static const String medicalFacilities =
      'medical_facilities'; // Fasilitas Medik
  static const String otherArea = 'other_area'; // Area Lainnya

  static List<String> get allKeys => [
    galley,
    pantry,
    store,
    cargo,
    quarterCrew,
    quarterOfficer,
    quarterPassenger,
    deck,
    potableWater,
    sewage,
    waterBallast,
    medicalWaste,
    standingWater,
    engineRoom,
    medicalFacilities,
    otherArea,
  ];

  static String getLabel(String key) {
    switch (key) {
      case galley:
        return 'Dapur (Galley)';
      case pantry:
        return 'Ruang Rakit Makanan (Pantry)';
      case store:
        return 'Gudang (Store)';
      case cargo:
        return 'Palka (Cargo)';
      case quarterCrew:
        return 'Ruang Tidur - ABK (Crew)';
      case quarterOfficer:
        return 'Ruang Tidur - Perwira (Officer)';
      case quarterPassenger:
        return 'Ruang Tidur - Penumpang (Passenger)';
      case deck:
        return 'Geladak (Deck)';
      case potableWater:
        return 'Air Minum (Potable Water)';
      case sewage:
        return 'Limbah Cair (Sewage)';
      case waterBallast:
        return 'Air Balast (Water Ballast)';
      case medicalWaste:
        return 'Limbah Medis/Padat (Medical/Solid Waste)';
      case standingWater:
        return 'Air Tergenang/Permukaan (Standing Water)';
      case engineRoom:
        return 'Ruang Mesin (Engine Room)';
      case medicalFacilities:
        return 'Fasilitas Medik (Medical Facilities)';
      case otherArea:
        return 'Area Lainnya (Other Area Specified)';
      default:
        return key;
    }
  }
}

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

  // --- SANITASI KAPAL (16 Area Pemeriksaan) ---
  Map<String, SanitationAreaData> sanitationAreas;
  String? sanitationNote;
  String? otherAreaDescription; // Deskripsi untuk "Area Lainnya"

  // --- OLDER FIELDS (FORM 2 & 4 - KEEPING FOR NOW) ---
  bool kitchenClean;
  bool pantryClean;
  bool foodStorageClean;
  bool wasteManagementGood;
  bool vectorControlGood;

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
    Map<String, SanitationAreaData>? sanitationAreas,
    this.sanitationNote,
    this.otherAreaDescription,
    this.kitchenClean = false,
    this.pantryClean = false,
    this.foodStorageClean = false,
    this.wasteManagementGood = false,
    this.vectorControlGood = false,
    this.sickCount = 0,
    this.symptoms = const [],
    this.captainSignature,
    this.officerSignature,
    this.officerName,
  }) : sanitationAreas = sanitationAreas ?? _initSanitationAreas();

  static Map<String, SanitationAreaData> _initSanitationAreas() {
    return {
      for (var key in SanitationAreaKeys.allKeys) key: SanitationAreaData(),
    };
  }
}
