# Datapod ORM Examples

Comprehensive guide to usage patterns and best practices with Datapod.

## 📋 Table of Contents
- [Entity Definitions](#entity-definitions)
- [Repository Queries](#repository-queries)
- [Relationships](#relationships)
- [Transactions](#transactions)
- [Streams](#streams)
- [Multi-Database Orchestration](#multi-database-orchestration)

---

## Entity Definitions

### Basic Entity
```dart
@Entity()
class User {
  @Id()
  int? id;

  @Column()
  late String username;
}
```

### Advanced Mapping (JSON & Enums)
```dart
enum UserRole { admin, user, guest }

@Entity()
class Profile {
  @Id()
  int? id;

  @Column()
  UserRole role = UserRole.user;

  @Column()
  Map<String, dynamic>? settings;

  @Column()
  List<String> tags = [];
}
```

---

## Repository Queries

Datapod generates repository implementations based on method naming conventions in your abstract classes.

### Common DSL Patterns
```dart
@Repository()
abstract class ProductRepository extends BaseRepository<Product, int> {
  // Simple equality
  Future<Product?> findBySku(String sku);

  // Partial match
  Future<List<Product>> findByNameContaining(String part);

  // Comparison
  Future<List<Product>> findByPriceLessThan(double limit);

  // Boolean logic
  Future<List<Product>> findByCategoryAndInStockTrue(String category);

  // Count & Existence
  Future<int> countByCategoryId(int categoryId);
  Future<bool> existsBySku(String sku);
}
```

---

## Relationships

### Many-To-One (Lazy Loading)
```dart
@Entity()
class Post {
  @Id()
  int? id;

  @Column()
  late String title;

  @ManyToOne()
  Future<User?> author; // Use Future for lazy loading
}
```

### One-To-Many (Cascading)
```dart
@Entity()
class User {
  @Id()
  int? id;

  @OneToMany(mappedBy: 'author', cascade: [CascadeType.all])
  Future<List<Post>> posts;
}
```

---

## Transactions

Datapod provides a powerful `TransactionManager` that handles nesting via savepoints automatically.

### runInTransaction (Auto-Commit/Rollback)
```dart
await db.transactionManager.runInTransaction(() async {
  final user = await userRepo.save(User()..name = 'Alice');
  await profileRepo.save(Profile()..userId = user.id);
  // Both committed on success, or rolled back if an exception occurs
});
```

### Nested Transactions (Savepoints)
```dart
await db.transactionManager.runInTransaction(() async {
  await logRepo.info('Starting critical update');
  
  try {
    await db.transactionManager.runInTransaction(() async {
      await dataRepo.updateSensitiveData();
      throw Exception('Oops!'); 
    });
  } catch (e) {
    // Only 'updateSensitiveData' is rolled back via savepoint
    // 'logRepo.info' is still part of the outer transaction
  }
});
```

### Manual Transaction Control
```dart
final trans = await db.transactionManager.beginTransaction();
try {
  await db.connection.execute('INSERT INTO log (msg) VALUES (@msg)', {'msg': 'Manual'});
  await trans.commit();
} catch (e) {
  await trans.rollback();
}
```

---

## Streams

Consume database records as they are emitted for efficient handling of large result sets.

```dart
@Repository()
abstract class LogRepository extends BaseRepository<LogEntry, int> {
  Stream<LogEntry> findByType(String type);
}

// Consumption
await for (final entry in logRepo.findByType('ERROR')) {
  print('Process error: ${entry.message}');
}
```

---

## Multi-Database Orchestration

Define your database context in `datapod_init.dart` and share repositories across connections.

```dart
void main() async {
  final context = await DatapodInitializer.initialize();

  // Postgres Repo
  final users = await context.userRepository.findAll();

  // MySQL Repo
  final logs = await context.logRepository.findAll();
  
  // Cross-DB logic
  for (final user in users) {
    await context.logRepository.save(LogEntry()..msg = 'Processed ${user.name}');
  }
}
```
