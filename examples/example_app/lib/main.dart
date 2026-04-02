import 'package:data_models/example_data.dart';
import 'package:example_app/screens/storefront_preview.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // In production, fetch config from dart_desk_client:
    //   final client = DartDeskClient(serverUrl: '...', apiKey: '...');
    //   final data = await client.getDocument('storefrontConfig', 'my-doc');
    //   final config = StorefrontConfigMapper.fromMap(data);

    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4451A)),
      ),
      home: StorefrontPreview(config: StorefrontConfig.defaultValue),
    );
  }
}
