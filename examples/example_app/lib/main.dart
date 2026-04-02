import 'package:data_models/example_data.dart';
import 'package:example_app/screens/kiosk_preview.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF496455)),
      ),
      home: KioskPreview(config: KioskConfig.defaultValue),
    );
  }
}
