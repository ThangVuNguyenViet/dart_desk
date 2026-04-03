/// Example: Fetching CMS content via the serverpod public endpoint
/// and deserializing with dart_mappable's `discriminatorValue`.
///
/// `publicContent.getDefaultContents()` returns `Map<String, PublicDocument>`
/// keyed by document type (e.g. `"heroConfig"`, `"kioskConfig"`).
///
/// We inject the key as `"documentType"` into the JSON payload, then call
/// `CmsContentMapper.fromMap(json)` — dart_mappable automatically resolves
/// to the correct subclass via `discriminatorValue`.
library;

import 'dart:convert';

import 'package:data_models/example_data.dart';
import 'package:dart_desk_client/dart_desk_client.dart';
import 'package:example_app/screens/brand_theme_screen.dart';
import 'package:example_app/screens/hero_screen.dart';
import 'package:example_app/screens/kiosk_screen.dart';
import 'package:example_app/screens/reward_screen.dart';
import 'package:example_app/screens/upsell_screen.dart';
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
    defaultValue: 'cms_w_5dGK1_MeafXRpFF5sLLU-0x5ICYqEIVDdyT9wrlcFmg',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF496455)),
      ),
      home: CmsHomePage(serverUrl: serverUrl, apiKey: apiKey),
    );
  }
}

class CmsHomePage extends StatefulWidget {
  const CmsHomePage({super.key, required this.serverUrl, required this.apiKey});

  final String serverUrl;
  final String apiKey;

  @override
  State<CmsHomePage> createState() => _CmsHomePageState();
}

// Screen definitions for the bottom nav.
const _screens = <({Type type, String label, IconData icon})>[
  (type: BrandTheme, label: 'Theme', icon: Icons.palette),
  (type: KioskConfig, label: 'Kiosk', icon: Icons.point_of_sale),
  (type: HeroConfig, label: 'Hero', icon: Icons.home),
  (type: UpsellConfig, label: 'Upsell', icon: Icons.restaurant_menu),
  (type: RewardConfig, label: 'Reward', icon: Icons.card_giftcard),
];

class _CmsHomePageState extends State<CmsHomePage> {
  late final Client _client;
  Map<Type, CmsContent>? _configs;
  String? _error;
  int _selectedIndex = 1; // default to Kiosk

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
      final configs = <Type, CmsContent>{};

      for (final entry in defaults.entries) {
        final documentType = entry.key;
        final data = jsonDecode(entry.value.data) as Map<String, dynamic>;

        // Inject the document type as the discriminator key.
        // CmsContentMapper.fromMap automatically routes to the correct
        // subclass (HeroConfig, KioskConfig, etc.) via discriminatorValue.
        data['documentType'] = documentType;
        final config = CmsContentMapper.fromMap(data);
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
          : Center(child: Text('No data for ${_screens[_selectedIndex].label}')),
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

  Widget _buildScreen(CmsContent config) {
    return switch (config) {
      BrandTheme c => BrandThemeScreen(config: c),
      KioskConfig c => KioskScreen(config: c),
      HeroConfig c => HeroScreen(config: c),
      UpsellConfig c => UpsellScreen(config: c),
      RewardConfig c => RewardScreen(config: c),
      _ => Center(child: Text('Unknown: ${config.runtimeType}')),
    };
  }
}
