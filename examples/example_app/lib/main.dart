/// Example: Fetching CMS content via the serverpod public endpoint
/// and deserializing with dart_mappable's `discriminatorValue`.
///
/// `publicContent.getDefaultContents()` returns `Map<String, PublicDocument>`
/// keyed by document type (e.g. `"brandTheme"`).
///
/// We inject the key as `"documentType"` into the JSON payload, then call
/// `DeskContentMapper.fromMap(json)` — dart_mappable automatically resolves
/// to the correct subclass via `discriminatorValue`.
library;

import 'dart:convert';

import 'package:dart_desk_client/dart_desk_client.dart';
import 'package:data_models/example_data.dart';
import 'package:example_app/screens/brand_theme_screen.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

const _defaultServerUrl = 'http://localhost:8080/';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: _defaultServerUrl,
  );

  static const apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'desk_w_5cRn9tCk-cdHTP0KM5Wiia02WhNMTL2rCzrz8guMVgk',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF496455)),
      ),
      home: DeskHomePage(serverUrl: serverUrl, apiKey: apiKey),
    );
  }
}

class DeskHomePage extends StatefulWidget {
  const DeskHomePage({super.key, required this.serverUrl, required this.apiKey});

  final String serverUrl;
  final String apiKey;

  @override
  State<DeskHomePage> createState() => _DeskHomePageState();
}

const _screens = <({Type type, String label, IconData icon})>[
  (type: BrandTheme, label: 'Theme', icon: Icons.palette),
  // Re-added incrementally as configs land:
  // (type: RestaurantProfile, label: 'Profile', icon: Icons.store),
  // (type: MenuItem, label: 'Menu', icon: Icons.restaurant_menu),
  // (type: PromotionCampaign, label: 'Promo', icon: Icons.campaign),
];

class _DeskHomePageState extends State<DeskHomePage> {
  late final Client _client;
  Map<Type, DeskContent>? _configs;
  String? _error;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _client = Client(widget.serverUrl)
      ..authKeyProvider = DartDeskAuthKeyProvider(apiKey: widget.apiKey)
      ..connectivityMonitor = FlutterConnectivityMonitor();
    _fetchContents();
  }

  Future<void> _fetchContents() async {
    try {
      final defaults = await _client.publicContent.getDefaultContents();
      final configs = <Type, DeskContent>{};

      for (final entry in defaults.entries) {
        final documentType = entry.key;
        final data = jsonDecode(entry.value.data) as Map<String, dynamic>;

        data['documentType'] = documentType;
        final config = DeskContentMapper.fromMap(data);
        configs[config.runtimeType] = config;
      }

      setState(() => _configs = configs);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }
    if (_configs == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screenType = _screens[_selectedIndex].type;
    final config = _configs![screenType];

    return Scaffold(
      body: config != null
          ? _buildScreen(config)
          : Center(
              child: Text('No data for ${_screens[_selectedIndex].label}'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: [
          for (final s in _screens)
            NavigationDestination(icon: Icon(s.icon), label: s.label),
        ],
      ),
    );
  }

  Widget _buildScreen(DeskContent config) {
    return switch (config) {
      BrandTheme c => BrandThemeScreen(config: c),
      _ => Center(child: Text('Unknown: ${config.runtimeType}')),
    };
  }
}
