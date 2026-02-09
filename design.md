## GOAL ##
This project will be a collection of packages to provide a uniform database API with an ORM mechanism similar to Spring Data JPA. It supports PostgreSQL, MySQL, and SQLite out of the box. Database support is implemented using a plugin architecture, allowing third parties to easily add support for other databases.

Key features include:
- **Uniform API**: Consistent interaction regardless of the backend.
- **Repository Pattern**: Automated implementation of repository interfaces.
- **Managed State**: Sophisticated tracking of entity persistence status.
- **Cascading Operations**: Automatic persistence and removal of related entities.
- **Lazy Loading**: Relationship fields can use `Future<T>` or `Future<List<T>>`.
- **Custom Plugins**: Support for private or third-party plugins via build-time discovery.

## databases.yaml ##
All projects using Datapod must have a `databases.yaml` file to define the backends used by the application. This is a development-time configuration.

```yaml
databases:
  - name: main_db
    plugin: datapod_postgres
  - name: local_cache
    plugin: datapod_sqlite
```

The `plugin` attribute can either be a standard package name (e.g., `datapod_postgres`) or a custom plugin name registered via `@DatapodPluginDef`.

## connections.yaml ##
A `connections.yaml` file defines the actual connection credentials. This is a runtime configuration and supports environment variable resolution using `${VAR_NAME}` syntax.

```yaml
connections:
  - name: main_db
    host: localhost
    port: 5432
    username: myuser
    password: ${DB_PASSWORD}
    database: myapp
```

## API ##
The Datapod API provides:
- **DatapodInitializer**: The generated entry point for initializing the framework.
- **DatapodContext**: Holds references to all configured databases and repositories.
- **TransactionManager**: Provides `runInTransaction<T>(Future<T> Function() action)` and `beginTransaction()`.
- **Repository<E,K>**: Base interface for entity `E` with key `K`.
  - Supports derived query methods: `findBy[Property][Operator]`.
  - Operators include: `In`, `NotIn`, `Like`, `Between`, `LessThan`, `GreaterThan`, `True`, `False`, `IsNull`, `IsNotNull`, `Contains`, `StartsWith`, `EndsWith`, and more.

## ANNOTATIONS ##
- **@Entity**: Maps a class to a database table.
- **@Column**: Maps a field to a column (optional, defaults to field name).
- **@Id**: Marks the primary key.
- **@Relationship**: (`OneToOne`, `OneToMany`, `ManyToOne`) Defines associations.
- **@Repository**: Marks an interface for implementation generation.
- **@DatapodPluginDef**: Marks a class as a custom database plugin for build-time discovery.

## DATABASE PLUGINS ##
Plugins implement the `DatapodPlugin` interface and are responsible for:
- Connection Management and Pooling
- SQL Generation and Translation
- Schema Management and Migration
- Transaction Semantics

Custom plugins can be defined within the application using `@DatapodPluginDef('plugin_name')`. The generator will automatically discover these and integrate them into the `DatapodInitializer`.

## MANAGED ENTITIES ##
Datapod uses a **Managed State** system to track entities:
- **Detached**: A plain instance created by the developer (e.g., `User()`). `save()` always performs an **INSERT**.
- **Managed**: An instance returned from the database, wrapped in a generated implementation (e.g., `_ManagedUser`).
- **Persistence Logic**: Managed entities track their ID and modification state. `save()` on a managed entity performs an **UPDATE** if changes are detected.

## CASCADING OPERATIONS ##
Relationships can be configured with cascading behavior:
- **CascadeType.persist**: Automatically saves related entities when the parent is saved.
- **CascadeType.remove**: Automatically deletes related entities when the parent is deleted.
- **CascadeType.all**: Includes both persist and remove.

## CODE GENERATION ##
Run `dart run build_runner build` to generate:
1. **Entity Implementations**: Managed versions of your classes with lazy loading and state tracking.
2. **Repository Implementations**: Full logic for your repository interfaces.
3. **DatapodInitializer**: Wiring code that orchestrates the entire framework setup.

## LEGAL ##
Copyright (c) 2025 Aaron Cosand <aaroncosand@gmail.com>

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
