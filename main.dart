import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mqtt_service.dart';
import 'providers/sensor_data_provider.dart';
import 'providers/alert_settings_provider.dart';
import 'providers/history_provider.dart'; // <<-- Tambahan ini
import 'pages/dashboard_page.dart';
import 'pages/mqtt_page.dart';
import 'pages/kelompok_page.dart';
import 'pages/tentang_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorDataProvider()),
        ChangeNotifierProvider(create: (_) => MQTTService()),
        ChangeNotifierProvider(create: (_) => AlertSettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(),
        ), // <<-- Tambahan ini
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pond Dashboard',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    MQTTPage(),
    KelompokPage(),
    TentangPage(),
  ];

  final List<String> _titles = [
    'Smart Pond',
    'Smart Pond',
    'Smart Pond',
    'Smart Pond',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[currentIndex]),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
        child: _pages[currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() {
            currentIndex = i;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.wifi), label: 'MQTT'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Kelompok'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Tentang'),
        ],
      ),
    );
  }
}
