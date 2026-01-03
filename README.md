# Datapod ORM

Datapod is a powerful, modular Dart ORM (Object-Relational Mapper) inspired by the flexibility and convenience of Spring Data JPA. It provides a uniform API for interacting with various database backends, automated code generation for repositories, and intelligent entity management.

## 🚀 Key Features

- **Multi-Database Support**: Native support for **PostgreSQL**, **MySQL**, and **SQLite**.
- **Extensible Plugin Architecture**: Easily add support for new databases using custom plugins with build-time discovery.
- **Declarative Repositories**: Define repository interfaces; Datapod generates the implementation based on method naming conventions (e.g., `findByTitleContaining`).
- **Managed Entities**: Intelligent state tracking handles `INSERT` vs `UPDATE` automatically.
- **Lazy Loading**: Relationship fields can be defined as `Future<T>` for on-demand fetching.
- **Schema Management**: Built-in support for schema initialization and automated table mapping.
- **Type Safety**: Fully typed queries and result mapping using Dart's powerful type system.
- **Enterprise-Ready**: Support for connection pooling, transactions, and environment-based configuration.

---

## 📦 Package Ecosystem

Datapod is composed of several modular packages:

| Package | Description |
| :--- | :--- |
| **[datapod_api](./datapod_api)** | Core annotations (`@Entity`, `@Repository`, `@Id`) and base interfaces. |
| **[datapod_core](./datapod_core)** | Shared configuration logic and environment variable resolution. |
| **[datapod_engine](./datapod_engine)** | The heart of the ORM; handles plugin management and core execution logic. |
| **[datapod_generator](./datapod_generator)** | The build-time generator for repositories, entities, and initialization code. |
| **[datapod_postgres](./datapod_postgres)** | Official PostgreSQL driver plugin. |
| **[datapod_mysql](./datapod_mysql)** | Official MySQL driver plugin. |
| **[datapod_sqlite](./datapod_sqlite)** | Official SQLite (and in-memory) driver plugin. |

---

## 🛠️ Getting Started

### 1. Add Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  datapod_api: any
  # Add the plugins you need:
  datapod_postgres: any
  datapod_sqlite: any

dev_dependencies:
  datapod_generator: any
  build_runner: any
```

### 2. Configure Databases

Create a `databases.yaml` file in your project root to define your database backends:

```yaml
databases:
  - name: main_db
    plugin: datapod_postgres
  - name: cache_db
    plugin: datapod_sqlite
```

Create a `connections.yaml` for runtime credentials (supports environment variables):

```yaml
connections:
  - name: main_db
    host: localhost
    port: 5432
    username: myuser
    password: ${DB_PASSWORD}
    database: myapp
  - name: cache_db
    database: ":memory:"
```

### 3. Define Entities

```dart
import 'package:datapod_api/datapod_api.dart';

@Entity()
class User {
  @Id()
  int? id;

  @Column()
  late String name;

  @Column(unique: true)
  late String email;
}
```

### 4. Define Repositories

```dart
@Repository()
abstract class UserRepository extends BaseRepository<User, int> {
  Future<User?> findByEmail(String email);
  Future<List<User>> findByNameStartingWith(String prefix);
}
```

### 5. Generate and Initialize

Run the generator:
```bash
dart run build_runner build
```

Initialize Datapod in your app:
```dart
import 'datapod_init.dart';

void main() async {
  final context = await DatapodInitializer.initialize();
  
  final user = await context.userRepository.findByEmail('alice@example.com');
  print('Hello, ${user?.name}');
}
```

---

## 🔌 Custom Plugins

Applications can implement their own database plugins using the `@DatapodPluginDef` annotation. These are discovered at build-time, allowing the generator to seamlessly integrate third-party or local storage backends without manual wiring.

---

## 📄 License

Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
