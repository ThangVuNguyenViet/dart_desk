# Serverpod Models Reference

## Table of Contents
- [Basic Model Definition](#basic-model-definition)
- [Field Types](#field-types)
- [Field Scopes](#field-scopes)
- [Default Values](#default-values)
- [Database Models](#database-models)
- [Relations](#relations)
- [Indexes](#indexes)
- [Enums](#enums)
- [Exceptions](#exceptions)

## Basic Model Definition

Models are defined as YAML files in `lib/src/models/`.

```yaml
# user.yaml
class: User
fields:
  name: String
  email: String
  age: int?        # Nullable field
  tags: List<String>
```

This generates a serializable Dart class. Run `serverpod generate` after changes.

## Field Types

| Type | Example |
|------|---------|
| `int`, `double`, `bool` | `age: int` |
| `String` | `name: String` |
| `DateTime` | `createdAt: DateTime` |
| `Duration` | `timeout: Duration` |
| `UuidValue` | `uuid: UuidValue` |
| `ByteData` | `data: ByteData` |
| `Uri` | `website: Uri` |
| `List<T>` | `tags: List<String>` |
| `Map<String, T>` | `metadata: Map<String, String>` |
| Custom classes | `address: Address` |
| Enums | `status: UserStatus` |

Append `?` for nullable: `email: String?`

## Field Scopes

Control where fields are available:

```yaml
class: User
fields:
  name: String                    # Default: 'all' for non-table, 'database' for table models
  email: String, scope=all        # Available everywhere
  password: String, scope=database  # Server + database only, not sent to client
  token: String, scope=api        # Server + client, not stored in database
  internal: String, scope=none    # Server only
```

| Scope | Database | Server | Client |
|-------|----------|--------|--------|
| `all` | Yes | Yes | Yes |
| `database` | Yes | Yes | No |
| `api` | No | Yes | Yes |
| `none` | No | Yes | No |

## Default Values

```yaml
class: UserSettings
fields:
  theme: String, default='light'
  notifications: bool, default=true
  maxItems: int, default=10
  score: double, default=0.0
  createdAt: DateTime, default=now   # Current timestamp
```

Persist defaults ensure database columns have default values:
```yaml
fields:
  status: String, default=persist='active'
```

## Database Models

Add `table` to persist to PostgreSQL:

```yaml
class: Company
table: company
fields:
  name: String
  orgNumber: String?
```

This adds:
- An auto-incrementing `id` field (integer primary key)
- Database table creation via migrations
- Static `db` accessor for ORM operations (`Company.db.find(...)`)

## Relations

### One-to-One

```yaml
# citizen.yaml
class: Citizen
table: citizen
fields:
  name: String
  address: Address?, relation(name=citizen_address)

# address.yaml
class: Address
table: address
fields:
  street: String
  citizen: Citizen?, relation(name=citizen_address)
```

### One-to-Many

```yaml
# company.yaml
class: Company
table: company
fields:
  name: String
  employees: List<Employee>?, relation(name=company_employees)

# employee.yaml
class: Employee
table: employee
fields:
  name: String
  company: Company?, relation(name=company_employees)
  companyId: int?    # Foreign key (auto-managed)
```

### Many-to-Many (via junction table)

```yaml
# student.yaml
class: Student
table: student
fields:
  name: String
  enrollments: List<Enrollment>?, relation(name=student_enrollment)

# course.yaml
class: Course
table: course
fields:
  name: String
  enrollments: List<Enrollment>?, relation(name=course_enrollment)

# enrollment.yaml (junction)
class: Enrollment
table: enrollment
fields:
  student: Student?, relation(name=student_enrollment)
  studentId: int?
  course: Course?, relation(name=course_enrollment)
  courseId: int?
```

### Self-Referencing Relations

```yaml
class: Category
table: category
fields:
  name: String
  parent: Category?, relation(name=category_parent, optional)
  parentId: int?
  children: List<Category>?, relation(name=category_parent)
```

### Relation Options

- `relation(name=relation_name)` - Names the relation (required for matching both sides)
- `relation(parent=table_name)` - Specifies which table holds the foreign key
- `relation(optional)` - Makes the relation optional (nullable foreign key, `ON DELETE SET NULL`)
- Without `optional`: `ON DELETE CASCADE` by default

### Foreign Key Fields

For relations, the foreign key field is auto-managed. Name it `<relation>Id`:

```yaml
fields:
  company: Company?, relation(name=company_employees)
  companyId: int?   # Auto-populated foreign key
```

## Indexes

```yaml
class: User
table: user
fields:
  email: String
  name: String
  company: Company?, relation(name=company_users)
  companyId: int?
indexes:
  user_email_idx:
    fields: email
    unique: true
  user_company_name_idx:
    fields: companyId, name
    type: btree         # Default. Options: btree, hash, gin, gist, brin
```

### Index Types

| Type | Use Case |
|------|----------|
| `btree` | Default. Range queries, sorting, equality |
| `hash` | Exact equality lookups only |
| `gin` | Full-text search, array containment, JSONB |
| `gist` | Geometric/spatial data, range types |
| `brin` | Very large tables with naturally ordered data |

## Enums

```yaml
# status.yaml
enum: UserStatus
values:
  - active
  - inactive
  - suspended
```

Use in models:
```yaml
fields:
  status: UserStatus
```

### Serialized Enums

```yaml
enum: Animal
serialized: byName    # or byIndex (default)
values:
  - dog
  - cat
  - bird
```

## Exceptions

Define serializable exceptions for typed client error handling:

```yaml
# not_found_exception.yaml
exception: NotFoundException
fields:
  message: String
  resourceType: String
```

Throw from endpoints:
```dart
throw NotFoundException(message: 'User not found', resourceType: 'User');
```

Catch on client:
```dart
try {
  await client.user.find(id: 999);
} on NotFoundException catch (e) {
  print('${e.resourceType}: ${e.message}');
}
```
