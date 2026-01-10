# datapod_sqlite

![Datapod Logo](https://raw.githubusercontent.com/cannon-fodder/dart_datapod/main/assets/datapod_logo.png)

The SQLite database plugin for the Datapod ORM framework.

## ✨ Features

- Fully integrates SQLite into the Datapod ecosystem.
- Supports both persistent file-based databases and `:memory:` databases.
- Automated schema management and type mapping.

## 📖 Usage

Add to your `pubspec.yaml`:

```yaml
dependencies:
  datapod_sqlite: any
```

Then configure it in your `databases.yaml`:

```yaml
databases:
  - name: my_db
    plugin: datapod_sqlite
    connection: my_sqlite_conn
```

In `connections.yaml`:

```yaml
connections:
  - name: my_sqlite_conn
    path: my_db.sqlite
    # or path: ":memory:" for in-memory database
```

For full documentation, see the [root README](https://github.com/cannon-fodder/dart_datapod/blob/main/README.md).
