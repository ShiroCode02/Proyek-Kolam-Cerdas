import 'package:flutter/material.dart';

class SensorDataProvider extends ChangeNotifier {
  // Data default untuk backward compatibility
  String suhuAir = '0';
  String phAir = '0';
  String kadarDo = '0';
  String tinggiAir = '0';
  String beratPakan = '0';

  // 🔄 Tambahan: Penyimpanan data per kolam
  final Map<String, Map<String, String>> _dataPerKolam = {};

  // 🔧 Update data berdasarkan kolam
  void updateSensorData(String kolam, Map<String, dynamic> data) {
    _dataPerKolam[kolam] = {
      'suhuAir': data['suhuAir'].toString(),
      'phAir': data['phAir'].toString(),
      'kadarDo': data['do'].toString(),
      'tinggiAir': data['tinggiAir'].toString(),
      'beratPakan': data['beratPakan'].toString(),
    };

    // Sinkronkan ke properti utama juga (opsional, untuk tampilan awal)
    if (kolam == '1') {
      updateAll(
        suhuAir: data['suhuAir'].toString(),
        phAir: data['phAir'].toString(),
        kadarDo: data['do'].toString(),
        tinggiAir: data['tinggiAir'].toString(),
        beratPakan: data['beratPakan'].toString(),
      );
    } else {
      notifyListeners(); // hanya trigger listener
    }
  }

  // 🔍 Ambil data kolam tertentu
  Map<String, String> getSensorData(String kolam) {
    return _dataPerKolam[kolam] ??
        {
          'suhuAir': '-',
          'phAir': '-',
          'kadarDo': '-',
          'tinggiAir': '-',
          'beratPakan': '-',
        };
  }

  // Fungsi lama tetap dipertahankan:
  void updateSuhu(String newSuhu) {
    if (newSuhu != suhuAir) {
      suhuAir = newSuhu;
      notifyListeners();
    }
  }

  void updatePh(String newPh) {
    if (newPh != phAir) {
      phAir = newPh;
      notifyListeners();
    }
  }

  void updateDo(String newDo) {
    if (newDo != kadarDo) {
      kadarDo = newDo;
      notifyListeners();
    }
  }

  void updateTinggiAir(String newTinggi) {
    if (newTinggi != tinggiAir) {
      tinggiAir = newTinggi;
      notifyListeners();
    }
  }

  void updateBeratPakan(String newBerat) {
    if (newBerat != beratPakan) {
      beratPakan = newBerat;
      notifyListeners();
    }
  }

  void updateAll({
    String? suhuAir,
    String? phAir,
    String? kadarDo,
    String? tinggiAir,
    String? beratPakan,
  }) {
    bool hasChanges = false;

    if (suhuAir != null && suhuAir != this.suhuAir) {
      this.suhuAir = suhuAir;
      hasChanges = true;
    }
    if (phAir != null && phAir != this.phAir) {
      this.phAir = phAir;
      hasChanges = true;
    }
    if (kadarDo != null && kadarDo != this.kadarDo) {
      this.kadarDo = kadarDo;
      hasChanges = true;
    }
    if (tinggiAir != null && tinggiAir != this.tinggiAir) {
      this.tinggiAir = tinggiAir;
      hasChanges = true;
    }
    if (beratPakan != null && beratPakan != this.beratPakan) {
      this.beratPakan = beratPakan;
      hasChanges = true;
    }

    if (hasChanges) {
      print(
        "✅ Data updated! suhu=$suhuAir, ph=$phAir, do=$kadarDo, tinggi=$tinggiAir, berat=$beratPakan",
      );
      notifyListeners();
    }
  }
}
