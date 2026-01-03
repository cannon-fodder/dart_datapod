# datapod_core

Common core logic for the Datapod ORM framework. This package provides shared configuration management, environment variable resolution, and basic utilities used across the framework.

## ✨ Features

- **Configuration Management**: Logic for loading and parsing `databases.yaml` and `connections.yaml`.
- **Environment Resolution**: Seamlessly resolves `${VAR_NAME}` in configuration files to environment variables.
- **Exception Hierarchy**: Defines standard exceptions like `ConfigurationException`.
- **Logging**: Standardized logging utilities for the framework.

## 📖 Usage

This is a internal framework package and is typically brought in as a dependency by other Datapod packages.

For full documentation, see the [root README](https://github.com/cannon-fodder/dart_datapod/blob/main/README.md).
