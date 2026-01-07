import 'package:flutter/material.dart';
import '../models/inspection_model.dart';
import 'dart:typed_data';

class InspectionProvider with ChangeNotifier {
  InspectionModel _data = InspectionModel(
    arrivalDate: DateTime.now(),
    quarantineRecommendationDate: DateTime.now(),
  );

  InspectionModel get data => _data;

  // Generic update for "Data Umum"
  void updateGeneralData({
    String? shipName,
    String? flag,
    String? grossTonnage,
    String? lastPort,
    DateTime? arrivalDate,
    String? nextPort,
    DateTime? departureDate,
    String? captainName,
    String? imoNumber,
    String? dockLocation,
    int? crewCount,
    int? passengerCount,
    int? unregisteredPassengers,
    String? agency,
  }) {
    if (shipName != null) _data.shipName = shipName;
    if (flag != null) _data.flag = flag;
    if (grossTonnage != null) _data.grossTonnage = grossTonnage;
    if (lastPort != null) _data.lastPort = lastPort;
    if (arrivalDate != null) _data.arrivalDate = arrivalDate;
    if (nextPort != null) _data.nextPort = nextPort;
    if (departureDate != null) _data.departureDate = departureDate;
    if (captainName != null) _data.captainName = captainName;
    if (imoNumber != null) _data.imoNumber = imoNumber;
    if (dockLocation != null) _data.dockLocation = dockLocation;
    if (crewCount != null) _data.crewCount = crewCount;
    if (passengerCount != null) _data.passengerCount = passengerCount;
    if (unregisteredPassengers != null)
      _data.unregisteredPassengers = unregisteredPassengers;
    if (agency != null) _data.agency = agency;
    notifyListeners();
  }

  // Generic update for "Data Khusus" (Violations & Documents)
  // To avoid a massive single function, we can group them or use direct assignment if logic is simple.
  // For provider pattern, explicit setters are safer.

  void updateQuarantineViolations({String? signal, String? activity}) {
    if (signal != null) _data.quarantineSignal = signal;
    if (activity != null) _data.shipActivity = activity;
    notifyListeners();
  }

  void updateDocumentMDH({String? status, String? note}) {
    if (status != null) _data.mdhStatus = status;
    if (note != null) _data.mdhNote = note;
    notifyListeners();
  }

  void updateDocumentSSCEC({
    String? place,
    DateTime? date,
    DateTime? expiry,
    String? status,
    String? note,
  }) {
    if (place != null) _data.sscecPlace = place;
    if (date != null) _data.sscecDate = date;
    if (expiry != null) _data.sscecExpiry = expiry;
    if (status != null) _data.sscecStatus = status;
    if (note != null) _data.sscecNote = note;
    notifyListeners();
  }

  void updateDocumentCrewList({String? status, String? note}) {
    _data.crewListStatus = status ?? _data.crewListStatus;
    _data.crewListNote = note ?? _data.crewListNote;
    notifyListeners();
  }

  void updateDocumentICV({String? status, String? note}) {
    _data.icvStatus = status ?? _data.icvStatus;
    _data.icvNote = note ?? _data.icvNote;
    notifyListeners();
  }

  void updateDocumentP3K({
    String? place,
    DateTime? date,
    DateTime? expiry,
    String? status,
    String? note,
  }) {
    if (place != null) _data.p3kPlace = place;
    if (date != null) _data.p3kDate = date;
    if (expiry != null) _data.p3kExpiry = expiry;
    if (status != null) _data.p3kStatus = status;
    if (note != null) _data.p3kNote = note;
    notifyListeners();
  }

  void updateDocumentHealthBook({
    String? place,
    DateTime? date,
    String? status,
    String? note,
  }) {
    if (place != null) _data.healthBookPlace = place;
    if (date != null) _data.healthBookDate = date;
    if (status != null) _data.healthBookStatus = status;
    if (note != null) _data.healthBookNote = note;
    notifyListeners();
  }

  void updateOtherDocuments({
    String? voyageStatus,
    String? voyageNote,
    String? shipPartStatus,
    String? shipPartNote,
    String? manifestStatus,
    String? manifestNote,
  }) {
    if (voyageStatus != null) _data.voyageMemoStatus = voyageStatus;
    if (voyageNote != null) _data.voyageMemoNote = voyageNote;
    if (shipPartStatus != null) _data.shipParticularStatus = shipPartStatus;
    if (shipPartNote != null) _data.shipParticularNote = shipPartNote;
    if (manifestStatus != null) _data.manifestCargoStatus = manifestStatus;
    if (manifestNote != null) _data.manifestCargoNote = manifestNote;
    notifyListeners();
  }

  void updateRisks({
    bool? sanitation,
    String? sDetail,
    bool? health,
    String? hDetail,
  }) {
    if (sanitation != null) _data.sanitationRisk = sanitation;
    if (sDetail != null) _data.sanitationRiskDetail = sDetail;
    if (health != null) _data.healthRisk = health;
    if (hDetail != null) _data.healthRiskDetail = hDetail;
    notifyListeners();
  }

  void updateConclusion({bool? isPHEICFree}) {
    if (isPHEICFree != null) _data.isPHEICFree = isPHEICFree;
    notifyListeners();
  }

  void updateRecommendation({
    String? qRec,
    DateTime? qDate,
    String? sibNum,
    bool? sibGiven,
    DateTime? sibDate,
  }) {
    if (qRec != null) _data.quarantineRecommendation = qRec;
    if (qDate != null) _data.quarantineRecommendationDate = qDate;
    if (sibNum != null) _data.sibNumber = sibNum;
    if (sibGiven != null) _data.sibGiven = sibGiven;
    if (sibDate != null) _data.sibDate = sibDate;
    notifyListeners();
  }

  // --- OLD METHODS (Keep for ease, but map to new model) ---

  void updateSanitationData({
    bool? kitchenClean,
    bool? pantryClean,
    bool? foodStorageClean,
    bool? wasteManagementGood,
    bool? vectorControlGood,
    String? note,
  }) {
    _data.kitchenClean = kitchenClean ?? _data.kitchenClean;
    _data.pantryClean = pantryClean ?? _data.pantryClean;
    _data.foodStorageClean = foodStorageClean ?? _data.foodStorageClean;
    _data.wasteManagementGood =
        wasteManagementGood ?? _data.wasteManagementGood;
    _data.vectorControlGood = vectorControlGood ?? _data.vectorControlGood;
    _data.sanitationNote = note ?? _data.sanitationNote;
    notifyListeners();
  }

  // --- SANITATION AREA METHODS (16 Areas) ---

  void updateSanitationArea(
    String areaKey, {
    bool? qualify,
    bool? unqualify,
    bool? visibleSigns,
    bool? noSigns,
  }) {
    final area = _data.sanitationAreas[areaKey];
    if (area != null) {
      _data.sanitationAreas[areaKey] = area.copyWith(
        qualify: qualify,
        unqualify: unqualify,
        visibleSigns: visibleSigns,
        noSigns: noSigns,
      );
      notifyListeners();
    }
  }

  void updateSanitationNote(String? note) {
    _data.sanitationNote = note;
    notifyListeners();
  }

  void updateOtherAreaDescription(String? description) {
    _data.otherAreaDescription = description;
    notifyListeners();
  }

  SanitationAreaData? getSanitationArea(String areaKey) {
    return _data.sanitationAreas[areaKey];
  }

  void updateHealthData({
    int? crewCount,
    int? passengerCount,
    int? sickCount,
    List<String>? symptoms,
  }) {
    // If crew/passenger are updated here, sync them back to general data
    if (crewCount != null) _data.crewCount = crewCount;
    if (passengerCount != null) _data.passengerCount = passengerCount;

    _data.sickCount = sickCount ?? _data.sickCount;
    _data.symptoms = symptoms ?? _data.symptoms;
    notifyListeners();
  }

  void setCaptainSignature(Uint8List? signature) {
    _data.captainSignature = signature;
    notifyListeners();
  }

  void setOfficerSignature(Uint8List? signature) {
    _data.officerSignature = signature;
    notifyListeners();
  }

  void setOfficerName(String name) {
    _data.officerName = name;
    notifyListeners();
  }
}
