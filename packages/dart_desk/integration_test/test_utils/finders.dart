// packages/dart_desk/integration_test/test_utils/finders.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Finds a ShadButton by its label text.
Finder findShadButton(String label) => find.text(label);

/// Finds a widget by its ValueKey string.
Finder findByKey(String key) => find.byKey(ValueKey(key));

/// Finds a text input field by its placeholder/hint text.
Finder findShadInput(String placeholder) =>
    find.widgetWithText(TextField, placeholder);
