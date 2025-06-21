import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HistoryProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _dataLampau = [];

  List<Map<String, dynamic>> get dataLampau => _dataLampau;

  Future<void> fetchDataLampau() async {
    // Use emulator localhost redirect if on Android
    final host = (!kIsWeb && Platform.isAndroid) ? '10.0.2.2' : 'localhost';
    final url = Uri.parse('http://$host:5000/data_lampau');
    debugPrint('Fetching history from $url');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _dataLampau =
            jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
        debugPrint('Loaded ${_dataLampau.length} history entries');
        notifyListeners();
      } else {
        debugPrint('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }
  }
}
