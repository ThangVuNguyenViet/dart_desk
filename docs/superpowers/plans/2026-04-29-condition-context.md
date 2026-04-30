# DeskConditionContext Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `DeskCondition.evaluate(Map<String, dynamic>)` with `DeskCondition.evaluate(DeskConditionContext)` so conditions can read full document metadata and runtime services without coupling schema packages to the dart_desk runtime.

**Architecture:** `dart_desk_annotation` defines an abstract `DeskConditionContext` with `document` and `read<T>()` capabilities. `dart_desk` provides a private GetIt-backed implementation and constructs a single instance per `DeskForm` render. `DeskDocument` migrates from `dart_desk` to `dart_desk_annotation` so conditions defined in lightweight schema packages can read it without importing the heavy runtime.

**Tech Stack:** Dart 3.8, Flutter, `flutter_test`, `get_it`, `signals_flutter`.

**Spec:** `docs/superpowers/specs/2026-04-29-condition-context-design.md`

**Repo paths in this plan are relative to:** `/Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk/`

---

## File Map

**Move:**
- `packages/dart_desk/lib/src/data/models/desk_document.dart`
  → `packages/dart_desk_annotation/lib/src/data/desk_document.dart`

**Modify:**
- `packages/dart_desk_annotation/lib/dart_desk_annotation.dart` — export new `data/desk_document.dart` and `fields/base/desk_condition_context.dart`
- `packages/dart_desk_annotation/lib/src/fields/base/field.dart` — change `DeskCondition.evaluate` signature, migrate built-ins
- `packages/dart_desk_annotation/pubspec.yaml` — add `flutter_test` dev dep
- `packages/dart_desk/lib/src/data/data.dart` — re-export `DeskDocument` from annotation
- `packages/dart_desk/lib/src/studio/core/view_models/desk_document_view_model.dart` — fix import
- `packages/dart_desk/lib/src/studio/core/view_models/desk_view_model.dart` — fix import
- `packages/dart_desk/lib/src/studio/screens/document_list.dart` — fix import
- `packages/dart_desk/lib/src/testing/mock_desk_data_source.dart` — fix import
- `packages/dart_desk/lib/src/studio/components/forms/desk_form.dart` — pass `DeskConditionContext` into `evaluate`

**Create:**
- `packages/dart_desk_annotation/lib/src/fields/base/desk_condition_context.dart`
- `packages/dart_desk_annotation/test/fields/base/desk_condition_test.dart`
- `packages/dart_desk/lib/src/studio/internal/get_it_condition_context.dart`
- `packages/dart_desk/test/studio/internal/get_it_condition_context_test.dart`
- `packages/dart_desk/test/studio/components/forms/desk_form_condition_test.dart`

---

## Task 1: Relocate `DeskDocument` to `dart_desk_annotation`

**Files:**
- Create: `packages/dart_desk_annotation/lib/src/data/desk_document.dart`
- Modify: `packages/dart_desk_annotation/lib/dart_desk_annotation.dart`
- Delete: `packages/dart_desk/lib/src/data/models/desk_document.dart`
- Modify: `packages/dart_desk/lib/src/data/data.dart`
- Modify: `packages/dart_desk/lib/src/studio/core/view_models/desk_document_view_model.dart:4`
- Modify: `packages/dart_desk/lib/src/studio/core/view_models/desk_view_model.dart:6`
- Modify: `packages/dart_desk/lib/src/studio/screens/document_list.dart:10`
- Modify: `packages/dart_desk/lib/src/testing/mock_desk_data_source.dart:9`

- [ ] **Step 1: Create the new file at the annotation path**

Copy the existing content of `packages/dart_desk/lib/src/data/models/desk_document.dart` verbatim into `packages/dart_desk_annotation/lib/src/data/desk_document.dart`. The class has no Flutter or heavy-runtime imports — only `dart:convert` — so no other changes are needed.

```dart
// packages/dart_desk_annotation/lib/src/data/desk_document.dart
import 'dart:convert';

/// Platform-agnostic CMS document model.
///
/// This represents document metadata without the actual content data.
/// The content is stored in DocumentVersion objects.
class DeskDocument {
  final String? id;
  final String clientId;
  final String documentType;
  final String title;
  final String? slug;
  final bool isDefault;
  final Map<String, dynamic>? activeVersionData;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdByUserId;
  final String? updatedByUserId;

  const DeskDocument({
    this.id,
    required this.clientId,
    required this.documentType,
    required this.title,
    this.slug,
    this.isDefault = false,
    this.activeVersionData,
    this.createdAt,
    this.updatedAt,
    this.createdByUserId,
    this.updatedByUserId,
  });

  DeskDocument copyWith({
    String? id,
    String? clientId,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    Map<String, dynamic>? activeVersionData,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdByUserId,
    String? updatedByUserId,
  }) {
    return DeskDocument(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      documentType: documentType ?? this.documentType,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      isDefault: isDefault ?? this.isDefault,
      activeVersionData: activeVersionData ??
          (this.activeVersionData != null
              ? Map<String, dynamic>.from(this.activeVersionData!)
              : null),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      updatedByUserId: updatedByUserId ?? this.updatedByUserId,
    );
  }

  factory DeskDocument.fromJson(Map<String, dynamic> json) {
    final rawData = json['activeVersionData'];
    Map<String, dynamic>? parsedData;

    if (rawData is String && rawData.isNotEmpty) {
      try {
        parsedData = jsonDecode(rawData) as Map<String, dynamic>;
      } catch (_) {
        parsedData = null;
      }
    } else if (rawData is Map<String, dynamic>) {
      parsedData = rawData;
    }

    return DeskDocument(
      id: json['id']?.toString(),
      clientId: json['clientId'].toString(),
      documentType: json['documentType'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      activeVersionData: parsedData,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      createdByUserId: json['createdByUserId']?.toString(),
      updatedByUserId: json['updatedByUserId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'documentType': documentType,
      'title': title,
      if (slug != null) 'slug': slug,
      'isDefault': isDefault,
      if (activeVersionData != null) 'activeVersionData': activeVersionData,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId,
    };
  }

  @override
  String toString() {
    return 'DeskDocument(id: $id, type: $documentType, title: $title, slug: $slug, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeskDocument &&
        other.id == id &&
        other.documentType == documentType &&
        other.slug == slug;
  }

  @override
  int get hashCode => Object.hash(id, documentType, slug);
}
```

- [ ] **Step 2: Export from the annotation barrel**

Add this export line to `packages/dart_desk_annotation/lib/dart_desk_annotation.dart` immediately after the existing `// Models` section (around the line `export 'src/models/image_reference_mapper.dart';`):

```dart
// Data models
export 'src/data/desk_document.dart';
```

- [ ] **Step 3: Delete the old file**

Run:
```bash
rm packages/dart_desk/lib/src/data/models/desk_document.dart
```

- [ ] **Step 4: Replace internal imports with annotation imports**

In each of these files, replace the `desk_document.dart` import with `package:dart_desk_annotation/dart_desk_annotation.dart`:

`packages/dart_desk/lib/src/studio/core/view_models/desk_document_view_model.dart` line 4 — change:
```dart
import '../../../data/models/desk_document.dart';
```
to:
```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
```

Same change in:
- `packages/dart_desk/lib/src/studio/core/view_models/desk_view_model.dart:6` (was `import '../../../data/models/desk_document.dart';`)
- `packages/dart_desk/lib/src/studio/screens/document_list.dart:10` (was `import '../../data/models/desk_document.dart';`)
- `packages/dart_desk/lib/src/testing/mock_desk_data_source.dart:9` (was `import '../data/models/desk_document.dart';`)

- [ ] **Step 5: Re-export `DeskDocument` from `dart_desk` for backward compat**

In `packages/dart_desk/lib/src/data/data.dart`, replace the line:
```dart
export 'models/desk_document.dart';
```
with:
```dart
// DeskDocument moved to dart_desk_annotation; re-exported here so existing
// `package:dart_desk/...` imports keep working.
export 'package:dart_desk_annotation/dart_desk_annotation.dart' show DeskDocument;
```

- [ ] **Step 6: Verify the package analyzes cleanly**

Run:
```bash
cd packages/dart_desk_annotation && dart analyze
cd ../dart_desk && flutter analyze
```
Expected: zero errors. Existing warnings unrelated to this change are acceptable.

- [ ] **Step 7: Commit**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
git add packages/dart_desk_annotation/lib/src/data/desk_document.dart \
        packages/dart_desk_annotation/lib/dart_desk_annotation.dart \
        packages/dart_desk/lib/src/data/models/desk_document.dart \
        packages/dart_desk/lib/src/data/data.dart \
        packages/dart_desk/lib/src/studio/core/view_models/desk_document_view_model.dart \
        packages/dart_desk/lib/src/studio/core/view_models/desk_view_model.dart \
        packages/dart_desk/lib/src/studio/screens/document_list.dart \
        packages/dart_desk/lib/src/testing/mock_desk_data_source.dart
git commit -m "refactor: move DeskDocument to dart_desk_annotation

Plain data model with no heavy deps; needed by upcoming
DeskConditionContext so conditions in schema-only packages can read
document metadata. dart_desk re-exports DeskDocument for backward
compat."
```

---

## Task 2: Add `flutter_test` dev dep to `dart_desk_annotation`

**Files:**
- Modify: `packages/dart_desk_annotation/pubspec.yaml`

- [ ] **Step 1: Add `dev_dependencies` block**

Append to `packages/dart_desk_annotation/pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
```

- [ ] **Step 2: Resolve dependencies**

Run:
```bash
cd packages/dart_desk_annotation && flutter pub get
```
Expected: `Got dependencies!` (or `Resolving dependencies...` followed by no errors).

- [ ] **Step 3: Commit**

```bash
git add packages/dart_desk_annotation/pubspec.yaml \
        packages/dart_desk_annotation/pubspec.lock
git commit -m "chore: add flutter_test dev dep to dart_desk_annotation"
```

---

## Task 3: Define `DeskConditionContext`

**Files:**
- Create: `packages/dart_desk_annotation/lib/src/fields/base/desk_condition_context.dart`
- Modify: `packages/dart_desk_annotation/lib/dart_desk_annotation.dart`

- [ ] **Step 1: Create the abstract class**

```dart
// packages/dart_desk_annotation/lib/src/fields/base/desk_condition_context.dart
import '../../data/desk_document.dart';

/// Information passed to [DeskCondition.evaluate] so conditions can read
/// document metadata and runtime services without coupling to a specific
/// host implementation (GetIt, Riverpod, etc.).
///
/// Implementations live in the host package (e.g. `dart_desk`).
abstract class DeskConditionContext {
  const DeskConditionContext();

  /// The document currently being edited.
  ///
  /// Includes metadata (`id`, `documentType`, `title`, `isDefault`, …) and
  /// the current content map under [DeskDocument.activeVersionData].
  ///
  /// Null when no document is selected (e.g. in tests, or before any
  /// document has been opened).
  DeskDocument? get document;

  /// Look up a runtime service by type — viewmodels, repositories, or
  /// anything else registered with the host's locator.
  ///
  /// Throws [StateError] (or the host's equivalent) if [T] is not
  /// registered.
  T read<T extends Object>();
}
```

- [ ] **Step 2: Export from the annotation barrel**

Add to `packages/dart_desk_annotation/lib/dart_desk_annotation.dart`, in the `// Base field abstractions` section right after `export 'src/fields/base/field.dart';`:

```dart
export 'src/fields/base/desk_condition_context.dart';
```

- [ ] **Step 3: Verify**

Run:
```bash
cd packages/dart_desk_annotation && dart analyze
```
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add packages/dart_desk_annotation/lib/src/fields/base/desk_condition_context.dart \
        packages/dart_desk_annotation/lib/dart_desk_annotation.dart
git commit -m "feat(annotation): add DeskConditionContext abstraction

Capability surface for conditions: document metadata + service lookup.
Concrete impl will live in dart_desk."
```

---

## Task 4: Migrate `DeskCondition` and built-ins to the new signature

**Files:**
- Modify: `packages/dart_desk_annotation/lib/src/fields/base/field.dart`
- Create: `packages/dart_desk_annotation/test/fields/base/desk_condition_test.dart`

- [ ] **Step 1: Write failing tests for built-ins**

Create `packages/dart_desk_annotation/test/fields/base/desk_condition_test.dart`:

```dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeContext extends DeskConditionContext {
  const _FakeContext({this.document});
  @override
  final DeskDocument? document;
  @override
  T read<T extends Object>() =>
      throw StateError('read<$T>() not stubbed in this test');
}

DeskConditionContext _ctxWithData(Map<String, dynamic> data) {
  return _FakeContext(
    document: DeskDocument(
      clientId: 'c',
      documentType: 'doc',
      title: 't',
      activeVersionData: data,
    ),
  );
}

void main() {
  group('FieldEquals', () {
    test('returns true when field equals value', () {
      const cond = FieldEquals('status', 'published');
      expect(cond.evaluate(_ctxWithData({'status': 'published'})), isTrue);
    });
    test('returns false when field differs', () {
      const cond = FieldEquals('status', 'published');
      expect(cond.evaluate(_ctxWithData({'status': 'draft'})), isFalse);
    });
    test('returns false when document is null', () {
      const cond = FieldEquals('status', 'published');
      expect(cond.evaluate(const _FakeContext()), isFalse);
    });
  });

  group('FieldNotEquals', () {
    test('returns true when field differs', () {
      const cond = FieldNotEquals('status', 'published');
      expect(cond.evaluate(_ctxWithData({'status': 'draft'})), isTrue);
    });
    test('returns false when field matches', () {
      const cond = FieldNotEquals('status', 'published');
      expect(cond.evaluate(_ctxWithData({'status': 'published'})), isFalse);
    });
  });

  group('FieldNotNull', () {
    test('returns true when field is set', () {
      const cond = FieldNotNull('publishedAt');
      expect(cond.evaluate(_ctxWithData({'publishedAt': 'x'})), isTrue);
    });
    test('returns false when field is null', () {
      const cond = FieldNotNull('publishedAt');
      expect(cond.evaluate(_ctxWithData({'publishedAt': null})), isFalse);
    });
    test('returns false when document is null', () {
      const cond = FieldNotNull('publishedAt');
      expect(cond.evaluate(const _FakeContext()), isFalse);
    });
  });

  group('FieldIsNull', () {
    test('returns true when field is null', () {
      const cond = FieldIsNull('publishedAt');
      expect(cond.evaluate(_ctxWithData({'publishedAt': null})), isTrue);
    });
    test('returns false when field is set', () {
      const cond = FieldIsNull('publishedAt');
      expect(cond.evaluate(_ctxWithData({'publishedAt': 'x'})), isFalse);
    });
  });

  group('AllConditions', () {
    test('returns true when every child returns true', () {
      const cond = AllConditions([
        FieldEquals('a', 1),
        FieldEquals('b', 2),
      ]);
      expect(cond.evaluate(_ctxWithData({'a': 1, 'b': 2})), isTrue);
    });
    test('returns false when any child returns false', () {
      const cond = AllConditions([
        FieldEquals('a', 1),
        FieldEquals('b', 2),
      ]);
      expect(cond.evaluate(_ctxWithData({'a': 1, 'b': 3})), isFalse);
    });
  });

  group('AnyCondition', () {
    test('returns true when at least one child returns true', () {
      const cond = AnyCondition([
        FieldEquals('a', 1),
        FieldEquals('b', 2),
      ]);
      expect(cond.evaluate(_ctxWithData({'a': 99, 'b': 2})), isTrue);
    });
    test('returns false when no child returns true', () {
      const cond = AnyCondition([
        FieldEquals('a', 1),
        FieldEquals('b', 2),
      ]);
      expect(cond.evaluate(_ctxWithData({'a': 99, 'b': 99})), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run:
```bash
cd packages/dart_desk_annotation && flutter test test/fields/base/desk_condition_test.dart
```
Expected: compilation failure — `evaluate` still takes `Map<String, dynamic>`, not `DeskConditionContext`. The test file won't compile against the current signature.

- [ ] **Step 3: Update `DeskCondition` and built-ins to the new signature**

Replace the contents of `packages/dart_desk_annotation/lib/src/fields/base/field.dart` with:

```dart
import 'desk_condition_context.dart';

/// Base condition class for conditional field visibility.
/// Subclass and override [evaluate] to create custom conditions.
/// All subclasses must be const-constructible.
abstract class DeskCondition {
  const DeskCondition();

  /// Returns true if the field should be visible given the current [ctx].
  bool evaluate(DeskConditionContext ctx);
}

/// Shows the field when [field] equals [value].
class FieldEquals extends DeskCondition {
  final String field;
  final Object? value;
  const FieldEquals(this.field, this.value);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      ctx.document?.activeVersionData?[field] == value;
}

/// Shows the field when [field] does not equal [value].
class FieldNotEquals extends DeskCondition {
  final String field;
  final Object? value;
  const FieldNotEquals(this.field, this.value);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      ctx.document?.activeVersionData?[field] != value;
}

/// Shows the field when [field] is not null.
class FieldNotNull extends DeskCondition {
  final String field;
  const FieldNotNull(this.field);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      ctx.document?.activeVersionData?[field] != null;
}

/// Shows the field when [field] is null.
class FieldIsNull extends DeskCondition {
  final String field;
  const FieldIsNull(this.field);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      ctx.document?.activeVersionData?[field] == null;
}

/// Shows the field when all [conditions] are true.
class AllConditions extends DeskCondition {
  final List<DeskCondition> conditions;
  const AllConditions(this.conditions);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      conditions.every((c) => c.evaluate(ctx));
}

/// Shows the field when any of [conditions] is true.
class AnyCondition extends DeskCondition {
  final List<DeskCondition> conditions;
  const AnyCondition(this.conditions);

  @override
  bool evaluate(DeskConditionContext ctx) =>
      conditions.any((c) => c.evaluate(ctx));
}

abstract class DeskOption {
  const DeskOption({this.hidden = false, this.optional = false, this.condition});

  final bool hidden;

  /// Whether the field is optional (can be null/unset).
  final bool optional;

  /// Condition that determines field visibility based on the editor context.
  /// When null, the field is always visible (unless [hidden] is true).
  final DeskCondition? condition;
}

abstract class DeskField {
  final String name;
  final String title;
  final String? description;
  final DeskOption? option;

  const DeskField({
    required this.name,
    required this.title,
    this.description,
    this.option,
  });
}

/// Base class for field configuration annotations used in code generation.
///
/// DeskFieldConfig classes are used as annotations (e.g., @DeskText())
/// to mark fields in @DeskModel classes. During build time, the code generator
/// processes these annotations to create:
/// 1. Field configuration lists for the CMS studio UI
/// 2. DeskField instances for runtime field representation
///
/// The optional fields (name, title) allow the generator to fill in default
/// values when not explicitly provided in the annotation.
abstract class DeskFieldConfig {
  const DeskFieldConfig({this.name, this.title, this.option, this.description});

  final String? name;
  final String? title;
  final String? description;
  final DeskOption? option;

  /// The Dart types that this field configuration supports.
  /// Used to validate field type compatibility during code generation.
  List<Type> get supportedFieldTypes;
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run:
```bash
cd packages/dart_desk_annotation && flutter test test/fields/base/desk_condition_test.dart
```
Expected: all 14 tests pass.

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk_annotation/lib/src/fields/base/field.dart \
        packages/dart_desk_annotation/test/fields/base/desk_condition_test.dart
git commit -m "feat(annotation): DeskCondition.evaluate takes DeskConditionContext

Built-ins (FieldEquals/NotEquals/NotNull/IsNull, AllConditions,
AnyCondition) read from ctx.document.activeVersionData. Breaking
change for any third-party DeskCondition subclasses; migration is
mechanical."
```

---

## Task 5: Internal `_GetItConditionContext` in `dart_desk`

**Files:**
- Create: `packages/dart_desk/lib/src/studio/internal/get_it_condition_context.dart`
- Create: `packages/dart_desk/test/studio/internal/get_it_condition_context_test.dart`

- [ ] **Step 1: Write failing tests**

Create `packages/dart_desk/test/studio/internal/get_it_condition_context_test.dart`:

```dart
import 'package:dart_desk/src/studio/core/view_models/desk_document_view_model.dart';
import 'package:dart_desk/src/studio/internal/get_it_condition_context.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:signals/signals_flutter.dart';

class _FakeService {
  final String tag;
  _FakeService(this.tag);
}

class _FakeViewModel implements DeskDocumentViewModel {
  _FakeViewModel(this._doc);
  final DeskDocument? _doc;

  @override
  late final selectedDocument = AwaitableFutureSignal<DeskDocument?>(
    () async => _doc,
  );

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Only selectedDocument is stubbed');
}

void main() {
  setUp(() async {
    if (GetIt.I.isRegistered<DeskDocumentViewModel>()) {
      await GetIt.I.unregister<DeskDocumentViewModel>();
    }
    if (GetIt.I.isRegistered<_FakeService>()) {
      await GetIt.I.unregister<_FakeService>();
    }
  });

  test('document returns the selected document from DeskDocumentViewModel',
      () async {
    final doc = DeskDocument(
      clientId: 'c',
      documentType: 'menuConfig',
      title: 'T',
      isDefault: true,
    );
    final vm = _FakeViewModel(doc);
    GetIt.I.registerSingleton<DeskDocumentViewModel>(vm);
    // Drain the signal so .value.value is populated.
    await vm.selectedDocument.future;

    const ctx = GetItConditionContext();
    expect(ctx.document, equals(doc));
    expect(ctx.document?.isDefault, isTrue);
  });

  test('document is null when no document is selected', () async {
    final vm = _FakeViewModel(null);
    GetIt.I.registerSingleton<DeskDocumentViewModel>(vm);
    await vm.selectedDocument.future;

    const ctx = GetItConditionContext();
    expect(ctx.document, isNull);
  });

  test('read<T>() resolves a registered service', () {
    GetIt.I.registerSingleton<_FakeService>(_FakeService('hello'));
    // No DeskDocumentViewModel needed for this assertion.
    const ctx = GetItConditionContext();
    expect(ctx.read<_FakeService>().tag, 'hello');
  });

  test('read<T>() throws when service is not registered', () {
    const ctx = GetItConditionContext();
    expect(() => ctx.read<_FakeService>(), throwsA(anything));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run:
```bash
cd packages/dart_desk && flutter test test/studio/internal/get_it_condition_context_test.dart
```
Expected: compilation failure — `GetItConditionContext` does not exist.

- [ ] **Step 3: Create the implementation**

```dart
// packages/dart_desk/lib/src/studio/internal/get_it_condition_context.dart
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:get_it/get_it.dart';

import '../core/view_models/desk_document_view_model.dart';

/// Default [DeskConditionContext] used by [DeskForm] when evaluating field
/// conditions. Resolves [document] from the registered
/// [DeskDocumentViewModel] and [read] from the global GetIt container.
///
/// Internal to dart_desk: not exported from `package:dart_desk/dart_desk.dart`.
/// Consumers should depend only on the abstract [DeskConditionContext].
class GetItConditionContext extends DeskConditionContext {
  const GetItConditionContext();

  @override
  DeskDocument? get document =>
      GetIt.I<DeskDocumentViewModel>().selectedDocument.value.value;

  @override
  T read<T extends Object>() => GetIt.I<T>();
}
```

Note: the class is public-to-the-package (no leading underscore) so the test file in `test/` can import it via `package:dart_desk/src/...`. It is intentionally **not** added to the `package:dart_desk/dart_desk.dart` barrel — consumers see only the abstract `DeskConditionContext`.

- [ ] **Step 4: Run the test to verify it passes**

Run:
```bash
cd packages/dart_desk && flutter test test/studio/internal/get_it_condition_context_test.dart
```
Expected: 4 tests pass.

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk/lib/src/studio/internal/get_it_condition_context.dart \
        packages/dart_desk/test/studio/internal/get_it_condition_context_test.dart
git commit -m "feat(dart_desk): add GetItConditionContext internal impl

Backs DeskConditionContext with the existing GetIt container and
DeskDocumentViewModel. Not exported; an implementation detail of
DeskForm."
```

---

## Task 6: Wire `DeskForm` to pass the new context

**Files:**
- Modify: `packages/dart_desk/lib/src/studio/components/forms/desk_form.dart:272-277`
- Create: `packages/dart_desk/test/studio/components/forms/desk_form_condition_test.dart`

- [ ] **Step 1: Write the failing test**

Create `packages/dart_desk/test/studio/components/forms/desk_form_condition_test.dart`:

```dart
import 'package:dart_desk/src/studio/components/forms/desk_form.dart';
import 'package:dart_desk/src/studio/core/view_models/desk_document_view_model.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

class _HideOnDefault extends DeskCondition {
  const _HideOnDefault();
  @override
  bool evaluate(DeskConditionContext ctx) => ctx.document?.isDefault != true;
}

class _FakeViewModel implements DeskDocumentViewModel {
  _FakeViewModel(this._doc);
  final DeskDocument? _doc;
  @override
  late final selectedDocument = AwaitableFutureSignal<DeskDocument?>(
    () async => _doc,
  );
  @override
  noSuchMethod(Invocation i) => throw UnimplementedError();
}

Future<void> _registerVm(DeskDocument? doc) async {
  if (GetIt.I.isRegistered<DeskDocumentViewModel>()) {
    await GetIt.I.unregister<DeskDocumentViewModel>();
  }
  final vm = _FakeViewModel(doc);
  GetIt.I.registerSingleton<DeskDocumentViewModel>(vm);
  await vm.selectedDocument.future;
}

DeskField _gatedField() => const DeskString(
      name: 'deviceOverrideGroups',
      title: 'Device override groups',
      option: DeskTextOption(condition: _HideOnDefault()),
    ).toField();

// _gatedField() above assumes DeskString.toField() exists; adapt if your
// codebase uses a different concrete DeskField subclass for testing. The
// invariant the test asserts is independent of the field type:
// when condition.evaluate(ctx) is false, the field's input is not rendered.

void main() {
  testWidgets('DeskForm hides field when condition.evaluate returns false',
      (tester) async {
    await _registerVm(DeskDocument(
      clientId: 'c',
      documentType: 'menuConfig',
      title: 'Default',
      isDefault: true,
    ));

    await tester.pumpWidget(
      ShadApp(
        home: Scaffold(
          body: DeskForm(
            data: const {},
            fields: [_gatedField()],
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Device override groups'), findsNothing);
  });

  testWidgets('DeskForm shows field when condition.evaluate returns true',
      (tester) async {
    await _registerVm(DeskDocument(
      clientId: 'c',
      documentType: 'menuConfig',
      title: 'Override',
      isDefault: false,
    ));

    await tester.pumpWidget(
      ShadApp(
        home: Scaffold(
          body: DeskForm(
            data: const {},
            fields: [_gatedField()],
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Device override groups'), findsOneWidget);
  });
}
```

If `DeskString` / `DeskTextOption` / `DeskField.toField()` don't exist with these exact names, replace `_gatedField()` with whatever your codebase uses to construct a minimal `DeskField` carrying a `DeskOption` with a `condition`. Look at `packages/dart_desk/test/studio/context_aware_dropdown_test.dart` for a working pattern (`DeskMultiDropdownOption` subclass + a real `DeskMultiDropdown` field). The behavior under test — visibility flips based on `condition.evaluate(ctx)` — is the assertion that matters.

- [ ] **Step 2: Run the test to verify it fails**

Run:
```bash
cd packages/dart_desk && flutter test test/studio/components/forms/desk_form_condition_test.dart
```
Expected: compilation failure on `condition.evaluate(widget.data)` — `widget.data` is a `Map`, not a `DeskConditionContext`. Once the signature lands, the test should pass.

- [ ] **Step 3: Update `DeskForm` to construct and pass the context**

In `packages/dart_desk/lib/src/studio/components/forms/desk_form.dart`, find:

```dart
                    ...widget.fields
                        .where((field) {
                          final condition = field.option?.condition;
                          return condition == null ||
                              condition.evaluate(widget.data);
                        })
```

Replace the `condition.evaluate(widget.data)` call with `condition.evaluate(const GetItConditionContext())`, and add the import at the top of the file:

```dart
import '../../internal/get_it_condition_context.dart';
```

The new where clause:

```dart
                    ...widget.fields
                        .where((field) {
                          final condition = field.option?.condition;
                          return condition == null ||
                              condition.evaluate(const GetItConditionContext());
                        })
```

- [ ] **Step 4: Run the widget test to verify it passes**

Run:
```bash
cd packages/dart_desk && flutter test test/studio/components/forms/desk_form_condition_test.dart
```
Expected: both tests pass. If they fail because of the test scaffold (not the production behavior), fix the scaffold per the note in Step 1.

- [ ] **Step 5: Run the full dart_desk test suite to catch regressions**

Run:
```bash
cd packages/dart_desk && flutter test
```
Expected: all tests pass. Any pre-existing failures unrelated to conditions are out of scope.

- [ ] **Step 6: Commit**

```bash
git add packages/dart_desk/lib/src/studio/components/forms/desk_form.dart \
        packages/dart_desk/test/studio/components/forms/desk_form_condition_test.dart
git commit -m "feat(dart_desk): DeskForm passes DeskConditionContext to evaluate

Replaces the raw data-map argument with a const GetItConditionContext.
Conditions can now read the selected document and any registered
service. Adds widget tests asserting visibility flips based on
ctx.document.isDefault."
```

---

## Task 7: Final repo-wide checks

**Files:** none modified — verification only.

- [ ] **Step 1: Analyze every package**

Run:
```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk
melos exec -- "dart analyze ." || flutter analyze
```
Expected: no analyzer errors introduced by this change.

- [ ] **Step 2: Test every package**

Run:
```bash
melos exec --dir-exists="test" -- "flutter test" || (cd packages/dart_desk_annotation && flutter test && cd ../dart_desk && flutter test)
```
Expected: all tests pass.

- [ ] **Step 3: Confirm no remaining `evaluate(Map<` callsites**

Run:
```bash
grep -rn "\.evaluate(" packages --include="*.dart" | grep -v ".g.dart\|.mapper.dart\|test/"
```
Expected: every hit either passes a `DeskConditionContext` or is unrelated to `DeskCondition`.

- [ ] **Step 4: Confirm `DeskDocument` is not double-defined**

Run:
```bash
grep -rn "^class DeskDocument" packages --include="*.dart"
```
Expected: exactly one match — `packages/dart_desk_annotation/lib/src/data/desk_document.dart`.

---

## Self-Review Notes

**Spec coverage:**
- "DeskDocument relocates" → Task 1 ✓
- "DeskConditionContext abstract class with document + read<T>" → Task 3 ✓
- "DeskCondition.evaluate signature change + built-in migration" → Task 4 ✓
- "Built-in unit tests with fake context" → Task 4 step 1 ✓
- "Private GetIt-backed implementation" → Task 5 ✓
- "Unit test for _GetItConditionContext" → Task 5 step 1 ✓
- "DeskForm widget test for visibility flip" → Task 6 step 1 ✓
- "GetIt remains internal; not exported" → Task 5 step 3 (no barrel export) ✓
- "dart_desk re-exports DeskDocument for backward compat" → Task 1 step 5 ✓

**Out-of-scope (per spec):** HG-side `HideWhenDefaultDocument` wiring — handled in a follow-up plan in the `hg_mobile_app` worktree once this dart_desk patch ships.
