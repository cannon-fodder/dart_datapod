# datapod_engine

<img src="https://raw.githubusercontent.com/cannon-fodder/dart_datapod/main/assets/datapod_logo.png" width="300">

The execution engine for the Datapod ORM framework. It manages database plugins, orchestrates cross-database relationships, and handles transaction boundaries.

## ✨ Features

- **Plugin Management**: Load and manage multiple database plugins in the same application.
- **Relationship Orchestration**: Handles cascading saves and deletes across different database backends.
- **Transaction Support**: Core logic for zone-based and manual transactions.
- **Configuration & Environment**:
    - Parse configurations from YAML files (`DatabaseConfig.load`).
    - Parse configurations from strings (`DatabaseConfig.parse`), enabling **Flutter** asset loading.
    - Resolves environment substitutions.
- **Build-Time Integration**: Supports the plugin discovery mechanism used by `datapod_generator`.

## 📖 Usage

This is a core framework package and is typically brought in as a dependency by database plugins or the generated code.

For full documentation, see the [root README](https://github.com/cannon-fodder/dart_datapod/blob/main/README.md).
