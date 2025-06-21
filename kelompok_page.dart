import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';

class KelompokPage extends StatefulWidget {
  const KelompokPage({super.key});

  @override
  State<KelompokPage> createState() => _KelompokPageState();
}

class _KelompokPageState extends State<KelompokPage>
    with TickerProviderStateMixin {
  final List<Map<String, String>> anggotaKelompok = [
    {'nama': 'Yoga Saputra', 'nim': '225510012'},
    {'nama': 'Rupian', 'nim': '225510011'},
    {'nama': 'Peres Mambrisauw', 'nim': '225510010'},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang Kelompok"),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        foregroundColor: isDark ? Colors.white : Colors.black,
        backgroundColor:
            isDark ? Colors.teal.withOpacity(0.9) : Colors.teal[300],
        elevation: 0,
        centerTitle: true,
      ),
      body: AnimatedBackground(
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Kelompok 6',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: anggotaKelompok.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final anggota = anggotaKelompok[index];
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color:
                            isDark
                                ? Colors.teal.withOpacity(0.25)
                                : Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    isDark ? Colors.teal[300] : Colors.teal,
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    anggota['nama'] ?? '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'NIM: ${anggota['nim']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
