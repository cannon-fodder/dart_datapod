# datapod_mysql

The MySQL database plugin for the Datapod ORM framework.

## ✨ Features

- Fully integrates MySQL into the Datapod ecosystem.
- Supports transactions, connection pooling, and automated schema management.
- Handles common MySQL data types via Datapod's mapping system.

## 📖 Usage

Add to your `pubspec.yaml`:

```yaml
dependencies:
  datapod_mysql: any
```

Then configure it in your `databases.yaml`:

```yaml
databases:
  - name: my_db
    plugin: datapod_mysql
    connection: my_conn
    migrationConnection: my_migration_conn # Optional
```

In `connections.yaml`:

```yaml
connections:
  - name: my_conn
    host: localhost
    port: 3306
    user: app_user
    password: password
    database: my_db

  - name: my_migration_conn
    host: localhost
    port: 3306
    user: admin_user
    password: admin_password
    database: my_db
```

For full documentation, see the [root README](https://github.com/cannon-fodder/dart_datapod/blob/main/README.md).
