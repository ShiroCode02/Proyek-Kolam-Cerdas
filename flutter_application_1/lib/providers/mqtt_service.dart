import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
import 'sensor_data_provider.dart';

class MQTTService with ChangeNotifier {
  late MqttServerClient client;
  bool isConnected = false;
  bool isConnecting = false;
  bool _isManuallyDisconnected = false;
  late BuildContext _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> connect() async {
    if (isConnected || isConnecting) {
      print('⚠️ MQTT already connecting/connected.');
      return;
    }

    print('🔌 Attempting MQTT connection...');
    _isManuallyDisconnected = false;

    client = MqttServerClient(
      'mqtt.eclipseprojects.io',
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
    );
    client.port = 1883;
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMess;

    try {
      // Tambah timeout agar tidak hang
      await client.connect().timeout(const Duration(seconds: 5));

      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print('✅ MQTT Connected!');
        isConnected = true;
        notifyListeners();

        const topic = 'K6/kolam/sensor/status';
        print('📡 Subscribing to topic: $topic');
        client.subscribe(topic, MqttQos.atLeastOnce);

        client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final recMess = c[0].payload as MqttPublishMessage;
          final pt = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );

          print('📥 MQTT Message received on ${c[0].topic}: $pt');

          try {
            final data = jsonDecode(pt);

            // 🔁 Cara 1: Langsung pakai metode updateAll
            final sensorProvider = Provider.of<SensorDataProvider>(
              _context,
              listen: false,
            );
            final kolam = data['kolam']?.toString() ?? '1';
            sensorProvider.updateSensorData(kolam, data);

            // 🔁 Cara 2: Jika kamu pakai updateFromJson di provider
            // final sensorData = Provider.of<SensorDataProvider>(_context, listen: false);
            // sensorData.updateFromJson(data);
          } catch (e) {
            print('❌ JSON parse error: $e');
          }
        });
      } else {
        throw Exception(
          'Connection failed with status: ${client.connectionStatus}',
        );
      }
    } on TimeoutException {
      print('⏰ MQTT connection timed out.');
      client.disconnect();
      isConnected = false;
      notifyListeners();
    } catch (e) {
      print('❌ MQTT Connection failed: $e');
      client.disconnect();
      isConnected = false;
      notifyListeners();

      if (!_isManuallyDisconnected) {
        // Retry jika bukan disconnect manual
        Future.delayed(const Duration(seconds: 5), () {
          print('🔁 Reconnecting...');
          connect();
        });
      }
    }
  }

  void disconnect() {
    if (isConnected) {
      _isManuallyDisconnected = true; // <-- tambahkan ini
      client.disconnect();
      print('❌ Manual disconnect by user');
    } else {
      print('⚠️ No active MQTT connection to disconnect.');
    }
  }

  void onDisconnected() {
    print('🔌 MQTT Disconnected!');
    isConnected = false;
    notifyListeners();

    if (!_isManuallyDisconnected) {
      Future.delayed(const Duration(seconds: 3), () {
        print('🔁 Auto reconnecting...');
        connect();
      });
    }
  }

  void publishMessage(String topic, String message) {
    if (!isConnected) {
      print('⚠️ Cannot publish, MQTT not connected.');
      return;
    }

    print('📤 Publishing to $topic: $message');
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
}
