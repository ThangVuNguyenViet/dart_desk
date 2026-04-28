import 'package:dart_desk/dart_desk.dart';
import 'package:data_models/example_data.dart';
import 'package:example_app/screens/brand_theme_screen.dart';
import 'package:flutter/material.dart';

Future<Widget> buildExampleApp({required PublicContentSource contentSource}) async {
  return _ExampleApp(contentSource: contentSource);
}

class _ExampleApp extends StatelessWidget {
  const _ExampleApp({required this.contentSource});
  final PublicContentSource contentSource;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF496455)),
      ),
      home: _ExampleHome(contentSource: contentSource),
    );
  }
}

const _screens = <({Type type, String label, IconData icon})>[
  (type: BrandTheme, label: 'Theme', icon: Icons.palette),
];

class _ExampleHome extends StatefulWidget {
  const _ExampleHome({required this.contentSource});
  final PublicContentSource contentSource;

  @override
  State<_ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<_ExampleHome> {
  Map<Type, DeskContent>? _configs;
  String? _error;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchContents();
  }

  Future<void> _fetchContents() async {
    try {
      final defaults = await widget.contentSource.getDefaultContents();
      final configs = <Type, DeskContent>{};
      for (final entry in defaults.entries) {
        final data = Map<String, dynamic>.from(entry.value.data);
        data['documentType'] = entry.key;
        final config = DeskContentMapper.fromMap(data);
        configs[config.runtimeType] = config;
      }
      if (mounted) setState(() => _configs = configs);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
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

  Widget _buildScreen(DeskContent config) {
    return switch (config) {
      BrandTheme c => BrandThemeScreen(config: c),
      _ => Center(child: Text('Unknown: ${config.runtimeType}')),
    };
  }
}
