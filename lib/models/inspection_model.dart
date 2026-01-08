import 'dart:typed_data';

class InspectionModel {
  // Form 1: Data Kapal
  String? shipName;
  String? flag;
  String? grossTonnage;
  DateTime? arrivalDate;
  String? captainName;
  String? lastPort;
  String? nextPort;

  // Form 2: Sanitasi (Checklist)
  bool kitchenClean;
  bool pantryClean;
  bool foodStorageClean;
  bool wasteManagementGood;
  bool vectorControlGood; // Tikus/Serangga
  String? sanitationNote;

  // Form 3: Kesehatan (Data ABK/Penumpang)
  int crewCount;
  int passengerCount;
  int sickCount;
  List<String> symptoms; // Demam, Batuk, dll
  
  // Signatures
  Uint8List? captainSignature;
  Uint8List? officerSignature;
  String? officerName;

  InspectionModel({
    this.shipName,
    this.flag,
    this.grossTonnage,
    this.arrivalDate,
    this.captainName,
    this.lastPort,
    this.nextPort,
    this.kitchenClean = false,
    this.pantryClean = false,
    this.foodStorageClean = false,
    this.wasteManagementGood = false,
    this.vectorControlGood = false,
    this.sanitationNote,
    this.crewCount = 0,
    this.passengerCount = 0,
    this.sickCount = 0,
    this.symptoms = const [],
    this.captainSignature,
    this.officerSignature,
    this.officerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'shipName': shipName,
      'flag': flag,
      'grossTonnage': grossTonnage,
      'arrivalDate': arrivalDate?.toIso8601String(),
      'kitchenClean': kitchenClean,
      // ... add others if needed for local storage
    };
  }
}
