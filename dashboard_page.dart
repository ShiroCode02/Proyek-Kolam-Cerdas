import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:provider/provider.dart';
import 'history_page.dart';
import '../providers/sensor_data_provider.dart';
import '../providers/mqtt_service.dart';
import '../providers/alert_settings_provider.dart';
import 'package:flutter_application_1/pages/settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  bool isGridView = false;
  int selectedKolam = 1;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final mqtt = Provider.of<MQTTService>(context, listen: false);
    mqtt.setContext(context);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor =
        isDark ? Colors.teal.withOpacity(0.9) : Colors.teal[300];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentPage == 1
              ? 'Riwayat Kolam $selectedKolam'
              : 'Dashboard Kolam $selectedKolam',
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        backgroundColor: appBarColor,
        elevation: 0,
        actions: [
          if (_currentPage == 0)
            IconButton(
              icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
              tooltip: 'Ubah Tampilan',
              onPressed: () {
                setState(() {
                  isGridView = !isGridView;
                });
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: isDark ? Colors.grey[900] : Colors.teal[50],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: isDark ? Colors.teal[700] : Colors.teal,
                ),
                child: const Text(
                  '🌊 Menu Navigasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.pool),
                title: const Text('Pilih Kolam'),
                subtitle: Text('Kolam $selectedKolam'),
                onTap: () async {
                  final kolam = await showDialog<int>(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: const Text('Pilih Kolam'),
                        children: List.generate(5, (index) {
                          final kolamNumber = index + 1;
                          return SimpleDialogOption(
                            child: Text('Kolam $kolamNumber'),
                            onPressed:
                                () => Navigator.pop(context, kolamNumber),
                          );
                        }),
                      );
                    },
                  );
                  if (kolam != null) {
                    setState(() {
                      selectedKolam = kolam;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Kalibrasi / Pengaturan'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          // Halaman Dashboard (data live)
          AnimatedBackground(
            behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
                baseColor: Colors.teal,
                spawnOpacity: 0.5,
                opacityChangeRate: 0.25,
                minOpacity: 0.1,
                maxOpacity: 0.4,
                spawnMinSpeed: 20.0,
                spawnMaxSpeed: 70.0,
                spawnMinRadius: 4.0,
                spawnMaxRadius: 8.0,
                particleCount: 40,
              ),
            ),
            vsync: this,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Consumer<SensorDataProvider>(
                        builder: (context, sensorData, _) {
                          final sensorDataMap = sensorData.getSensorData(
                            selectedKolam.toString(),
                          );

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            String? alertMessage;

                            double suhu =
                                double.tryParse(
                                  sensorDataMap['suhuAir'] ?? '0',
                                ) ??
                                0;
                            double ph =
                                double.tryParse(
                                  sensorDataMap['phAir'] ?? '0',
                                ) ??
                                0;
                            double doAir =
                                double.tryParse(
                                  sensorDataMap['kadarDo'] ?? '0',
                                ) ??
                                0;

                            final alertSettings =
                                Provider.of<AlertSettingsProvider>(
                                  context,
                                  listen: false,
                                );

                            if (suhu > alertSettings.suhuBatasAtas ||
                                suhu < alertSettings.suhuBatasBawah) {
                              alertMessage = '🚨 Suhu air keluar batas aman!';
                            } else if (ph > alertSettings.phBatasAtas ||
                                ph < alertSettings.phBatasBawah) {
                              alertMessage = '🚨 pH air keluar batas ideal!';
                            } else if (doAir < alertSettings.doBatasBawah) {
                              alertMessage = '🚨 Kadar DO terlalu rendah!';
                            }

                            if (alertMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(alertMessage),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              alertSettings.addHistory(alertMessage);
                            }
                          });

                          return isGridView
                              ? GridView.count(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                children: _buildSensorCards(sensorDataMap),
                              )
                              : ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    _buildSensorCards(sensorDataMap).length,
                                separatorBuilder:
                                    (context, index) =>
                                        const SizedBox(height: 16),
                                itemBuilder:
                                    (context, index) =>
                                        _buildSensorCards(sensorDataMap)[index],
                              );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Halaman History (riwayat)
          HistoryPage(selectedKolam: selectedKolam),
        ],
      ),
    );
  }

  List<Widget> _buildSensorCards(Map<String, String> sensorDataMap) {
    return [
      SensorCard(title: 'Suhu Air', value: sensorDataMap['suhuAir'] ?? '-'),
      SensorCard(title: 'Kadar DO', value: sensorDataMap['kadarDo'] ?? '-'),
      SensorCard(title: 'pH Air', value: sensorDataMap['phAir'] ?? '-'),
      SensorCard(
        title: 'Berat Pakan',
        value: sensorDataMap['beratPakan'] ?? '-',
      ),
      SensorCard(title: 'Tinggi Air', value: sensorDataMap['tinggiAir'] ?? '-'),
    ];
  }
}

class SensorCard extends StatelessWidget {
  final String title;
  final String value;

  const SensorCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors:
              isDark
                  ? [
                    Colors.teal.withOpacity(0.25),
                    Colors.blue.withOpacity(0.25),
                  ]
                  : [
                    Colors.tealAccent.withOpacity(0.4),
                    Colors.cyan.withOpacity(0.3),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
