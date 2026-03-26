// packages/dart_desk/integration_test/test_utils/db_helper.dart
import 'package:flutter/foundation.dart';

/// Database helpers for integration tests.
///
/// IMPORTANT: DB reset/seed cannot run from within Flutter web tests
/// (browser sandbox). Run the e2e_env.sh script BEFORE launching tests:
///
///   packages/dart_desk/tests/e2e/setup/e2e_env.sh reset-all
///   packages/dart_desk/tests/e2e/setup/e2e_env.sh seed
///
/// These are no-ops so test files don't need to change when HTTP endpoints
/// are added later.
class DbHelper {
  static Future<void> reset() async {
    debugPrint('[db_helper] reset: no-op — run e2e_env.sh reset-all before tests');
  }

  static Future<void> seedDocuments() async {
    debugPrint('[db_helper] seedDocuments: no-op — seed externally if needed');
  }
}
