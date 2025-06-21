import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final alertSettings = Provider.of<AlertSettingsProvider>(context);

    final suhuAtasController = TextEditingController(
      text: alertSettings.suhuBatasAtas.toString(),
    );
    final suhuBawahController = TextEditingController(
      text: alertSettings.suhuBatasBawah.toString(),
    );
    final phAtasController = TextEditingController(
      text: alertSettings.phBatasAtas.toString(),
    );
    final phBawahController = TextEditingController(
      text: alertSettings.phBatasBawah.toString(),
    );
    final doBawahController = TextEditingController(
      text: alertSettings.doBatasBawah.toString(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Peringatan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Batas Suhu Air (°C)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: suhuBawahController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Bawah'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: suhuAtasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Atas'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Batas pH Air',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: phBawahController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Bawah'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: phAtasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Atas'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Batas DO Minimal (mg/L)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: doBawahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'DO Minimum'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                alertSettings.updateSuhuBatas(
                  double.tryParse(suhuAtasController.text) ?? 30,
                  double.tryParse(suhuBawahController.text) ?? 20,
                );
                alertSettings.updatePhBatas(
                  double.tryParse(phAtasController.text) ?? 8.5,
                  double.tryParse(phBawahController.text) ?? 6.5,
                );
                alertSettings.updateDoBatas(
                  double.tryParse(doBawahController.text) ?? 3,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pengaturan disimpan!')),
                );
              },
              child: const Text('Simpan Pengaturan'),
            ),
          ],
        ),
      ),
    );
  }
}
