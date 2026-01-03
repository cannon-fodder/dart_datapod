# datapod_sqlite

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
```

For full documentation, see the [root README](https://github.com/cannon-fodder/dart_datapod/blob/main/README.md).
