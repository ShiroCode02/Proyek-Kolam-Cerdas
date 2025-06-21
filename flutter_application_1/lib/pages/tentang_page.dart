import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';

class TentangPage extends StatefulWidget {
  const TentangPage({super.key});

  @override
  State<TentangPage> createState() => _TentangPageState();
}

class _TentangPageState extends State<TentangPage>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> infoItems = [
    {
      'icon': Icons.info_outline,
      'title': 'Tentang Aplikasi',
      'content':
          'Aplikasi ini merupakan sistem monitoring kualitas air kolam yang menampilkan data sensor secara real-time, '
          'meliputi suhu air, kadar DO, pH, berat pakan, dan tinggi air. Data dikirim via MQTT ke server cloud.',
    },
    {
      'icon': Icons.settings_input_antenna,
      'title': 'Teknologi yang Digunakan',
      'content':
          '• Flutter\n• MQTT Protocol\n• Firebase / Cloud Server\n• Sensor IoT (suhu, DO, pH, dll)\n• ESP32',
    },
    {
      'icon': Icons.lightbulb_outline,
      'title': 'Fitur Utama',
      'content':
          '• Monitoring kualitas air real-time\n• Antarmuka responsif\n• Visualisasi data\n• Integrasi IoT dan cloud',
    },
    {
      'icon': Icons.contact_mail_outlined,
      'title': 'Kontak Tim',
      'content':
          'Kelompok 6\nYoga Saputra \nRupian \nPeres Mambrisauw\nUTDI, 2025',
    },
  ];

  void showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                child: const Text('Tutup'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang"),
        backgroundColor: isDark ? Colors.orange[900] : Colors.orangeAccent,
        centerTitle: true,
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Colors.orangeAccent,
            spawnOpacity: 0.4,
            opacityChangeRate: 0.2,
            minOpacity: 0.1,
            maxOpacity: 0.5,
            spawnMinSpeed: 30.0,
            spawnMaxSpeed: 80.0,
            spawnMinRadius: 4.0,
            spawnMaxRadius: 10.0,
            particleCount: 45,
          ),
        ),
        vsync: this,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Tentang Aplikasi',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: infoItems.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = infoItems[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: isDark ? Colors.white10 : Colors.white,
                        child: ListTile(
                          leading: Icon(item['icon'], color: Colors.orange),
                          title: Text(
                            item['title'],
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap:
                              () => showInfoDialog(
                                item['title'],
                                item['content'],
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
