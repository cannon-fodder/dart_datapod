# datapod_postgres

![Datapod Logo](https://raw.githubusercontent.com/cannon-fodder/dart_datapod/main/assets/datapod_logo.png)

The PostgreSQL database plugin for the Datapod ORM.

## ✨ Features

- Fully integrates PostgreSQL into the Datapod ecosystem.
- Supports transactions, connection pooling, and automated schema management.
- Handles advanced data types like JSONB and Arrays via Datapod's mapping system.

## 📖 Usage

Add to your `pubspec.yaml`:

```yaml
dependencies:
  datapod_postgres: any
```

```yaml
databases:
  - name: main_db
    plugin: datapod_postgres
```

In your `connections.yaml`, provide the credentials (supports environment variables):

```yaml
connections:
  - name: main_db
    host: ${DB_HOST:-localhost}
    port: 5432
    username: my_user
    password: ${DB_PASSWORD}
    database: my_app

  # Optional: Separate connection for migrations (e.g. admin user)
  - name: migration_db
    host: localhost
    port: 5432
    username: admin_user
    password: admin_password
    database: my_app
```

Then link it in `databases.yaml`:

```yaml
databases:
  - name: main_db
    plugin: datapod_postgres
    connection: main_db
    migrationConnection: migration_db # Optional
```

For full documentation, see the [root README](https://github.com/cannon-fodder/dart_datapod/blob/main/README.md).
