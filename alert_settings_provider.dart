import 'package:flutter/material.dart';

class AlertSettingsProvider with ChangeNotifier {
  double suhuBatasAtas = 30;
  double suhuBatasBawah = 20;
  double phBatasAtas = 8.5;
  double phBatasBawah = 6.5;
  double doBatasBawah = 3;

  // Riwayat alert disimpan di sini
  final List<String> historyAlerts = [];

  /// Getter untuk akses history dari luar
  List<String> get history => historyAlerts;

  /// Update batas suhu dan tambah entri history
  void updateSuhuBatas(double atas, double bawah) {
    suhuBatasAtas = atas;
    suhuBatasBawah = bawah;
    addHistory('[Kolam Pengaturan] Suhu diubah: atas=$atas, bawah=$bawah');
    notifyListeners();
  }

  /// Update batas pH dan tambah entri history
  void updatePhBatas(double atas, double bawah) {
    phBatasAtas = atas;
    phBatasBawah = bawah;
    addHistory('[Kolam Pengaturan] pH diubah: atas=$atas, bawah=$bawah');
    notifyListeners();
  }

  /// Update batas DO dan tambah entri history
  void updateDoBatas(double bawah) {
    doBatasBawah = bawah;
    addHistory('[Kolam Pengaturan] DO diubah: bawah=$bawah');
    notifyListeners();
  }

  /// Tambah pesan ke history dengan timestamp
  void addHistory(String alert) {
    final timestamp = DateTime.now().toString();
    historyAlerts.insert(0, '$timestamp - $alert');
    notifyListeners();
  }

  /// Bersihkan semua riwayat
  void clearHistory() {
    historyAlerts.clear();
    notifyListeners();
  }
}
