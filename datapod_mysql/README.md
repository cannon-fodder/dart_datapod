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
```

For full documentation, see the [root README](https://github.com/cannon-fodder/dart_datapod/blob/main/README.md).
