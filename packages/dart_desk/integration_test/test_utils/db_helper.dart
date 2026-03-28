// packages/dart_desk/integration_test/test_utils/db_helper.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'test_app.dart';

const _e2eEnvScript = String.fromEnvironment(
  'E2E_ENV_SCRIPT',
  defaultValue: 'tests/e2e/setup/e2e_env.sh',
);

class DbHelper {
  static Future<void> reset() async {
    // Verify the backend is reachable before resetting.
    try {
      final uri = Uri.parse(testBackendUrl);
      await http.get(uri).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[db_helper] Backend unreachable at $testBackendUrl: $e');
      rethrow;
    }

    debugPrint('[db_helper] Resetting database via $e2eEnvScript reset');
    final result = await Process.run('bash', [e2eEnvScript, 'reset']);
    if (result.exitCode != 0) {
      debugPrint('[db_helper] reset failed (exit ${result.exitCode}):');
      debugPrint(result.stderr.toString());
    } else {
      debugPrint('[db_helper] reset complete');
    }
  }

  static Future<void> seedDocuments() async {
    debugPrint('[db_helper] Seeding via $e2eEnvScript seed');
    final result = await Process.run('bash', [e2eEnvScript, 'seed']);
    if (result.exitCode != 0) {
      debugPrint('[db_helper] seed failed (exit ${result.exitCode}):');
      debugPrint(result.stderr.toString());
    } else {
      debugPrint('[db_helper] seed complete');
    }
  }

  static String get e2eEnvScript => _e2eEnvScript;
}
