import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_background/animated_background.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../providers/history_provider.dart';

class HistoryPage extends StatefulWidget {
  final int selectedKolam;
  const HistoryPage({Key? key, required this.selectedKolam}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    await context.read<HistoryProvider>().fetchDataLampau();
    setState(() => isLoading = false);
  }

  DateTime _parseTimestamp(String ts) {
    try {
      return DateTime.parse(ts);
    } catch (_) {
      try {
        return HttpDate.parse(ts).toLocal();
      } catch (e) {
        return DateTime.now();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final historyProvider = context.watch<HistoryProvider>();
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');
    final dataLampau =
        historyProvider.dataLampau
            .where(
              (item) =>
                  item['kolam_id'].toString() ==
                  widget.selectedKolam.toString(),
            )
            .toList();

    return AnimatedBackground(
      behaviour: RandomParticleBehaviour(
        options: ParticleOptions(
          baseColor: Colors.teal,
          spawnOpacity: 0.3,
          opacityChangeRate: 0.2,
          minOpacity: 0.05,
          maxOpacity: 0.3,
          spawnMinSpeed: 10.0,
          spawnMaxSpeed: 50.0,
          spawnMinRadius: 3.0,
          spawnMaxRadius: 6.0,
          particleCount: 30,
        ),
      ),
      vsync: this,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: false,
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : dataLampau.isEmpty
                  ? const Center(child: Text('Belum ada data riwayat.'))
                  : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
                    itemCount: dataLampau.length,
                    itemBuilder: (context, index) {
                      final item = dataLampau[index];
                      final dt = _parseTimestamp(item['timestamp']);
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color:
                            isDark
                                ? Colors.teal.withOpacity(0.2)
                                : Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateFormatter.format(dt),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildMetric(
                                    'Suhu',
                                    '${item['suhuAir']} °C',
                                    isDark,
                                  ),
                                  _buildMetric(
                                    'pH',
                                    '${item['phAir']}',
                                    isDark,
                                  ),
                                  _buildMetric('DO', '${item['do']}', isDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
