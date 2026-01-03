# datapod_postgres

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

Then configure it in your `databases.yaml`:

```yaml
databases:
  - name: my_db
    plugin: datapod_postgres
```

For full documentation, see the [root README](../README.md).
