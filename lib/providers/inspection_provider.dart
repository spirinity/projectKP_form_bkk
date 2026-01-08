import 'package:flutter/material.dart';
import '../models/inspection_model.dart';
import 'dart:typed_data';

class InspectionProvider with ChangeNotifier {
  InspectionModel _data = InspectionModel(
    arrivalDate: DateTime.now(),
  );

  InspectionModel get data => _data;

  void updateShipData({
    String? shipName,
    String? flag,
    String? grossTonnage,
    DateTime? arrivalDate,
    String? captainName,
    String? lastPort,
    String? nextPort,
  }) {
    _data.shipName = shipName ?? _data.shipName;
    _data.flag = flag ?? _data.flag;
    _data.grossTonnage = grossTonnage ?? _data.grossTonnage;
    _data.arrivalDate = arrivalDate ?? _data.arrivalDate;
    _data.captainName = captainName ?? _data.captainName;
    _data.lastPort = lastPort ?? _data.lastPort;
    _data.nextPort = nextPort ?? _data.nextPort;
    notifyListeners();
  }

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
    _data.wasteManagementGood = wasteManagementGood ?? _data.wasteManagementGood;
    _data.vectorControlGood = vectorControlGood ?? _data.vectorControlGood;
    _data.sanitationNote = note ?? _data.sanitationNote;
    notifyListeners();
  }

  void updateHealthData({
    int? crewCount,
    int? passengerCount,
    int? sickCount,
    List<String>? symptoms,
  }) {
    _data.crewCount = crewCount ?? _data.crewCount;
    _data.passengerCount = passengerCount ?? _data.passengerCount;
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
