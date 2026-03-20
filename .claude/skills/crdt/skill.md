# CRDT Skill

This skill provides expertise in implementing Conflict-free Replicated Data Types (CRDTs) for collaborative editing in Dart/Flutter applications, specifically integrated with Serverpod backends.

## When to Use This Skill

Activate this skill when:
- Implementing real-time collaborative editing features
- Working with CRDT-based data synchronization
- Building offline-first applications with eventual consistency
- Integrating the `crdt` package with Serverpod
- Designing conflict resolution strategies
- Implementing operational transformation systems
- Optimizing CRDT operation logs and compaction
- Questions about CRDT architecture or best practices

## Key Concepts

### What are CRDTs?

**Conflict-free Replicated Data Types** are data structures that:
- Allow multiple replicas to be updated independently
- Automatically merge concurrent updates without conflicts
- Guarantee eventual consistency across all replicas
- Don't require coordination or consensus protocols

### Core CRDT Components

1. **Hybrid Logical Clock (HLC)**: Provides causally-consistent timestamps
2. **Operations**: Individual changes (put, delete) applied to the data
3. **Merge Function**: Automatically resolves conflicts (last-write-wins)
4. **State**: Current merged view of all operations

## CRDT Packages in Dart

### `crdt` Package (v5.1.3)

**Best for**: General CRDT implementation with flexible storage backends

**Key Features**:
- Production-proven (1M+ installs - Libra app)
- Minimal dependencies, runs everywhere Dart runs
- MapCrdt for key-value data structures
- PostgreSQL backend available (`postgres_crdt`)
- HLC-based conflict resolution

**Basic Usage**:
```dart
import 'package:crdt/crdt.dart';

// Generate HLC timestamp
final hlc = Hlc.now('node-id');

// Increment for next operation
final nextHlc = hlc.increment();

// Parse from string
final parsed = Hlc.parse('1701234567890000-node-01');
```

### `crdt_lf` Package

**Best for**: Text editing with Fugue algorithm, operation-based sync

**Not Recommended For**:
- Flexible JSON documents (our use case)
- Production backends (still in development)
- PostgreSQL storage (no direct adapter)

## Architecture Patterns

### 1. Single-Node CRDT (Recommended for Serverpod)

**Pattern**: Serverpod backend acts as single CRDT node, clients are consumers

```
┌─────────┐    ┌─────────┐    ┌─────────┐
│Client A │    │Client B │    │Client C │
└────┬────┘    └────┬────┘    └────┬────┘
     │              │              │
     └──────────────┼──────────────┘
                    │
              ┌─────▼─────┐
              │ Serverpod │  (Single CRDT Node)
              │  Backend  │
              └───────────┘
                    │
              ┌─────▼─────┐
              │PostgreSQL │
              └───────────┘
```

**Advantages**:
- Simpler to implement and reason about
- All operations coordinated through single source
- Easier to debug and monitor
- Still enables real-time collaboration between clients

**Node ID Strategy**:
```dart
// Based on Serverpod discussion #2084:
// nodeId should represent the DATABASE, not server instances
final nodeId = Platform.environment['CRDT_NODE_ID'] ?? 'postgres-main';
```

### 2. Multi-Node CRDT (Advanced)

**Pattern**: Multiple backend servers sync between themselves

```
┌─────────┐    ┌─────────┐
│ Server  │◄──►│ Server  │
│ Node 1  │    │ Node 2  │
└─────────┘    └─────────┘
     │              │
     └──────┬───────┘
            │
    ┌───────▼────────┐
    │   PostgreSQL   │
    │  (distributed) │
    └────────────────┘
```

**Use When**:
- Horizontal scaling required
- Multi-region deployment
- High availability needed

**Additional Complexity**:
- Requires sync mechanism between nodes
- More complex conflict scenarios
- Network partition handling

## JSON Document CRDT Strategy

### Flatten to Dot-Notation

**Why**: Enable field-level CRDT tracking instead of document-level

**Example**:
```dart
// Original JSON
{
  "title": "My Blog",
  "metadata": {
    "author": "John",
    "tags": ["tech", "tutorial"]
  }
}

// Flattened for CRDT
{
  "title": "My Blog",
  "metadata.author": "John",
  "metadata.tags": ["tech", "tutorial"]  // JSON encoded
}
```

**Benefits**:
- Users can edit different fields simultaneously without conflicts
- Only changed fields create operations
- Fine-grained conflict resolution

**Implementation**:
```dart
Map<String, dynamic> _flattenMap(
  Map<String, dynamic> map,
  [String prefix = '']
) {
  final result = <String, dynamic>{};

  for (var entry in map.entries) {
    final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';

    if (entry.value is Map<String, dynamic>) {
      // Recursively flatten nested maps
      result.addAll(_flattenMap(entry.value, key));
    } else {
      // Store primitives and arrays as-is
      result[key] = entry.value;
    }
  }

  return result;
}
```

### Conflict Resolution: Last-Write-Wins

**Based on HLC timestamps**:

```dart
// User A @ HLC 1000-node-01
{"title": "Version A"}

// User B @ HLC 1001-node-01  (later)
{"title": "Version B"}

// Result: "Version B" wins (higher HLC)
```

**Same field, different users**:
- Compare HLC timestamps lexicographically
- Later timestamp wins
- Deterministic across all nodes

**Different fields**:
- No conflict - both changes merge
- Independent operations

## Database Schema Design

### Operations Table

```yaml
class: DocumentCrdtOperation
table: document_crdt_operations
fields:
  documentId: int, relation(parent=documents, onDelete=Cascade)
  hlc: String  # Lexicographically sortable timestamp
  nodeId: String  # Node that created operation
  operationType: CrdtOperationType  # enum: put, delete
  fieldPath: String  # Dot-notation: "metadata.author"
  fieldValue: String?  # JSON-encoded value
  createdAt: DateTime?
  createdByUserId: int?
indexes:
  - fields: [documentId, hlc]  # Critical for queries
  - fields: [documentId]
  - fields: [createdAt]
```

**Why String for HLC**:
- Lexicographic comparison works for range queries
- PostgreSQL can index and sort efficiently
- No need to parse for most operations

### Snapshots Table (Performance Optimization)

```yaml
class: DocumentCrdtSnapshot
table: document_crdt_snapshots
fields:
  documentId: int
  snapshotHlc: String  # HLC when snapshot created
  snapshotData: String  # Complete JSON document
  operationCountAtSnapshot: int
  createdAt: DateTime?
indexes:
  - fields: [documentId, snapshotHlc]
    unique: true
```

**Purpose**:
- Prevent unbounded growth of operation log
- Fast state reconstruction (load snapshot + replay recent ops)
- Create when operation count exceeds threshold (e.g., 1000)

### Document Table

```yaml
class: Document
fields:
  data: String  # Latest merged CRDT state (cached)
  crdtNodeId: String  # CRDT node identifier
  crdtHlc: String  # Current HLC timestamp
  # ... other fields
```

**`data` field**: Denormalized cache of latest state for fast reads

## Core Service Implementation

### CRDT Service Structure

```dart
class DocumentCrdtService {
  final String nodeId;

  DocumentCrdtService(this.nodeId);

  // Initialize CRDT from initial data
  Future<void> initializeCrdt(
    Session session,
    int documentId,
    Map<String, dynamic> initialData,
  );

  // Apply partial updates (only changed fields)
  Future<Document> applyOperations(
    Session session,
    int documentId,
    Map<String, dynamic> updates,
    String sessionId,
  );

  // Get current merged state
  Future<Map<String, dynamic>> getCurrentState(
    Session session,
    int documentId,
  );

  // Reconstruct state at specific HLC (version history)
  Future<Map<String, dynamic>> getStateAtHlc(
    Session session,
    int documentId,
    String targetHlc,
  );

  // Compact operations into snapshot
  Future<void> compactOperations(
    Session session,
    int documentId,
    {int threshold = 1000},
  );
}
```

### Initialize CRDT

```dart
Future<void> initializeCrdt(
  Session session,
  int documentId,
  Map<String, dynamic> initialData,
) async {
  // Generate initial HLC
  final hlc = Hlc.now(nodeId);
  final hlcString = hlc.toString();

  // Flatten JSON to dot-notation
  final flatData = _flattenMap(initialData);

  // Create operation for each field
  for (var entry in flatData.entries) {
    final operation = DocumentCrdtOperation(
      documentId: documentId,
      hlc: hlcString,
      nodeId: nodeId,
      operationType: CrdtOperationType.put,
      fieldPath: entry.key,
      fieldValue: jsonEncode(entry.value),
      createdAt: DateTime.now(),
    );

    await DocumentCrdtOperation.db.insertRow(session, operation);
  }

  // Update document with CRDT metadata
  final doc = await Document.db.findById(session, documentId);
  final updated = doc!.copyWith(
    crdtNodeId: nodeId,
    crdtHlc: hlcString,
  );
  await Document.db.updateRow(session, updated);
}
```

### Apply Operations

```dart
Future<Document> applyOperations(
  Session session,
  int documentId,
  Map<String, dynamic> updates,
  String sessionId,
) async {
  final doc = await Document.db.findById(session, documentId);

  // Increment HLC from current
  final currentHlc = doc!.crdtHlc != null ? Hlc.parse(doc.crdtHlc!) : null;
  final newHlc = currentHlc?.increment() ?? Hlc.now(nodeId);
  final hlcString = newHlc.toString();

  // Create peer ID for attribution
  final peerId = '$nodeId:$sessionId';

  // Flatten updates
  final flatUpdates = _flattenMap(updates);

  // Create operations for each changed field
  for (var entry in flatUpdates.entries) {
    final operation = DocumentCrdtOperation(
      documentId: documentId,
      hlc: hlcString,
      nodeId: peerId,
      operationType: CrdtOperationType.put,
      fieldPath: entry.key,
      fieldValue: jsonEncode(entry.value),
      createdAt: DateTime.now(),
    );

    await DocumentCrdtOperation.db.insertRow(session, operation);
  }

  // Rebuild current state
  final currentState = await getCurrentState(session, documentId);

  // Update document's data cache
  final updated = doc.copyWith(
    data: jsonEncode(currentState),
    crdtHlc: hlcString,
    updatedAt: DateTime.now(),
  );

  await Document.db.updateRow(session, updated);

  return updated;
}
```

### Reconstruct State

```dart
Future<Map<String, dynamic>> getCurrentState(
  Session session,
  int documentId,
) async {
  // Load most recent snapshot (optimization)
  final snapshots = await DocumentCrdtSnapshot.db.find(
    session,
    where: (t) => t.documentId.equals(documentId),
    orderBy: (t) => t.snapshotHlc,
    orderDescending: true,
    limit: 1,
  );

  Map<String, dynamic> flatState = {};
  String sinceHlc = '0';

  if (snapshots.isNotEmpty) {
    final snapshotData = jsonDecode(snapshots.first.snapshotData);
    flatState = _flattenMap(snapshotData);
    sinceHlc = snapshots.first.snapshotHlc;
  }

  // Get operations since snapshot using raw SQL
  // (HLC string comparison)
  final operations = await session.db.query(
    'SELECT * FROM document_crdt_operations '
    'WHERE "documentId" = @documentId AND hlc > @sinceHlc '
    'ORDER BY hlc ASC',
    parameters: QueryParameters.named({
      'documentId': documentId,
      'sinceHlc': sinceHlc,
    }),
  );

  // Apply operations to state
  for (var row in operations) {
    final op = DocumentCrdtOperation.fromJson(row.toColumnMap());
    if (op.operationType == CrdtOperationType.put && op.fieldValue != null) {
      flatState[op.fieldPath] = jsonDecode(op.fieldValue!);
    } else if (op.operationType == CrdtOperationType.delete) {
      flatState.remove(op.fieldPath);
    }
  }

  // Unflatten to nested structure
  return _unflattenMap(flatState);
}
```

### Compaction

```dart
Future<void> compactOperations(
  Session session,
  int documentId,
  {int threshold = 1000},
) async {
  final opCount = await getOperationCount(session, documentId);

  if (opCount > threshold) {
    // Get current state and HLC
    final currentState = await getCurrentState(session, documentId);
    final doc = await Document.db.findById(session, documentId);
    final currentHlc = doc!.crdtHlc!;

    // Create snapshot
    final snapshot = DocumentCrdtSnapshot(
      documentId: documentId,
      snapshotHlc: currentHlc,
      snapshotData: jsonEncode(currentState),
      operationCountAtSnapshot: opCount,
      createdAt: DateTime.now(),
    );

    await DocumentCrdtSnapshot.db.insertRow(session, snapshot);

    // Delete operations older than snapshot
    await session.db.query(
      'DELETE FROM document_crdt_operations '
      'WHERE "documentId" = @documentId AND hlc < @hlc',
      parameters: QueryParameters.named({
        'documentId': documentId,
        'hlc': currentHlc,
      }),
    );

    session.log('Compacted $opCount operations for document $documentId');
  }
}
```

## Real-Time Collaboration Patterns

### Polling Strategy

**Client Flow**:
1. Client opens document, stores current HLC
2. Poll every 2-5 seconds: `getOperationsSince(lastKnownHlc)`
3. Server returns operations with `hlc > lastKnownHlc`
4. Client applies operations to local view
5. Update `lastKnownHlc` to latest received

**Endpoint**:
```dart
Future<List<DocumentCrdtOperation>> getOperationsSince(
  Session session,
  int documentId,
  String sinceHlc,
  {int limit = 100},
) async {
  final allOps = await DocumentCrdtOperation.db.find(
    session,
    where: (t) => t.documentId.equals(documentId),
    orderBy: (t) => t.hlc,
    limit: 1000,
  );

  // Filter by HLC (lexicographic comparison)
  final filtered = allOps
    .where((op) => op.hlc.compareTo(sinceHlc) > 0)
    .toList();

  return filtered.take(limit).toList();
}
```

### Submit Edit

```dart
Future<Document> submitEdit(
  Session session,
  int documentId,
  String sessionId,
  Map<String, dynamic> fieldUpdates,
) async {
  return await documentCrdtService.applyOperations(
    session,
    documentId,
    fieldUpdates,  // Only changed fields!
    sessionId,
  );
}
```

**Client Side**:
```dart
// Optimistic UI update
updateLocalView({"title": "New Title"});

// Submit to server (debounced)
await client.collaboration.submitEdit(
  documentId,
  sessionId,
  {"title": "New Title"},  // Partial update
);
```

### Active Editors (Presence)

```dart
Future<List<Map<String, dynamic>>> getActiveEditors(
  Session session,
  int documentId,
) async {
  final fiveMinutesAgo = DateTime.now().subtract(Duration(minutes: 5));

  final recentOps = await DocumentCrdtOperation.db.find(
    session,
    where: (t) => t.documentId.equals(documentId),
    orderBy: (t) => t.createdAt,
    orderDescending: true,
    limit: 500,
  );

  // Group by user, find latest edit per user
  final userEdits = <int, DateTime>{};
  for (var op in recentOps) {
    if (op.createdAt != null &&
        op.createdAt!.isAfter(fiveMinutesAgo) &&
        op.createdByUserId != null) {
      final userId = op.createdByUserId!;
      if (!userEdits.containsKey(userId) ||
          op.createdAt!.isAfter(userEdits[userId]!)) {
        userEdits[userId] = op.createdAt!;
      }
    }
  }

  // Return list of active users
  return userEdits.entries
    .map((e) => {'userId': e.key, 'lastEdit': e.value.toIso8601String()})
    .toList();
}
```

## Performance Optimization

### When to Compact

**Triggers**:
1. **Operation count threshold**: When ops > 1000
2. **Time-based**: Daily/weekly scheduled job
3. **Manual**: Admin trigger when needed

**Compaction Strategy**:
```dart
// Check after each operation batch
if (await getOperationCount(session, documentId) > 1000) {
  await compactOperations(session, documentId);
}
```

**Background Job** (Serverpod Future Call):
```dart
class CrdtCompactionJob extends FutureCall {
  @override
  Future<void> invoke(Session session, SerializableEntity? object) async {
    // Find all documents needing compaction
    final heavyDocs = await session.db.unsafeQuery(
      'SELECT "documentId", COUNT(*) as op_count '
      'FROM document_crdt_operations '
      'GROUP BY "documentId" '
      'HAVING COUNT(*) > 1000'
    );

    for (var row in heavyDocs) {
      final documentId = row[0] as int;
      await documentCrdtService.compactOperations(session, documentId);
    }
  }
}
```

### Query Optimization

**Critical Index**:
```sql
CREATE INDEX document_crdt_operations_document_hlc_idx
  ON document_crdt_operations("documentId", hlc);
```

**Why**: Enables efficient range queries on HLC strings

**Query Pattern**:
```sql
-- Fast with composite index
SELECT * FROM document_crdt_operations
WHERE "documentId" = 123 AND hlc > '1701234567890000-node-01'
ORDER BY hlc ASC;
```

### Serverpod Raw SQL Queries

**Important**: Serverpod database query methods vary by context

**In Services** (has access to QueryParameters):
```dart
final results = await session.db.query(
  'SELECT * FROM table WHERE id = @id',
  parameters: QueryParameters.named({'id': id}),
);
```

**In Endpoints** (use positional parameters with unsafeQuery):
```dart
final results = await session.db.unsafeQuery(
  'SELECT * FROM table WHERE id = \$1',
  [id],
);
```

**No Parameters** (both work):
```dart
final results = await session.db.unsafeQuery(
  'SELECT DISTINCT type FROM documents'
);
```

## Best Practices

### 1. Always Use Enums

```dart
enum CrdtOperationType {
  put,
  delete,
}

// NOT strings:
// operationType: 'put'  ❌
// operationType: CrdtOperationType.put  ✅
```

### 2. Partial Updates Only

```dart
// Good: Only changed fields
await submitEdit(docId, sessionId, {
  "title": "New Title"  // Only this field changed
});

// Bad: Sending entire document
await submitEdit(docId, sessionId, {
  "title": "New Title",
  "author": "John",  // Unchanged
  "content": "...",  // Unchanged
});
```

### 3. Optimistic UI Updates

```dart
// 1. Update UI immediately
updateLocalView(changes);

// 2. Submit to server (debounced)
debouncer.run(() => submitEdit(changes));

// 3. Poll for other users' changes
pollTimer.periodic(() => getOperationsSince(lastHlc));
```

### 4. Handle Arrays Carefully

**Current Implementation**: Arrays are JSON-encoded strings
- Last-write-wins on entire array
- No per-element CRDT

**Future Enhancement**: Implement CRDT arrays
- Use position-based operations
- Enable collaborative list editing

### 5. Monitor Operation Growth

```dart
// Log warnings
if (opCount > 5000) {
  session.log(
    'WARNING: Document $documentId has $opCount operations',
    level: LogLevel.warning,
  );
}

// Alert on excessive growth
if (opCount > 10000) {
  // Trigger immediate compaction or alert admins
}
```

### 6. Test Concurrent Edits

```dart
test('Concurrent edits on different fields merge correctly', () async {
  // User A edits title
  await submitEdit(docId, 'session-a', {'title': 'Title A'});

  // User B edits author (concurrent)
  await submitEdit(docId, 'session-b', {'author': 'Author B'});

  // Both changes should be present
  final doc = await getDocument(docId);
  final data = jsonDecode(doc.data);
  expect(data['title'], 'Title A');
  expect(data['author'], 'Author B');
});

test('Concurrent edits on same field - last write wins', () async {
  // Both edit title concurrently
  await submitEdit(docId, 'session-a', {'title': 'Title A'});
  await submitEdit(docId, 'session-b', {'title': 'Title B'});

  // Last HLC wins (deterministic based on timestamp)
  final doc = await getDocument(docId);
  final data = jsonDecode(doc.data);
  // Result depends on HLC ordering
});
```

## Common Issues & Solutions

### Issue 1: Operation Log Growing Too Large

**Symptoms**:
- Slow state reconstruction
- Large database size
- Slow queries

**Solution**:
```dart
// Implement aggressive compaction
await compactOperations(session, documentId, threshold: 500);

// Or schedule more frequent compaction jobs
```

### Issue 2: HLC Comparison Not Working

**Symptoms**:
- Operations in wrong order
- Conflicts not resolving correctly

**Cause**: HLC strings not lexicographically sortable

**Solution**: Ensure HLC format is consistent:
```dart
// Format: {timestamp}-{nodeId}
// Example: "1701234567890000-postgres-main"

// Lexicographic comparison works:
"1701234567890000-node-01".compareTo("1701234567890001-node-01") < 0  // true
```

### Issue 3: Serverpod Query Method Confusion

**Symptoms**:
- "query method not found"
- "substitutionValues not defined"

**Solution**: Use correct method for context:
```dart
// Services: QueryParameters.named
await session.db.query(
  'SELECT * FROM table WHERE id = @id',
  parameters: QueryParameters.named({'id': id}),
);

// Endpoints: Positional with unsafeQuery
await session.db.unsafeQuery(
  'SELECT * FROM table WHERE id = \$1',
  [id],
);
```

### Issue 4: Node ID Per-Server vs Per-Database

**Symptoms**:
- Multiple servers creating different CRDT states
- Sync issues in clustered deployments

**Solution**: Node ID represents the DATABASE ([from Serverpod #2084](https://github.com/serverpod/serverpod/discussions/2084))
```dart
// Wrong: Different per server instance
final nodeId = 'server-${serverInstanceId}';  ❌

// Correct: Same for all servers using same database
final nodeId = 'postgres-main';  ✅
```

## Related Resources

- **crdt package**: https://pub.dev/packages/crdt
- **Serverpod discussion**: https://github.com/serverpod/serverpod/discussions/2084
- **HLC paper**: "Logical Physical Clocks and Consistent Snapshots"
- **CRDT theory**: https://crdt.tech/

## Example: Complete CRDT Flow

```dart
// 1. Create document with CRDT
final doc = await client.document.createDocument(
  'blog',
  'My Post',
  {'title': 'Hello', 'content': 'World'},
);

// 2. User A edits title
await client.collaboration.submitEdit(
  doc.id!,
  'session-user-a',
  {'title': 'Hello CRDT!'},  // Partial update
);

// 3. User B edits content (concurrent)
await client.collaboration.submitEdit(
  doc.id!,
  'session-user-b',
  {'content': 'CRDT is awesome'},  // Different field
);

// 4. User A polls for updates
final lastKnownHlc = '1701234567890000-postgres-main';
final newOps = await client.collaboration.getOperationsSince(
  doc.id!,
  lastKnownHlc,
);

// 5. User A sees User B's changes
for (var op in newOps) {
  applyOperationToLocalView(op);
}

// 6. Check who's editing
final editors = await client.collaboration.getActiveEditors(doc.id!);
// Returns: [{'userId': 123, 'lastEdit': '2024-...'}, ...]

// 7. System auto-compacts when needed
// (happens automatically at 1000 operations)
```

---

**Remember**: CRDTs provide eventual consistency with automatic conflict resolution, perfect for collaborative editing where network partitions and concurrent updates are common!
