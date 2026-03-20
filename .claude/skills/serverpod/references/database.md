# Serverpod Database Reference

## Table of Contents
- [ORM Basics](#orm-basics)
- [Querying Data](#querying-data)
- [Filter Operators](#filter-operators)
- [Sorting and Pagination](#sorting-and-pagination)
- [Relations and Eager Loading](#relations-and-eager-loading)
- [Transactions](#transactions)
- [Counting](#counting)
- [Raw SQL](#raw-sql)
- [Migrations](#migrations)
- [Index Types](#index-types)

## ORM Basics

Every model with a `table` field gets a static `db` accessor for ORM operations.

### Insert

```dart
// Single row
final user = await User.db.insertRow(session, User(name: 'Alice', email: 'alice@example.com'));

// Multiple rows
final users = await User.db.insert(session, [user1, user2, user3]);
```

### Update

```dart
user.name = 'Alice Updated';
final updated = await User.db.updateRow(session, user);

// Multiple rows
await User.db.update(session, [user1, user2]);
```

### Delete

```dart
// Single row
await User.db.deleteRow(session, user);

// By condition
final deletedRows = await User.db.deleteWhere(
  session,
  where: (t) => t.email.like('%@old-domain.com'),
);

// Multiple specific rows
await User.db.delete(session, [user1, user2]);
```

## Querying Data

### find

```dart
final users = await User.db.find(
  session,
  where: (t) => t.name.like('A%'),
  orderBy: (t) => t.name,
  orderDescending: false,
  limit: 20,
  offset: 0,
);
```

### findById

```dart
final user = await User.db.findById(session, 42);
// Returns null if not found
```

### findFirstRow

```dart
final user = await User.db.findFirstRow(
  session,
  where: (t) => t.email.equals('alice@example.com'),
);
```

## Filter Operators

### Comparison

```dart
where: (t) => t.age.equals(25)
where: (t) => t.age.notEquals(25)
where: (t) => t.age > 18
where: (t) => t.age >= 18
where: (t) => t.age < 65
where: (t) => t.age <= 65
```

### String Operations

```dart
where: (t) => t.name.like('A%')        // SQL LIKE (case-sensitive)
where: (t) => t.name.ilike('a%')       // Case-insensitive LIKE
where: (t) => t.email.equals('a@b.com')
```

### Null Checks

```dart
where: (t) => t.deletedAt.equals(null)    // IS NULL
where: (t) => t.deletedAt.notEquals(null)  // IS NOT NULL
```

### Set Operations

```dart
where: (t) => t.status.inSet({'active', 'pending'})
where: (t) => t.status.notInSet({'deleted', 'banned'})
```

### Between

```dart
where: (t) => t.age.between(18, 65)
where: (t) => t.createdAt.between(startDate, endDate)
```

### Combining Conditions

```dart
// AND
where: (t) => t.name.like('A%') & t.age > 18

// OR
where: (t) => (t.status.equals('active')) | (t.status.equals('pending'))

// Complex
where: (t) => (t.name.like('A%') & t.age > 18) | t.isAdmin.equals(true)
```

### Relation Filters

```dart
// Has related record
where: (t) => t.company.has()

// Filter by related field
where: (t) => t.company.has((c) => c.name.equals('Acme'))

// Count related records
where: (t) => t.employees.count() > 5
```

## Sorting and Pagination

### OrderBy

```dart
final users = await User.db.find(
  session,
  orderBy: (t) => t.name,
  orderDescending: false,  // ASC (default)
);
```

### Multiple Sort Columns

```dart
final users = await User.db.find(
  session,
  orderByList: (t) => [
    OrderByColumn(column: t.lastName),
    OrderByColumn(column: t.firstName),
  ],
);
```

### Pagination

```dart
final page = await User.db.find(
  session,
  limit: 20,
  offset: 40,  // Skip first 40 rows (page 3)
  orderBy: (t) => t.id,
);
```

## Relations and Eager Loading

### Include (Eager Loading)

```dart
// Load company with its CEO
final company = await Company.db.findById(
  session, id,
  include: Company.include(
    ceo: Employee.include(),
  ),
);
print(company?.ceo?.name);

// Nested includes
final company = await Company.db.findById(
  session, id,
  include: Company.include(
    ceo: Employee.include(
      address: Address.include(),
    ),
  ),
);
```

### Include List (One-to-Many)

```dart
final company = await Company.db.findById(
  session, id,
  include: Company.include(
    employees: Employee.includeList(),
  ),
);
for (final emp in company?.employees ?? []) {
  print(emp.name);
}
```

### Filtered Include List

```dart
final company = await Company.db.findById(
  session, id,
  include: Company.include(
    employees: Employee.includeList(
      where: (t) => t.isActive.equals(true),
      orderBy: (t) => t.name,
      limit: 10,
    ),
  ),
);
```

## Transactions

```dart
await session.db.transaction((transaction) async {
  // All operations within share the same transaction
  final company = await Company.db.insertRow(
    session, Company(name: 'Acme'),
    transaction: transaction,
  );

  await Employee.db.insertRow(
    session,
    Employee(name: 'Alice', companyId: company.id),
    transaction: transaction,
  );

  // If any operation throws, all are rolled back
});
```

### Nested Transactions (Savepoints)

```dart
await session.db.transaction((outerTx) async {
  await User.db.insertRow(session, user1, transaction: outerTx);

  try {
    await session.db.transaction((innerTx) async {
      await User.db.insertRow(session, user2, transaction: innerTx);
      throw Exception('Rollback inner only');
    });
  } catch (_) {
    // Inner transaction rolled back, outer continues
  }

  await User.db.insertRow(session, user3, transaction: outerTx);
  // user1 and user3 committed, user2 rolled back
});
```

## Counting

```dart
final total = await User.db.count(session);

final activeCount = await User.db.count(
  session,
  where: (t) => t.status.equals('active'),
);
```

## Raw SQL

For queries that can't be expressed with the ORM.

### Select Queries

```dart
final result = await session.db.unsafeQuery(
  'SELECT * FROM "user" WHERE age > @age ORDER BY name',
  parameters: QueryParameters.named({'age': 18}),
);

for (final row in result) {
  print(row[0]); // Access by column index
}
```

### Execute (INSERT/UPDATE/DELETE)

```dart
final affectedRows = await session.db.unsafeExecute(
  'UPDATE "user" SET status = @status WHERE last_login < @date',
  parameters: QueryParameters.named({
    'status': 'inactive',
    'date': DateTime.now().subtract(Duration(days: 90)),
  }),
);
```

### Parameter Binding

Always use parameterized queries to prevent SQL injection:

```dart
// CORRECT - parameterized
await session.db.unsafeQuery(
  'SELECT * FROM "user" WHERE name = @name',
  parameters: QueryParameters.named({'name': userInput}),
);

// WRONG - string interpolation (SQL injection risk)
await session.db.unsafeQuery('SELECT * FROM "user" WHERE name = \'$userInput\'');
```

### Positional Parameters

```dart
await session.db.unsafeQuery(
  'SELECT * FROM "user" WHERE age > \$1 AND status = \$2',
  parameters: QueryParameters.positional([18, 'active']),
);
```

## Migrations

### Creating Migrations

```bash
# After model changes
serverpod create-migration

# Repair after conflicts
serverpod create-migration --repair

# Force recreate all migrations
serverpod create-migration --force
```

### Migration Structure

Migrations live in `migrations/` and are applied in order on server start.

```
migrations/
├── 20240101120000000/
│   ├── migration.yaml
│   └── definition.yaml
└── 20240102150000000/
    ├── migration.yaml
    └── definition.yaml
```

### Applying Migrations

Migrations are auto-applied on server start. To apply manually:

```bash
serverpod apply-migrations
```

### Migration Tags

Tag migrations in production to track which have been applied:

```bash
serverpod create-migration --tag v1.0.0
```

## Index Types

Define indexes in model YAML:

```yaml
indexes:
  user_email_idx:
    fields: email
    unique: true
    type: btree
```

### Available Index Types

| Type | Best For | Notes |
|------|----------|-------|
| `btree` | Range queries, sorting, equality | Default. Most common choice |
| `hash` | Exact equality only | Slightly faster than btree for equality, no range support |
| `gin` | Full-text search, arrays, JSONB | Generalized Inverted Index |
| `gist` | Geometric, spatial, range types | Generalized Search Tree |
| `brin` | Very large, naturally ordered tables | Block Range Index, very compact |

### Index Naming Convention

Use descriptive names: `<table>_<fields>_idx`

```yaml
indexes:
  user_email_idx:
    fields: email
    unique: true
  user_company_name_idx:
    fields: companyId, name
  user_created_at_idx:
    fields: createdAt
    type: brin    # Good for timestamp columns in large tables
```

### Composite Indexes

```yaml
indexes:
  order_status_date_idx:
    fields: status, createdAt
    # Column order matters: put most selective column first
```
