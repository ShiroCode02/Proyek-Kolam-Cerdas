import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:provider/provider.dart';
import '../providers/mqtt_service.dart';

class MQTTPage extends StatefulWidget {
  const MQTTPage({super.key});

  @override
  State<MQTTPage> createState() => _MQTTPageState();
}

class _MQTTPageState extends State<MQTTPage> with TickerProviderStateMixin {
  final TextEditingController topicController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  List<String> logMessages = [];

  @override
  void initState() {
    super.initState();
    final mqtt = Provider.of<MQTTService>(context, listen: false);
    mqtt.setContext(context);
  }

  void _updateLog(String message) {
    setState(() {
      logMessages.insert(0, "${DateTime.now().toLocal()} - $message");
    });
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = Provider.of<MQTTService>(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isConnected = mqtt.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MQTT Connection"),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        foregroundColor:
            isDark
                ? Colors.white
                : Colors.black, // Menyesuaikan warna teks dengan mode
        backgroundColor:
            isDark
                ? Colors.teal.withOpacity(0.9) // Gelap saat mode malam
                : Colors.teal[300], // Lebih terang saat mode siang
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.teal.withOpacity(0.9) // Gelap saat mode malam
                    : Colors.teal[300], // Lebih terang saat mode siang
          ),
        ),
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
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [Tab(text: 'Koneksi'), Tab(text: 'History')],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // === Tab 1: Koneksi ===
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed:
                                  mqtt.isConnecting
                                      ? null
                                      : () async {
                                        if (isConnected) {
                                          mqtt.disconnect();
                                          _updateLog(
                                            "❌ Disconnected from MQTT Broker",
                                          );
                                        } else {
                                          _updateLog(
                                            "🔌 Connecting to MQTT Broker...",
                                          );
                                          await mqtt.connect();
                                          if (mqtt.isConnected) {
                                            _updateLog(
                                              "✅ Connected to MQTT Broker",
                                            );
                                          } else {
                                            _updateLog(
                                              "❌ Failed to connect to MQTT Broker",
                                            );
                                          }
                                        }
                                      },
                              icon: Icon(
                                isConnected ? Icons.cloud_done : Icons.cloud,
                              ),
                              label: Text(
                                isConnected ? "Disconnect" : "Connect",
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isConnected ? Colors.green : Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: topicController,
                              decoration: const InputDecoration(
                                labelText: 'Topic',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: messageController,
                              decoration: const InputDecoration(
                                labelText: 'Message',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed:
                                  isConnected
                                      ? () {
                                        final topic =
                                            topicController.text.trim();
                                        final message =
                                            messageController.text.trim();

                                        if (topic.isNotEmpty &&
                                            message.isNotEmpty) {
                                          mqtt.publishMessage(topic, message);
                                          _updateLog(
                                            "📤 Published to '$topic': $message",
                                          );
                                        }
                                      }
                                      : null,
                              icon: const Icon(Icons.send),
                              label: const Text("Send Message"),
                            ),
                          ],
                        ),
                      ),
                      // === Tab 2: History ===
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              "MQTT Log History",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: logMessages.length,
                                itemBuilder: (context, index) {
                                  return Text(
                                    logMessages[index],
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
