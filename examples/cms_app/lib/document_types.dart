import 'dart:convert';

import 'package:data_models/example_data.dart';
import 'package:example_app/screens/homes_creen.dart';

final homeScreenDocumentType = homeScreenConfigTypeSpec.build(
  builder: (data) {
    final merged = {...HomeScreenConfig.defaultValue.toMap(), ...data};

    // Normalize fields that may be stored as JSON strings instead of Lists
    final featuredItems = merged['featuredItems'];
    if (featuredItems is String) {
      try {
        merged['featuredItems'] = jsonDecode(featuredItems) as List;
      } catch (_) {
        merged['featuredItems'] = <String>[];
      }
    }

    return HomeScreen(config: HomeScreenConfigMapper.fromMap(merged));
  },
);
